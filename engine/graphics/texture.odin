#+feature using-stmt
package graphics
import "base:runtime"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:bytes"
import "core:container/intrusive/list"
import "core:fmt"
import "core:image"
import "core:image/qoi"
import "core:image/png"
import "core:image/jpeg"
import os "core:os/os2"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:mem"
import "core:path/filepath"
import "core:reflect"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:thread"
import "core:time"
import tracy "shared:tracy"


Texture :: struct {
	name:        string,
	handle:      u32,
	using image: image.Image }


new_generic_texture :: proc(draw: ^Draw, name: string) -> (texture_ptr: ^Texture) {
	texture: Texture = { name = name }
	append(&draw.generic_textures, texture)
	texture_ptr = &draw.generic_textures[len(draw.generic_textures) - 1]
	draw.textures_map[name] = texture_ptr
	return }


// (DESC): Look for a generic texture with the given name. //
generic_textures_search :: proc(draw: ^Draw, name: string) -> (index: int, ok: bool) {
	ptr, found := draw.textures_map[name]
	if ! found do return -1, false
	return cast(int)(cast(uintptr)ptr - cast(uintptr)&draw.generic_textures[0]) / size_of(Texture), true }


// (DESC): Look for a generic texture with the given name. If one is found, return it and remove it. //
generic_texture_search_and_remove :: proc(draw: ^Draw, name: string) -> (texture: Texture, ok: bool) {
	index, found := generic_textures_search(draw, name)
	if ! found do return {}, false
	if index >= len(draw.generic_textures) do return
	texture = draw.generic_textures[index]
	unordered_remove(&draw.generic_textures, index)
	return texture, true }


// (DESC): Initialize all QOI textures found in the data folder. //
textures_init_all_from_qoi_data :: proc(draw: ^Draw) {
	directory_path: string
	directory:      ^os.File
	error:          os.Error
	files:          []os.File_Info
	texture_ptr:    ^Texture
	texture_name:   string
	bytes:          []u8
	ok:             bool

	directory_path = filepath.join({ working_directory_path, IMAGES_PATH_RELATIVE })
	directory, error = os.open(directory_path)
	files, error = os.read_directory(directory, -1, context.allocator)
	for file in files {
		if filepath.ext(file.name) != ".qoi" do continue
		texture_name = filepath.stem(file.name)
		texture_ptr = new_generic_texture(draw, texture_name)
		bytes, error = os.read_entire_file_from_path(file.fullpath, context.allocator)
		assert(error == nil)
		ok = init_texture_from_qoi(draw, texture_ptr, texture_name, bytes)
		assert(ok) } }


texture_to_qoi :: proc(texture: ^Texture) -> []u8 {
	output:    bytes.Buffer
	error:     image.Error

	bytes.buffer_init_allocator(&output, 0, 1024, context.allocator)
	error = qoi.save_to_buffer(&output, &texture.image)
	assert(error == nil)
	return output.buf[:] }


// texture_write_to_qoi :: proc(texture: ^Texture) {
// 	path:  string
// 	error: image.Error

// 	path = filepath.join({ working_directory_path, IMAGES_PATH_RELATIVE, fmt.tprintf("%s.qoi", texture.name) })
// 	error = qoi.save_to_file(path, &texture.image)
// 	assert(error == nil) }


init_texture_from_bytes :: proc(draw: ^Draw, texture: ^Texture, name: string, data: []u8, size: [2]int, channels, depth: int) -> bool {
	texture.name = name
	buffer_size := image.compute_buffer_size(size.x, size.y, channels, depth)
	buffer: bytes.Buffer
	bytes.buffer_init(&buffer, data)
	texture.image = { width = size.x, height = size.y, channels = channels, depth = depth, pixels = buffer }
	return true }


init_texture_from_image_bytes :: proc(draw: ^Draw, texture: ^Texture, load_proc: image.Loader_Proc, name: string, bytes: []u8) -> bool {
	texture_image: ^image.Image
	error:         image.Error

	texture.name = name
	texture_image, error = load_proc(bytes, { .alpha_add_if_missing }, context.allocator)
	fmt.assertf(error == nil, "Failed to load image %s because %v.", name, error)
	texture.image = texture_image^
	free(texture_image)
	return true }


init_texture_from_png :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
	fmt.println(WARN, "Calling init_texture_from_png")
	return init_texture_from_image_bytes(draw, texture, png.load_from_bytes, name, bytes) }


init_texture_from_jpeg :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
	return init_texture_from_image_bytes(draw, texture, jpeg.load_from_bytes, name, bytes) }


init_texture_from_qoi :: proc(draw: ^Draw, texture: ^Texture, name: string, bytes: []u8) -> bool {
	return init_texture_from_image_bytes(draw, texture, qoi.load_from_bytes, name, bytes) }


