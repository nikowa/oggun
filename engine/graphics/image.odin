#+feature using-stmt
package graphics
import rt "base:runtime"
import os "core:os"
import im "core:image"
import png "core:image/png"
import jpeg "core:image/jpeg"
import db "../database"
import b "core:bytes"
import slc "core:slice"
import fmt "core:fmt"
import log "core:log"



Image :: struct {
	url: db.URL,
	using image: im.Image }

image_equal :: proc(a: ^Image, b: ^Image) -> bool {
	return (a.url == b.url) &&
		(a.width == b.width) &&
		(a.channels == b.channels) &&
		(a.depth == b.depth) &&
		(a.background == b.background) &&
		(a.metadata == b.metadata) &&
		(a.which == b.which) }

// Get an image from the database by URL. If no such image exists, load it from file and add to the database. //
import_or_retreive_image :: proc(database: ^db.Database, url: db.URL, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
	entry: ^db.Entry
	ok: bool
	path: string

	entry, ok = db.entry_from_url(database, url)
	if ok do image = deserialize(entry.data, allocator) or_return
	else {
		path = db.url_search_source(database, url, allocator) or_return
		image = load_from_path(path, url, allocator) or_return }
	return image, os.General_Error.None }

@(require_results)
serialize :: proc(image: ^Image, allocator: rt.Allocator) -> (bytes: []u8, err: os.Error) {
	buffer: b.Buffer
	n: int

	b.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	b.buffer_write_ptr(&buffer, image, size_of(image^)) or_return
	b.buffer_write_slice(&buffer, b.buffer_to_bytes(&image.pixels)) or_return
	return slc.clone(b.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@(require_results)
deserialize :: proc(bytes: []u8, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
	reader: b.Reader
	n: int

	b.reader_init(&reader, bytes)
	b.reader_read_ptr(&reader, &image, size_of(image)) or_return
	n = len(image.pixels.buf)
	image.pixels.buf = make_dynamic_array_len_cap([dynamic]u8, n, n, allocator) or_return
	b.reader_read_slice(&reader, image.pixels.buf[:]) or_return
	return image, os.General_Error.None }

@(require_results)
load_from_path :: proc(path: string, url: db.URL, allocator: rt.Allocator) -> (image: Image, err: os.Error) {
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
