#+feature using-stmt
package oggun
import "base:runtime"
import "core:os"
import im "core:image"
import "core:image/png"
import "core:image/jpeg"
import "core:bytes"
import "core:slice"
import "core:log"
import "core:time"
import gl "vendor:OpenGL"

Texture :: struct #packed {
	using asset: Asset,
	using shape: Texture_Shape,
	bytes: []u8,
	modification_time: time.Time,
	gpu_modification_time: time.Time,
	handle: u32 }

Texture_Shape :: struct #packed {
	size: [2]u32,
	channels: u8,
	depth: u8 }

DEFAULT_TEXTURE_SIZE: [2]u32 : { 1024, 1024 }

new_texture :: proc() -> ^Texture {
	_, err := append(&state.graphics_manager.textures, Texture{ })
	if err != nil do return nil
	return &state.graphics_manager.textures[len(state.graphics_manager.textures) - 1] }

texture_init :: proc(texture: ^Texture, config: Asset_Config, shape: Texture_Shape = {}) {
	config := config
	config.derived_type = Texture
	texture.shape = shape
	am_init_asset(Texture, &texture.asset, config) }

texture_equals :: proc(texture0: ^Texture, texture1: ^Texture) -> bool {
	return (texture0.shape == texture1.shape) && slice.equal(texture0.bytes, texture1.bytes) }

_texture_modification_time :: proc(texture: ^Texture, location: Asset_Location) -> (modification_time: time.Time) {
	#partial switch location {
	case .Source:
		path := am_path_from_url(texture.url, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Storage:
		path := relpath_to_path(state.asset_manager.relpath, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database:
		entry := am_get_entry(texture.url)
		return (entry != nil) ? entry.modification_time : {}
	case .RAM:
		return texture.modification_time
	case .VRAM:
		return texture.gpu_modification_time }
	return {} }

_image_as_bytes :: proc(image: ^im.Image) -> []u8 {
	shrink(&image.pixels.buf)
	return image.pixels.buf[:] }

_image_shape :: proc(image: ^im.Image) -> Texture_Shape {
	return {
		size = { auto_cast image.width, auto_cast image.height },
		depth = auto_cast image.depth,
		channels = auto_cast image.channels } }

texture_op :: proc(asset: ^Asset, op: Asset_Op, dest: Asset_Location = .None, src: Asset_Location = .None, arg: rawptr = nil, location := #caller_location) -> (ok: bool) {
	texture := am_asset_base(asset, Texture, "asset")
	// #partial switch op {
	// case .Download, .Upload, .Serialize, .Deserialize, .Export, .Import:
	// 	if len(texture.bytes) == 0 {
	// 		width: int = (image.size.x != 0) ? image.size.x : DEFAULT_TEXTURE_SIZE.x
	// 		height: int = (image.size.y != 0) ? image.size.y : DEFAULT_TEXTURE_SIZE.y
	// 		image.image = make_image(width, height) } }
	ni: bool = false
	#partial switch op {
	case .Make:
		#partial switch dest {
		case .RAM:
			texture.bytes = make([]u8, int(texture.size.x * texture.size.y * auto_cast texture.depth * auto_cast texture.channels / 8))
			return true
		case .VRAM:
			gl.GenTextures(1, &texture.handle)
			return true
		case: ni = true }
	case .Delete:
		#partial switch dest {
		case .RAM:
			delete(texture.bytes)
			return true
		case .VRAM:
			if texture.handle != 0 do gl.DeleteTextures(1, &texture.handle)
			texture.handle = 0
			return true
		case: ni = true }
	case .Initialize:
		#partial switch dest {
		case .RAM:
			slice.zero(texture.bytes)
			return true
		case: ni = true }
	case .Exists:
		#partial switch dest {
		case .Source:
			path := am_path_from_url(asset.url, context.temp_allocator)
			return os.exists(path)
		case .RAM:
			return len(texture.bytes) > 0
		case .VRAM:
			return texture.handle != 0
		case: ni = true }
	case .Translate:
		vector: [2]Asset_Location = { src, dest }
		switch vector {
		case { .Source, .RAM }:
			if texture.url == "" do return false
			path := am_path_from_url(texture.url, context.allocator)
			modification_time, _ := os.modification_time_by_path(path)
			if time.diff(texture.modification_time, modification_time) <= 0 do return true
			loader_proc: im.Loader_Proc
			switch ext := os.ext(path); ext {
			case ".png": loader_proc = png.load_from_bytes
			case ".jpg", ".jpeg": loader_proc = jpeg.load_from_bytes
			case: log.errorf("Unrecognized texture extension \"%s\".", ext, location=location); return false }
			bytes, err := os.read_entire_file(path, context.allocator)
			image_temp, image_err := loader_proc(bytes, im.Options{}, context.allocator)
			if image_err != nil {
				log.errorf("Image error: %v.", image_err, location=location); return false }
			texture.bytes = _image_as_bytes(image_temp)
			texture.shape = _image_shape(image_temp)
			free(image_temp)
			texture.modification_time = modification_time
			return true
		case { .Database, .RAM }:
			bytes, _ := texture_serialize(texture, context.allocator)
			am_add_or_update_entry(am_make_entry(texture.url, bytes, texture.modification_time))
			return true
		case { .RAM, .VRAM }:
			if texture.handle == 0 {
				log.errorf("Texture VRAM representation not allocated.", location=location)
				return false }
			gl.BindTexture(gl.TEXTURE_2D, texture.handle)
			internal_format: i32
			data_format: u32
			data_format_type: u32
			switch texture.channels {
			case 1:
				switch texture.depth {
				case 8:
					internal_format = gl.R8
					data_format = gl.RED
				case:
					log.errorf("Unsupported data format %v for texture %s.", texture.shape, texture.url, location=location)
					return false }
			case 3:
				switch texture.depth {
				case 8:
					internal_format = gl.RGB8
					data_format = gl.RGB
				case:
					log.errorf("Unsupported data format %v for texture %s.", texture.shape, texture.url, location=location)
					return false }
			case 4:
				switch texture.depth {
				case 8:
					internal_format = gl.RGBA8
					data_format = gl.RGBA
				case:
					log.errorf("Unsupported internal format for texture %s.", texture.url, location=location)
					return false }
			case:
				log.errorf("Unsupported channel count for texture %s.", texture.url, location=location)
				return false }
			data_format_type = gl.UNSIGNED_BYTE
			gl.TexImage2D(gl.TEXTURE_2D, 0, internal_format, cast(i32)texture.size.x, cast(i32)texture.size.y, 0, data_format, data_format_type, &texture.bytes[0])
			texture_wrapping(gl.REPEAT)
			texture_filtering(gl.NEAREST)
			texture.gpu_modification_time = texture.modification_time
			return true
		case: ni = true }
	case: ni = true }
	if ni do am_error_not_implemented(op, dest, src, location)
	return false }

