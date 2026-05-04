#+feature using-stmt
package graphics
import rt "base:runtime"
import os "core:os"
import im "core:image"
import png "core:image/png"
import jpeg "core:image/jpeg"
import as "../asset_sys"
import b "core:bytes"
import slc "core:slice"
import fmt "core:fmt"
import log "core:log"
import tm "core:time"
import gl "vendor:OpenGL"



Image_Asset :: struct {
	using asset: as.Asset,
	using image: im.Image,
	modification_time: tm.Time,
	gpu_modification_time: tm.Time,
	handle: u32 } // TODO: Add procedures to load the image to the GPU.

image_equiv :: proc(a: ^Image_Asset, b: ^Image_Asset) -> bool {
	return (a.url == b.url) &&
		(a.width == b.width) &&
		(a.channels == b.channels) &&
		(a.depth == b.depth) &&
		(a.background == b.background) &&
		(a.metadata == b.metadata) &&
		(a.which == b.which) }

init_image :: proc(as_mngr: ^as.Asset_Manager, image: ^Image_Asset, config: as.Asset_Config) {
	config := config
	config.derived_type = Image_Asset
	as.init_asset(as_mngr, &image.asset, config) }

image_modification_time :: proc(as_mngr: ^as.Asset_Manager, image: ^Image_Asset, location: as.Asset_Location_Field) -> (modification_time: tm.Time) {
	switch location {
	case .Source_Directory:
		path := as.path_from_url(&as_mngr.database, image.url, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database_File:
		path := as.relpath_to_path(as_mngr.database.relpath, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database:
		entry, ok := as.get_entry(&as_mngr.database, image.url)
		return ok ? entry.modification_time : {}
	case .Main_Memory:
		return image.modification_time
	case .GPU_Memory:
		return image.gpu_modification_time }
	return {} }

@private
image_asset_command :: proc(as_mngr: ^as.Asset_Manager, asset: ^as.Asset, command: as.Asset_Command, watch: bool = false) -> (ok: bool) {
	image := as.asset_object(asset, Image_Asset, "asset")
	switch command {
	case .Validate:
	case .Query_Location:
		path := as.path_from_url(&as_mngr.database, asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
	case .Import:
		path: string
		err: os.Error
		if path, err = as.url_search_source(as_mngr, image.url, context.allocator); err != nil {
			log.errorf("Could not find source for image \"%s\".", image.url); return false }
		modification_time, _ := os.modification_time_by_path(path)
		if tm.diff(image.modification_time, modification_time) <= 0 do return true
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
		as.add_or_update_entry(as_mngr, as.make_entry(image.url, bytes, modification_time), true)
		asset.location += { .Database, .Main_Memory }
		image.modification_time = modification_time
		return true
	case .Export:
	case .Load:
	// DICK
		return image_asset_command(as_mngr, asset, .Import, watch)
	case .Save:
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
		// DICK
		image.gpu_modification_time = image.modification_time
		asset.location += { .GPU_Memory }
		return true
	case .Download: }
	return false }

// import_or_retreive_image :: proc(database: ^as.Asset_Manager, url: as.URL, allocator: rt.Allocator) -> (image: Image_Asset, err: os.Error) {
// 	entry: ^as.Entry
// 	ok: bool
// 	path: string
// 	modification_time: t.Time
// 	bytes: []u8

// 	entry, ok = as.get_entry(database, url)
// 	if ok do if as.entry_was_modified(database, entry) || database.spec_modified do ok = false
// 	if ok do image = image_deserialize(entry.data, allocator) or_return
// 	else {
// 		log.infof("Reading image %s from source.", url)
// 		path = as.url_search_source(database, url, allocator) or_return
// 		image = load_image_from_path(path, url, allocator) or_return
// 		modification_time = os.modification_time_by_path(path) or_return
// 		bytes = image_serialize(&image, allocator) or_return
// 		as.add_or_update_entry(database, as.make_entry(url, bytes, modification_time), true) or_return }
// 	return image, os.General_Error.None }

@(require_results)
image_serialize :: proc(image: ^Image_Asset, allocator: rt.Allocator) -> (bytes: []u8, err: os.Error) {
	buffer: b.Buffer
	n: int

	b.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	b.buffer_write_ptr(&buffer, image, size_of(image^)) or_return
	b.buffer_write_slice(&buffer, b.buffer_to_bytes(&image.pixels)) or_return
	return slc.clone(b.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@(require_results)
image_deserialize :: proc(bytes: []u8, allocator: rt.Allocator) -> (image: Image_Asset, err: os.Error) {
	reader: b.Reader
	n: int

	b.reader_init(&reader, bytes)
	b.reader_read_ptr(&reader, &image, size_of(image)) or_return
	n = len(image.pixels.buf)
	image.pixels.buf = make_dynamic_array_len_cap([dynamic]u8, n, n, allocator) or_return
	b.reader_read_slice(&reader, image.pixels.buf[:]) or_return
	return image, os.General_Error.None }

download_image :: proc(image: ^Image_Asset) {
	gl.DeleteTextures(1, &image.handle)
	image.handle = 0 }

image_loaded :: proc(image: ^Image_Asset) -> bool {
	return image.handle != 0 }
