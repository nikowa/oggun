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

Texture :: struct {
	using asset: Asset,
	using image: im.Image,
	modification_time: time.Time,
	gpu_modification_time: time.Time,
	handle: u32,
	render_buffer: ^Render_Buffer }

Texture_Create_Flag :: enum {
	Allocate_Empty,
	Allocate_Render_Buffer }

Texture_Create_Flags :: bit_set[Texture_Create_Flag]

DEFAULT_IMAGE_SIZE: [2]int : { 1024, 1024 }

texture_init :: proc(texture: ^Texture, config: Asset_Config, flags: Texture_Create_Flags = {}) {
	config := config
	config.derived_type = Texture
	if .Allocate_Empty in flags do _texture_allocate_empty(texture)
	if .Allocate_Render_Buffer in flags do _texture_allocate_render_buffer(texture)
	am_init_asset(Texture, &texture.asset, config) }

image_equiv :: proc(a: ^Texture, b: ^Texture) -> bool {
	return (a.url == b.url) &&
		(a.width == b.width) &&
		(a.channels == b.channels) &&
		(a.depth == b.depth) &&
		(a.background == b.background) &&
		(a.metadata == b.metadata) &&
		(a.which == b.which) }

image_modification_time :: proc(image: ^Texture, location: Asset_Location_Field) -> (modification_time: time.Time) {
	switch location {
	case .Source_Directory:
		path := am_path_from_url(image.url, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database_File:
		path := relpath_to_path(engine.asset_manager.relpath, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database:
		entry := am_get_entry(image.url)
		return (entry != nil) ? entry.modification_time : {}
	case .Main_Memory:
		return image.modification_time
	case .GPU_Memory:
		return image.gpu_modification_time }
	return {} }

texture_is_empty :: proc(image: ^Texture) -> bool {
	return len(image.pixels.buf) == 0 }

_texture_allocate_empty :: proc(texture: ^Texture) {
	width: int = (texture.width != 0) ? texture.width : DEFAULT_IMAGE_SIZE.x
	height: int = (texture.height != 0) ? texture.height : DEFAULT_IMAGE_SIZE.y
	// channels: int = (texture.channels != 0) ? texture.channels : 4
	texture.image = make_image(width, height, 4) }

_texture_allocate_render_buffer :: proc(texture: ^Texture) {
	texture.render_buffer = new(Render_Buffer)
	texture.render_buffer^ = make_render_buffer({ cast(f32)texture.width, cast(f32)texture.height }, { gl.RGBA8 }, { gl.RGBA }, { gl.UNSIGNED_BYTE }) }

@private
texture_command :: proc(asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	image := am_asset_base(asset, Texture, "asset")
	// #partial switch command {
	// case .Download, .Upload, .Serialize, .Deserialize, .Export, .Import:
	// 	if texture_is_empty(image) {
	// 		width: int = (image.width != 0) ? image.width : DEFAULT_IMAGE_SIZE.x
	// 		height: int = (image.height != 0) ? image.height : DEFAULT_IMAGE_SIZE.y
	// 		image.image = make_image(width, height) } }
	switch command {
	case .Validate:
	case .Query_Location:
		path := am_path_from_url(asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
	case .Import:
		if image.url == "" do return false
		err: os.Error
		path := am_path_from_url(image.url, context.allocator)
		modification_time, _ := os.modification_time_by_path(path)
		if time.diff(image.modification_time, modification_time) <= 0 do return true
		loader_proc: im.Loader_Proc
		switch ext := os.ext(path); ext {
		case ".png": loader_proc = png.load_from_bytes
		case ".jpg", ".jpeg": loader_proc = jpeg.load_from_bytes
		case: log.errorf("Unrecognized image extension \"%s\".", ext); return false }
		bytes: []u8
		if bytes, err = os.read_entire_file(path, context.allocator); err != nil {
			return false }
		image_temp, image_err := loader_proc(bytes, im.Options{}, context.allocator)
		if image_err != nil {
			log.errorf("Image error: %v.", image_err); return false }
		image.image = image_temp^
		free(image_temp)
		bytes, _ = image_serialize(image, context.allocator)
		am_add_or_update_entry(am_make_entry(image.url, bytes, modification_time))
		asset.location += { .Database, .Main_Memory }
		image.modification_time = modification_time
		return true
	case .Export:
		if image.url == "" do return false
	case .Deserialize:
		if image.url == "" do return false
		return texture_command(asset, .Import, watch)
	case .Serialize:
		if image.url == "" do return false
	case .Upload:
		if image.handle != 0 do download_image(image)
		gl.GenTextures(1, &image.handle)
		gl.BindTexture(gl.TEXTURE_2D, image.handle)
		internal_format: i32
		data_format: u32
		data_format_type: u32
		switch image.channels {
		case 1:
			switch image.depth {
			case 8:
				internal_format = gl.R8
				data_format = gl.RED
			case:
				log.errorf("Unsupported data format for texture %s.", image.url)
				return false }
		case 3:
			switch image.depth {
			case 8:
				internal_format = gl.RGB8
				data_format = gl.RGB
			case:
				log.errorf("Unsupported data format for texture %s.", image.url)
				return false }
		case 4:
			switch image.depth {
			case 8:
				internal_format = gl.RGBA8
				data_format = gl.RGBA
			case:
				log.errorf("Unsupported internal format for texture %s.", image.url)
				return false }
		case:
			log.errorf("Unsupported channel count for texture %s.", image.url)
			return false }
		data_format_type = gl.UNSIGNED_BYTE
		gl.TexImage2D(gl.TEXTURE_2D, 0, internal_format, cast(i32)image.width, cast(i32)image.height, 0, data_format, data_format_type, &image.pixels.buf[0])
		texture_wrapping(gl.REPEAT)
		texture_filtering(gl.NEAREST)
		image.gpu_modification_time = image.modification_time
		asset.location += { .GPU_Memory }
		return true
	case .Download: }
	return false }

// import_or_retreive_image :: proc(database: ^Asset_Manager, url: URL, allocator: runtime.Allocator) -> (image: Texture, err: os.Error) {
// 	entry: ^Entry
// 	ok: bool
// 	path: string
// 	modification_time: t.Time
// 	bytes: []u8

// 	entry, ok = am_get_entry(database, url)
// 	if ok do if am_entry_was_modified(database, entry) || database.spec_modified do ok = false
// 	if ok do image = image_deserialize(entry.data, allocator) or_return
// 	else {
// 		log.infof("Reading image %s from source.", url)
// 		path = url_search_source(database, url, allocator) or_return
// 		image = load_image_from_path(path, url, allocator) or_return
// 		modification_time = os.modification_time_by_path(path) or_return
// 		bytes = image_serialize(&image, allocator) or_return
// 		am_add_or_update_entry(database, am_make_entry(url, bytes, modification_time), true) or_return }
// 	return image, os.General_Error.None }

@(require_results)
image_serialize :: proc(image: ^Texture, allocator: runtime.Allocator) -> (image_bytes: []u8, err: os.Error) {
	buffer: bytes.Buffer
	n: int

	bytes.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	bytes.buffer_write_ptr(&buffer, image, size_of(image^)) or_return
	bytes.buffer_write_slice(&buffer, bytes.buffer_to_bytes(&image.pixels)) or_return
	return slice.clone(bytes.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@(require_results)
image_deserialize :: proc(image_bytes: []u8, allocator: runtime.Allocator) -> (image: Texture, err: os.Error) {
	reader: bytes.Reader
	n: int

	bytes.reader_init(&reader, image_bytes)
	bytes.reader_read_ptr(&reader, &image, size_of(image)) or_return
	n = len(image.pixels.buf)
	image.pixels.buf = make_dynamic_array_len_cap([dynamic]u8, n, n, allocator) or_return
	bytes.reader_read_slice(&reader, image.pixels.buf[:]) or_return
	return image, os.General_Error.None }

download_image :: proc(image: ^Texture) {
	gl.DeleteTextures(1, &image.handle)
	image.handle = 0 }

image_loaded :: proc(image: ^Texture) -> bool {
	return image.handle != 0 }

make_image :: proc(#any_int width: int, #any_int height: int, $channels: int, allocator := context.allocator) -> (image: im.Image) {
	pixels := make([][channels]u8, width * height, allocator)
	ok: bool; image, ok = im.pixels_to_image(pixels, width, height)
	assert(ok)
	return image }
