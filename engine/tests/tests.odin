package tests
import sl "core:slice"
import tst "core:testing"
import im "core:image"
import jpg "core:image/jpeg"
import db "../database"
import log "core:log"
import sp "core:path/slashpath"
import str "core:strings"



@(test)
database_compression_test :: proc(t_context: ^tst.T) {
	img: ^im.Image; err: im.Error
	img, err = jpg.load_from_file("assets/test.jpg", allocator = context.temp_allocator)
	if ! tst.expect(t_context, err == nil) do return
	bytes: []u8 = img.pixels.buf[:]
	compressed_bytes: []u8 = db.compress_bytes(bytes, allocator = context.temp_allocator)
	decompressed_bytes: []u8 = db.decompress_bytes(compressed_bytes, allocator = context.temp_allocator)
	tst.expect(t_context, sl.equal(bytes, decompressed_bytes))
	free_all(allocator = context.temp_allocator) }

@(test)
database_test :: proc(t_context: ^tst.T) {
	test_images := [2]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
	entries: [2]^db.Entry
	database_0 := db.make_database("Data.bin", allocator = context.temp_allocator)
	for test_image, i in test_images {
		img: ^im.Image; err: im.Error
		path := db.relpath_to_path(test_image, context.temp_allocator)
		log.infof("Loading %s.", path)
		img, err = jpg.load_from_file(path, allocator = context.temp_allocator)
		log.info(err)
		assert(err == nil)
		bytes: []u8 = img.pixels.buf[:]
		url: string = db.url_join({ "image", sp.name(test_image, true, allocator = context.temp_allocator) }, allocator = context.temp_allocator)
		entry := db.make_entry(url, bytes)
		entries[i] = db.add_entry(&database_0, entry) }
	entry_0, _ := db.entry_from_url(&database_0, "image:cardboard-tile-4")
	entry_1, _ := db.entry_from_url(&database_0, "image:test")
	tst.expect(t_context, entries[0] == entry_0)
	tst.expect(t_context, entries[1] == entry_1)
	db.write(&database_0, context.temp_allocator)
	database_1 := db.read(database_0.relpath, context.temp_allocator)
	// ident ~ (write -> read)
	tst.expect(t_context, db.equiv(&database_0, &database_1))
	database_0_compressed := db.clone(&database_0)
	db.compress(&database_0_compressed)
	database_0_decompressed := db.clone(&database_0_compressed)
	db.decompress(&database_0_decompressed, context.temp_allocator)
	// ident ~ (compress -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_0_decompressed))
	db.write(&database_0_compressed, context.temp_allocator)
	database_1_decompressed := db.read_and_decompress(database_0.relpath, context.temp_allocator)
	// ident ~ (compress -> write -> read -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_1_decompressed))
	database_1_compressed := db.read(database_0.relpath, context.temp_allocator)
	// compress ~ (compress -> write -> read)
	tst.expect(t_context, db.equiv(&database_0_compressed, &database_1_compressed))
	free_all(context.temp_allocator) }
