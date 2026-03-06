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
	test_images := [?]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
	database_0 := db.make_database("Data.bin", allocator = context.temp_allocator)
	for test_image in test_images {
		img: ^im.Image; err: im.Error
		path := db.relpath_to_path(test_image, context.temp_allocator)
		log.infof("Loading %s.", path)
		img, err = jpg.load_from_file(path, allocator = context.temp_allocator)
		log.info(err)
		assert(err == nil)
		bytes: []u8 = img.pixels.buf[:]
		url: string = db.url_join({ "image", sp.name(test_image, true, allocator = context.temp_allocator) }, allocator = context.temp_allocator)
		entry := db.make_entry(url, bytes)
		append(&database_0.entries, entry) }
	database_0_compressed := db.clone(&database_0)
	db.write(&database_0, context.temp_allocator)
	database_1 := db.read(database_0.relpath, context.temp_allocator)
	tst.expect(t_context, db.equiv(&database_0, &database_1))
	db.compress_and_write(&database_0_compressed, context.temp_allocator)
	database_1_decompressed := db.read_and_decompress(database_0.relpath, context.temp_allocator)
	tst.expect(t_context, db.equiv(&database_0, &database_1_decompressed))
	database_1_compressed := db.read(database_0.relpath, context.temp_allocator)
	tst.expect(t_context, db.equiv(&database_0_compressed, &database_1_compressed))
	free_all(context.temp_allocator) }
