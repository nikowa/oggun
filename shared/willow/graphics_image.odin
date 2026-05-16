#+feature using-stmt
package willow
import "base:runtime"
import "core:os"
import "core:image"
import "core:image/png"
import "core:image/jpeg"
import "core:bytes"
import "core:slice"
import "core:log"
import "core:time"
import gl "vendor:OpenGL"

Image_Asset :: struct {
	using asset: Asset,
	using image: image.Image,
	modification_time: time.Time,
	gpu_modification_time: time.Time,
	handle: u32 } // TODO: Add procedures to load the image to the GPU.

image_equiv :: proc(a: ^Image_Asset, b: ^Image_Asset) -> bool {
	return (a.url == b.url) &&
		(a.width == b.width) &&
		(a.channels == b.channels) &&
		(a.depth == b.depth) &&
		(a.background == b.background) &&
		(a.metadata == b.metadata) &&
		(a.which == b.which) }

init_image :: proc(asset_manager: ^Asset_Manager, image: ^Image_Asset, config: Asset_Config) {
	config := config
	config.derived_type = Image_Asset
	init_asset(asset_manager, Image_Asset, &image.asset, config) }

image_modification_time :: proc(asset_manager: ^Asset_Manager, image: ^Image_Asset, location: Asset_Location_Field) -> (modification_time: time.Time) {
	switch location {
	case .Source_Directory:
		path := path_from_url(asset_manager, image.url, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database_File:
		path := relpath_to_path(asset_manager.relpath, context.temp_allocator)
		modification_time, _ := os.modification_time_by_path(path)
		return modification_time
	case .Database:
		entry := get_entry(asset_manager, image.url)
		return (entry != nil) ? entry.modification_time : {}
	case .Main_Memory:
		return image.modification_time
	case .GPU_Memory:
		return image.gpu_modification_time }
	return {} }

@private
image_asset_command :: proc(asset_manager: ^Asset_Manager, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	img := asset_object(asset, Image_Asset, "asset")
	switch command {
	case .Validate:
	case .Query_Location:
		path := path_from_url(asset_manager, asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
	case .Import:
		err: os.Error
		path := path_from_url(asset_manager, img.url, context.allocator)
		modification_time, _ := os.modification_time_by_path(path)
		if time.diff(img.modification_time, modification_time) <= 0 do return true
		loader_proc: image.Loader_Proc
		switch ext := os.ext(path); ext {
		case ".png": loader_proc = png.load_from_bytes
		case ".jpg", ".jpeg": loader_proc = jpeg.load_from_bytes
		case: log.errorf("Unrecognized image extension \"%s\".", ext); return false }
		bytes: []u8
		if bytes, err = os.read_entire_file(path, context.allocator); err != nil {
			return false }
		image_temp, image_err := loader_proc(bytes, image.Options{}, context.allocator)
		if image_err != nil {
			log.errorf("Image error: %v.", image_err); return false }
		img.image = image_temp^
		free(image_temp)
		bytes, _ = image_serialize(img, context.allocator)
		add_or_update_entry(asset_manager, make_entry(img.url, bytes, modification_time))
		asset.location += { .Database, .Main_Memory }
		img.modification_time = modification_time
		return true
	case .Export:
	case .Load:
	// DICK
		return image_asset_command(asset_manager, asset, .Import, watch)
	case .Save:
	case .Upload:
		if img.handle != 0 do download_image(img)
		gl.GenTextures(1, &img.handle)
		gl.BindTexture(gl.TEXTURE_2D, img.handle)
		internal_format: i32
		data_format: u32
		data_format_type: u32
		switch img.channels {
		case 1:
			switch img.depth {
			case 8:
				internal_format = gl.R8
				data_format = gl.RED
			case:
				log.errorf("Unsupported data format for texture %s.", img.url)
				return false }
		case 3:
			switch img.depth {
			case 8:
				internal_format = gl.RGB8
				data_format = gl.RGB
			case:
				log.errorf("Unsupported data format for texture %s.", img.url)
				return false }
		case 4:
			switch img.depth {
			case 8:
				internal_format = gl.RGBA8
				data_format = gl.RGBA
			case:
				log.errorf("Unsupported internal format for texture %s.", img.url)
				return false }
		case:
			log.errorf("Unsupported channel count for texture %s.", img.url)
			return false }
		data_format_type = gl.UNSIGNED_BYTE
		gl.TexImage2D(gl.TEXTURE_2D, 0, internal_format, cast(i32)img.width, cast(i32)img.height, 0, data_format, data_format_type, &img.pixels.buf[0])
		texture_wrapping(gl.REPEAT)
		texture_filtering(gl.NEAREST)
		// DICK
		img.gpu_modification_time = img.modification_time
		asset.location += { .GPU_Memory }
		return true
	case .Download: }
	return false }

// import_or_retreive_image :: proc(database: ^Asset_Manager, url: URL, allocator: runtime.Allocator) -> (image: Image_Asset, err: os.Error) {
// 	entry: ^Entry
// 	ok: bool
// 	path: string
// 	modification_time: t.Time
// 	bytes: []u8

// 	entry, ok = get_entry(database, url)
// 	if ok do if entry_was_modified(database, entry) || database.spec_modified do ok = false
// 	if ok do image = image_deserialize(entry.data, allocator) or_return
// 	else {
// 		log.infof("Reading image %s from source.", url)
// 		path = url_search_source(database, url, allocator) or_return
// 		image = load_image_from_path(path, url, allocator) or_return
// 		modification_time = os.modification_time_by_path(path) or_return
// 		bytes = image_serialize(&image, allocator) or_return
// 		add_or_update_entry(database, make_entry(url, bytes, modification_time), true) or_return }
// 	return image, os.General_Error.None }

@(require_results)
image_serialize :: proc(image: ^Image_Asset, allocator: runtime.Allocator) -> (image_bytes: []u8, err: os.Error) {
	buffer: bytes.Buffer
	n: int

	bytes.buffer_init_allocator(&buffer, 0, 100_000, context.temp_allocator)
	bytes.buffer_write_ptr(&buffer, image, size_of(image^)) or_return
	bytes.buffer_write_slice(&buffer, bytes.buffer_to_bytes(&image.pixels)) or_return
	return slice.clone(bytes.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

@(require_results)
image_deserialize :: proc(image_bytes: []u8, allocator: runtime.Allocator) -> (image: Image_Asset, err: os.Error) {
	reader: bytes.Reader
	n: int

	bytes.reader_init(&reader, image_bytes)
	bytes.reader_read_ptr(&reader, &image, size_of(image)) or_return
	n = len(image.pixels.buf)
	image.pixels.buf = make_dynamic_array_len_cap([dynamic]u8, n, n, allocator) or_return
	bytes.reader_read_slice(&reader, image.pixels.buf[:]) or_return
	return image, os.General_Error.None }

download_image :: proc(image: ^Image_Asset) {
	gl.DeleteTextures(1, &image.handle)
	image.handle = 0 }

image_loaded :: proc(image: ^Image_Asset) -> bool {
	return image.handle != 0 }
