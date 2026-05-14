package test_asset
import "shared:willow"
import "core:testing"
import "core:image"
import "core:image/jpeg"
import "core:slice"

@(test)
asset_test :: proc(t_context: ^testing.T) {
	context.allocator = rt.panic_allocator()

	// test compression and decompression //
	img: ^image.Image; img_error: image.Error
	img, img_error = jpeg.load_from_file("assets/test.jpg", allocator = context.temp_allocator)
	if ! testing.expect(t_context, img_error == nil) do return
	bytes: []u8 = img.pixels.buf[:]
	compressed_bytes: []u8 = willow._compress_bytes(bytes, context.temp_allocator)
	decompressed_bytes: []u8 = willow._decompress_bytes(compressed_bytes, context.temp_allocator)
	testing.expect(t_context, slice.equal(bytes, decompressed_bytes))

// 	entries: [2]^as.Entry

// 	test_images := [2]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
// 	database_0 := as.make_database({ "Test-Data.bin", "data", as.DEFAULT_AUTOSAVE_INTERVAL, as.DEFAULT_AUTOSAVE_CAP }, context.temp_allocator)
// 	as.remove_database(&database_0)
// 	defer as.delete_database(database_0, context.temp_allocator)
// 	for test_image, i in test_images {
// 		path := as.relpath_to_path(test_image, context.temp_allocator)
// 		log.infof("Loading %s.", path)
// 		img, img_error = jpeg.load_from_file(path, allocator = context.temp_allocator)
// 		testing.expect(t_context, img_error == nil)
// 		bytes: []u8 = img.pixels.buf[:]
// 		url: as.URL = as.url_join({ "image", cast(as.URL)sp.name(test_image, true, context.temp_allocator) }, context.temp_allocator)
// 		entry := as.make_entry(url, bytes)
// 		entries[i], err = as.add_entry(&database_0, entry, true)
// 		testing.expect(t_context, err == nil) }
// 	entry_0, _ := as.get_entry(&database_0, "image:cardboard-tile-4")
// 	entry_1, _ := as.get_entry(&database_0, "image:test")
// 	testing.expect(t_context, entries[0] == entry_0)
// 	testing.expect(t_context, entries[1] == entry_1)
// 	as._write_without_compressing(&database_0, context.temp_allocator)
// 	database_1 := as._read_without_decompressing(database_0.config, context.temp_allocator)
// 	defer as.delete_database(database_1, context.temp_allocator)
// 	// ident ~ (write -> read)
// 	testing.expect(t_context, as.equiv(&database_0, &database_1))
// 	database_0_compressed := as.clone(&database_0, context.temp_allocator)
// 	defer as.delete_database(database_0_compressed, context.temp_allocator)
// 	as._compress(&database_0_compressed, context.temp_allocator)
// 	database_0_decompressed := as.clone(&database_0_compressed, context.temp_allocator)
// 	defer as.delete_database(database_0_decompressed, context.temp_allocator)
// 	as._decompress(&database_0_decompressed, context.temp_allocator)
// 	// ident ~ (compress -> decompress)
// 	testing.expect(t_context, as.equiv(&database_0, &database_0_decompressed))
// 	as._write_without_compressing(&database_0_compressed, context.temp_allocator)
// 	database_1_decompressed := as.read_and_decompress(database_0.config, context.temp_allocator)
// 	defer as.delete_database(database_1_decompressed, context.temp_allocator)
// 	// ident ~ (compress -> write -> read -> decompress)
// 	testing.expect(t_context, as.equiv(&database_0, &database_1_decompressed))
// 	database_1_compressed := as._read_without_decompressing(database_0.config, context.temp_allocator)
// 	defer as.delete_database(database_1_compressed, context.temp_allocator)
// 	// compress ~ (compress -> write -> read)
// 	testing.expect(t_context, as.equiv(&database_0_compressed, &database_1_compressed))

	free_all(context.temp_allocator) }