init_texture_from_data :: proc(draw: ^Draw, texture: ^Texture, data_path: string, name: string) -> bool {
	path := filepath.join({ data_path, fmt.aprintf("%s.png", name) })
	bytes, error := os.read_entire_file_from_path(path, context.allocator)
	if error != nil {
		fmt.println(BAD, "Could not find file", path)
		return false }
	return init_texture_from_png(draw, texture, name, bytes) }


init_texture_from_description :: proc(draw: ^Draw, texture: ^Texture, name: string, size: [2]int, channels, depth: int) -> bool {
	bytes: []u8 = make([]u8, image.compute_buffer_size(size.x, size.y, channels, depth))
	return init_texture_from_bytes(draw, texture, name, bytes, size, channels, depth) }


load_texture :: proc(draw: ^Draw, texture: ^Texture) -> bool {
	if texture.handle != 0 do unload_texture(texture)
	gl.GenTextures(1, &texture.handle)
	gl.BindTexture(gl.TEXTURE_2D, texture.handle)
	internal_format: i32
	data_format: u32
	data_format_type: u32
	switch texture.image.channels {
	case 1:
		switch texture.image.depth {
		case 8:
			internal_format = gl.R8
			data_format = gl.RED
		case:
			fmt.printfln(BAD + "Unsupported data format for texture %s.", texture.name)
			return false }
	case 3:
		switch texture.image.depth {
		case 8:
			internal_format = gl.RGB8
			data_format = gl.RGB
		case:
			fmt.printfln(BAD + "Unsupported data format for texture %s.", texture.name)
			return false }
	case 4:
		switch texture.image.depth {
		case 8:
			internal_format = gl.RGBA8
			data_format = gl.RGBA
		case:
			fmt.printfln(BAD + "Unsupported internal format for texture %s.", texture.name)
			return false }
	case:
		fmt.println(BAD + "Unsupported channel count for texture %s.", texture.name)
		return false }
	data_format_type = gl.UNSIGNED_BYTE
	gl.TexImage2D(gl.TEXTURE_2D, 0, internal_format, cast(i32)texture.width, cast(i32)texture.height, 0, data_format, data_format_type, &texture.image.pixels.buf[0])
	texture_wrapping(gl.REPEAT)
	texture_filtering(gl.NEAREST)
	return true }


unload_texture :: proc(texture: ^Texture) {
	gl.DeleteTextures(1, &texture.handle)
	texture.handle = 0 }


init_texture_from_image :: proc(draw: ^Draw, texture: ^Texture, im: image.Image) -> bool {
	texture.image = im
	return true }


texture_pixel :: proc(texture: ^Texture, index: [2]int) -> []u8 {
	stride: int = (texture.depth / 8) * texture.channels
	offset: int = (index.y * texture.width + index.x) * stride
	return texture.pixels.buf[offset : offset + stride] }


// (DESC): Iterate through the pixel positions in a texture. //
Texture_Position_Iterator :: struct {
	size:     [2]int,
	position: [2]int }


make_texture_position_iterator :: proc(size: [2]int) -> Texture_Position_Iterator {
	return { size = size, position = { 0, 0 } } }


texture_position_iterate_next :: proc(iterator: ^Texture_Position_Iterator) -> (position: [2]int, ok: bool) {
	position = iterator.position
	if iterator.position.y >= iterator.size.y do return { 0, 0 }, false
	if iterator.position.x < iterator.size.x - 1 {
		iterator.position.x += 1 }
	else {
		iterator.position.y += 1
		iterator.position.x = 0 }
	return position, true }


// (DESC): Iterate through the pixels in a texture. //
Texture_Pixel_Iterator :: struct($Type: typeid) {
	size:     [2]int,
	pixels:   []Type,
	index:    int,
	position: [2]int }


make_texture_pixel_iterator :: proc(texture: ^Texture, size: [2]int, $Type: typeid) -> Texture_Pixel_Iterator(Type) {
	return { size = size, pixels = slice.reinterpret([]Type, texture.pixels.buf[:]), index = 0 } }


texture_pixel_iterate_next :: proc(iterator: ^Texture_Pixel_Iterator($Type)) -> (pixel: ^Type, pixel_position: [2]int, ok: bool) {
	if iterator.index >= len(iterator.pixels) do return nil, { 0, 0 }, false
	pixel = &iterator.pixels[iterator.index]
	iterator.index += 1
	pixel_position = iterator.position
	if iterator.position.x < iterator.size.x - 1 {
		iterator.position.x += 1 }
	else {
		iterator.position.y += 1
		iterator.position.x = 0 }
	return pixel, pixel_position, true }


texture_pixel_from_position :: proc(texture: ^Texture, position: [2]int, $Type: typeid) -> (pixel: ^Type) {
	// fmt.println("looking for pixel at position", position)
	pixels := slice.reinterpret([]Type, texture.pixels.buf[:])
	return &pixels[position.y * texture.width + position.x] }