// import_or_retreive_image :: proc(database: ^Asset_Manager, url: URL, allocator: runtime.Allocator) -> (image: Texture, err: os.Error) {
// 	entry: ^Entry
// 	ok: bool
// 	path: string
// 	modification_time: t.Time
// 	bytes: []u8

// 	entry, ok = am_get_entry(database, url)
// 	if ok do if am_entry_was_modified(database, entry) || database.spec_modified do ok = false
// 	if ok do image = texture_deserialize(entry.bytes, allocator) or_return
// 	else {
// 		log.infof("Reading image %s from source.", url)
// 		path = url_search_source(database, url, allocator) or_return
// 		image = load_image_from_path(path, url, allocator) or_return
// 		modification_time = os.modification_time_by_path(path) or_return
// 		bytes = texture_serialize(&image, allocator) or_return
// 		am_add_or_update_entry(database, am_make_entry(url, bytes, modification_time), true) or_return }
// 	return image, os.General_Error.None }

@require_results
texture_serialize :: proc(texture: ^Texture, allocator: runtime.Allocator) -> (image_bytes: []u8, err: os.Error) {
	buffer: bytes.Buffer
	n: int

	bytes.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	bytes.buffer_write_ptr(&buffer, texture, size_of(texture^)) or_return
	bytes.buffer_write_slice(&buffer, texture.bytes) or_return
	return slice.clone(bytes.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@require_results
texture_deserialize :: proc(image_bytes: []u8, allocator: runtime.Allocator) -> (texture: Texture, err: os.Error) {
	reader: bytes.Reader
	n: int

	bytes.reader_init(&reader, image_bytes)
	bytes.reader_read_ptr(&reader, &texture, size_of(texture)) or_return
	n = len(texture.bytes)
	texture.bytes = make([]u8, n, allocator) or_return
	bytes.reader_read_slice(&reader, texture.bytes) or_return
	return texture, os.General_Error.None }

_texture_shape_to_gl_format :: proc(shape: Texture_Shape) -> u32 {
	switch shape.channels {
	case 1: return gl.RED
	case 2: return gl.RG
	case 3: return gl.RGB
	case 4: return gl.RGBA }
	return 0 }

_texture_shape_to_gl_internal_format :: proc(shape: Texture_Shape) -> i32 {
	switch shape.depth {
	case 8:
		switch shape.channels {
		case 1: return gl.R8
		case 2: return gl.RG8
		case 3: return gl.RGB8
		case 4: return gl.RGBA8 }
	case 16:
		switch shape.channels {
		case 1: return gl.R16F
		case 2: return gl.RG16F
		case 3: return gl.RGB16F
		case 4: return gl.RGBA16F }
	case 32:
		switch shape.channels {
		case 1: return gl.R16F
		case 2: return gl.RG32F
		case 3: return gl.RGB32F
		case 4: return gl.RGBA32F } }
	return 0 }

texture_shapes_compatible :: proc(shape0: Texture_Shape, shape1: Texture_Shape) -> bool {
	return (shape0.channels == shape1.channels) &&
	       (shape0.depth == shape1.depth) &&
	       ((shape0.size == shape1.size) || (shape0.size == 0) || (shape1.size == 0)) }

default_texture_shape :: proc(size: [2]u32 = { 0, 0 }, channels: u8 = 4, depth: u8 = 1) -> Texture_Shape {
	return {
		size = size != { 0, 0 } ? size : cast([2]u32)state.graphics_manager.active_resolution,
		channels = channels,
		depth = depth } }

// make_image :: proc(#any_int width: int, #any_int height: int, channels: int, allocator := context.allocator) -> (image: im.Image) {
// 	if (channels < 1) || (channels > 4) do log.errorf("Invalid channel-count: %d", channels)
// 	switch channels {
// 	case 1:
// 		pixels := make([][1]u8, width * height, allocator)
// 		image, _ = im.pixels_to_image(pixels, width, height)
// 	case 2:
// 		pixels := make([][2]u8, width * height, allocator)
// 		image, _ = im.pixels_to_image(pixels, width, height)
// 	case 3:
// 		pixels := make([][3]u8, width * height, allocator)
// 		image, _ = im.pixels_to_image(pixels, width, height)
// 	case 4:
// 		pixels := make([][4]u8, width * height, allocator)
// 		image, _ = im.pixels_to_image(pixels, width, height) }
// 	return image }

// texture_to_qoi :: proc(texture: ^Texture) -> []u8 {
// 	output:    bytes.Buffer
// 	error:     im.Error

// 	bytes.buffer_init_allocator(&output, 0, 1024, context.allocator)
// 	error = qoi.save_to_buffer(&output, &texture.image)
// 	assert(error == nil)
// 	return output.buf[:] }


// // texture_write_to_qoi :: proc(texture: ^Texture) {
// // 	path:  string
// // 	error: im.Error

// // 	path = filepath.join({ working_directory_path, IMAGES_PATH_RELATIVE, fmt.tprintf("%s.qoi", texture.name) })
// // 	error = qoi.save_to_file(path, &texture.image)
// // 	assert(error == nil) }


// init_texture_from_bytes :: proc(draw: ^Draw, texture: ^Texture, name: string, data: []u8, size: [2]int, channels, depth: int) -> bool {
// 	texture.name = name
// 	buffer_size := im.compute_buffer_size(size.x, size.y, channels, depth)
// 	buffer: bytes.Buffer
// 	bytes.buffer_init(&buffer, data)
// 	texture.image = { width = size.x, height = size.y, channels = channels, depth = depth, pixels = buffer }
// 	return true }

// init_texture_from_url :: proc(graphics_context: ^Graphics_Manager, config: Texture_Config) -> (err: os.Error) {
// 	texture: Texture
// 	path: string
// 	texture_image: ^im.Image
// 	image_err: im.Error
// 	load_proc: im.Loader_Proc
// 	data: []u8

// 	texture.config = config
// 	path = am_relpath_to_source_path(database, am_relpath_from_url(database, url, context.allocator), context.allocator)
// 	if entry, ok = db.am_get_entry(&database, url); ok {
// 		data = entry.bytes }
// 	else {
// 		data = os.read_entire_file_from_path(path, context.allocator) or_return
// 		db.am_make_entry(url, data, os.modification_time_by_path(path)) }

// 	// DICK
// 	texture_image, image_err = load_proc(bytes, { .alpha_add_if_missing }, context.allocator)
// 	fmt.assertf(error == nil, "Failed to load image %s because %v.", name, image_err)
// 	texture.image = texture_image^
// 	free(texture_image)
// 	return os.General_Error.None }

// init_texture_from_png :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
// 	fmt.println(WARN, "Calling init_texture_from_png")
// 	return init_texture_from_image_bytes(draw, texture, png.load_from_bytes, name, bytes) }

// init_texture_from_jpeg :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
// 	return init_texture_from_image_bytes(draw, texture, jpeg.load_from_bytes, name, bytes) }


// init_texture_from_qoi :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
// 	return init_texture_from_image_bytes(draw, texture, qoi.load_from_bytes, name, bytes) }


// init_texture_from_data :: proc(draw: ^Draw, texture: ^Texture, data_path: string, name: string) -> bool {
// 	path := filepath.join({ data_path, fmt.aprintf("%s.png", name) })
// 	bytes, error := os.read_entire_file_from_path(path, context.allocator)
// 	if error != nil {
// 		fmt.println(BAD, "Could not find file", path)
// 		return false }
// 	return init_texture_from_png(draw, texture, name, bytes) }


// init_texture_from_description :: proc(draw: ^Draw, texture: ^Texture, name: string, size: [2]int, channels, depth: int) -> bool {
// 	bytes: []u8 = make([]u8, im.compute_buffer_size(size.x, size.y, channels, depth))
// 	return init_texture_from_bytes(draw, texture, name, bytes, size, channels, depth) }

// init_texture_from_image :: proc(draw: ^Draw, texture: ^Texture, im: im.Image) -> bool {
// 	texture.image = im
// 	return true }


// texture_pixel :: proc(texture: ^Texture, index: [2]int) -> []u8 {
// 	stride: int = (texture.depth / 8) * texture.channels
// 	offset: int = (index.y * texture.size.x + index.x) * stride
// 	return texture.pixels.buf[offset : offset + stride] }


// // (DESC): Iterate through the pixel positions in a texture. //
// Texture_Position_Iterator :: struct {
// 	size:     [2]int,
// 	position: [2]int }


// make_texture_position_iterator :: proc(size: [2]int) -> Texture_Position_Iterator {
// 	return { size = size, position = { 0, 0 } } }


// texture_position_iterate_next :: proc(iterator: ^Texture_Position_Iterator) -> (position: [2]int, ok: bool) {
// 	position = iterator.position
// 	if iterator.position.y >= iterator.size.y do return { 0, 0 }, false
// 	if iterator.position.x < iterator.size.x - 1 {
// 		iterator.position.x += 1 }
// 	else {
// 		iterator.position.y += 1
// 		iterator.position.x = 0 }
// 	return position, true }


// // (DESC): Iterate through the pixels in a texture. //
// Texture_Pixel_Iterator :: struct($Type: typeid) {
// 	size:     [2]int,
// 	pixels:   []Type,
// 	index:    int,
// 	position: [2]int }


// make_texture_pixel_iterator :: proc(texture: ^Texture, size: [2]int, $Type: typeid) -> Texture_Pixel_Iterator(Type) {
// 	return { size = size, pixels = slice.reinterpret([]Type, texture.pixels.buf[:]), index = 0 } }


// texture_pixel_iterate_next :: proc(iterator: ^Texture_Pixel_Iterator($Type)) -> (pixel: ^Type, pixel_position: [2]int, ok: bool) {
// 	if iterator.index >= len(iterator.pixels) do return nil, { 0, 0 }, false
// 	pixel = &iterator.pixels[iterator.index]
// 	iterator.index += 1
// 	pixel_position = iterator.position
// 	if iterator.position.x < iterator.size.x - 1 {
// 		iterator.position.x += 1 }
// 	else {
// 		iterator.position.y += 1
// 		iterator.position.x = 0 }
// 	return pixel, pixel_position, true }


// texture_pixel_from_position :: proc(texture: ^Texture, position: [2]int, $Type: typeid) -> (pixel: ^Type) {
// 	// fmt.println("looking for pixel at position", position)
// 	pixels := slice.reinterpret([]Type, texture.pixels.buf[:])
// 	return &pixels[position.y * texture.size.x + position.x] }
