package test_asset
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:image"
import "core:image/jpeg"
import "core:slice"
import "core:log"
import "core:os"
import "core:mem"

@(test)
asset_test :: proc(t_context: ^testing.T) {
	context.allocator = runtime.panic_allocator()

	// test compression and decompression //
	img: ^image.Image; img_error: image.Error
	img, img_error = jpeg.load_from_file("assets/test.jpg", allocator = context.temp_allocator)
	if ! testing.expect(t_context, img_error == nil) do return
	bytes: []u8 = img.pixels.buf[:]
	compressed_bytes: []u8 = og.compress(bytes, context.temp_allocator)
	decompressed_bytes: []u8 = og.decompress(compressed_bytes, context.temp_allocator)
	testing.expect(t_context, slice.equal(bytes, decompressed_bytes))

	// test entry adding //
	err: os.Error
	entries: [2]^og.Entry
	urls: [2]og.URL
	test_images := [2]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
	database_0 := og.make_database({ "Test-Data.bin", "data", og.DEFAULT_AUTOSAVE_INTERVAL, og.DEFAULT_AUTOSAVE_CAP }, context.temp_allocator)
	og.remove_database(&database_0)
	for test_image, i in test_images {
		path := og.relpath_to_path(test_image, context.temp_allocator)
		log.infof("Loading %s.", path)
		img, img_error = jpeg.load_from_file(path, allocator = context.temp_allocator)
		testing.expect(t_context, img_error == nil)
		bytes: []u8 = img.pixels.buf[:]
		_, filename := os.split_path(test_image)
		urls[i] = og.url_join({ "image", cast(og.URL)filename }, context.temp_allocator)
		entry := og.make_entry(urls[i], bytes)
		entries[i] = og.add_entry(&database_0, entry)
		testing.expect(t_context, entries[i] != nil) }
	for url, i in urls {
		testing.expect(t_context, og.contains_entry(&database_0, url))
		entry := og.get_entry(&database_0, url)
		testing.expect(t_context, entry != nil)
		testing.expect(t_context, entry == entries[i]) }

// 	og._write_without_compressing(&database_0, context.temp_allocator)
// 	database_1 := og._read_without_decompressing(database_0.config, context.temp_allocator)
// 	defer og.delete_database(database_1, context.temp_allocator)
// 	// ident ~ (write -> read)
// 	testing.expect(t_context, og.equiv(&database_0, &database_1))
// 	database_0_compressed := og.clone(&database_0, context.temp_allocator)
// 	defer og.delete_database(database_0_compressed, context.temp_allocator)
// 	og._compress(&database_0_compressed, context.temp_allocator)
// 	database_0_decompressed := og.clone(&database_0_compressed, context.temp_allocator)
// 	defer og.delete_database(database_0_decompressed, context.temp_allocator)
// 	og._decompress(&database_0_decompressed, context.temp_allocator)
// 	// ident ~ (compress -> decompress)
// 	testing.expect(t_context, og.equiv(&database_0, &database_0_decompressed))
// 	og._write_without_compressing(&database_0_compressed, context.temp_allocator)
// 	database_1_decompressed := og.read_and_decompress(database_0.config, context.temp_allocator)
// 	defer og.delete_database(database_1_decompressed, context.temp_allocator)
// 	// ident ~ (compress -> write -> read -> decompress)
// 	testing.expect(t_context, og.equiv(&database_0, &database_1_decompressed))
// 	database_1_compressed := og._read_without_decompressing(database_0.config, context.temp_allocator)
// 	defer og.delete_database(database_1_compressed, context.temp_allocator)
// 	// compress ~ (compress -> write -> read)
// 	testing.expect(t_context, og.equiv(&database_0_compressed, &database_1_compressed))

	free_all(context.temp_allocator) }
