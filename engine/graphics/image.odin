#+feature using-stmt
package graphics
import rt "base:runtime"
import os "core:os"
import im "core:image"
import png "core:image/png"
import jpeg "core:image/jpeg"
import as "../asset_manager"
import b "core:bytes"
import slc "core:slice"
import fmt "core:fmt"
import log "core:log"
import t "core:time"
import gl "vendor:OpenGL"



Image :: struct {
	url: as.URL,
	using image: im.Image,
	handle: u32 } // TODO: Add procedures to load the image to the GPU.

image_equiv :: proc(a: ^Image, b: ^Image) -> bool {
	return (a.url == b.url) &&
		(a.width == b.width) &&
		(a.channels == b.channels) &&
		(a.depth == b.depth) &&
		(a.background == b.background) &&
		(a.metadata == b.metadata) &&
		(a.which == b.which) }

import_or_retreive_image :: proc(database: ^as.Asset_Manager, url: as.URL, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
	entry: ^as.Entry
	ok: bool
	path: string
	modification_time: t.Time
	bytes: []u8

	entry, ok = as.entry_from_url(database, url)
	if ok do if as.entry_was_modified(database, entry) || database.spec_modified do ok = false
	if ok do image = image_deserialize(entry.data, allocator) or_return
	else {
		log.infof("Reading image %s from source.", url)
		path = as.url_search_source(database, url, allocator) or_return
		image = load_image_from_path(path, url, allocator) or_return
		modification_time = os.modification_time_by_path(path) or_return
		bytes = image_serialize(&image, allocator) or_return
		as.add_or_update_entry(database, as.make_entry(url, bytes, modification_time), true) or_return }
	return image, os.General_Error.None }

@(require_results)
image_serialize :: proc(image: ^Image, allocator: rt.Allocator) -> (bytes: []u8, err: os.Error) {
	buffer: b.Buffer
	n: int

	b.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	b.buffer_write_ptr(&buffer, image, size_of(image^)) or_return
	b.buffer_write_slice(&buffer, b.buffer_to_bytes(&image.pixels)) or_return
	return slc.clone(b.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@(require_results)
image_deserialize :: proc(bytes: []u8, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
	reader: b.Reader
	n: int

	b.reader_init(&reader, bytes)
	b.reader_read_ptr(&reader, &image, size_of(image)) or_return
	n = len(image.pixels.buf)
	image.pixels.buf = make_dynamic_array_len_cap([dynamic]u8, n, n, allocator) or_return
	b.reader_read_slice(&reader, image.pixels.buf[:]) or_return
	return image, os.General_Error.None }

@(require_results)
load_image_from_path :: proc(path: string, url: as.URL, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
	ext: string
	image_temp: ^im.Image
	image_err: im.Error
	loader_proc: im.Loader_Proc
	bytes: []u8

	log.infof("Loading image %v.", path)
	ext = os.ext(path)
	switch ext {
	case ".png": loader_proc = png.load_from_bytes
	case ".jpg", ".jpeg": loader_proc = jpeg.load_from_bytes
	case:
		log.errorf("Unrecognized image extension \"%s\".", ext)
		return {}, os.General_Error.Invalid_Path }
	bytes = os.read_entire_file(path, allocator) or_return
	image_temp, image_err = loader_proc(bytes, im.Options{}, allocator)
	if image_err != nil {
		log.errorf("Image error: %v.", image_err)
		return {}, os.General_Error.Not_Exist }
	image.image = image_temp^
	image.url = url
	free(image_temp)
	return image, os.General_Error.None }

upload_image :: proc(image: ^Image) -> bool {
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
	return true }

download_image :: proc(image: ^Image) {
	gl.DeleteTextures(1, &image.handle)
	image.handle = 0 }

image_loaded :: proc(image: ^Image) -> bool {
	return image.handle != 0 }
