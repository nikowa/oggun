package tests
import rt "base:runtime"
import sl "core:slice"
import tst "core:testing"
import im "core:image"
import jpg "core:image/jpeg"
import db "../database"
import log "core:log"
import sp "core:path/slashpath"
import str "core:strings"
import ts "../container/two_stack"



@(test)
database_compression_test :: proc(t_context: ^tst.T) {
	img: ^im.Image; err: im.Error
	img, err = jpg.load_from_file("assets/test.jpg", allocator = context.temp_allocator)
	if ! tst.expect(t_context, err == nil) do return
	bytes: []u8 = img.pixels.buf[:]
	compressed_bytes: []u8 = db.compress_bytes(bytes, context.temp_allocator)
	decompressed_bytes: []u8 = db.decompress_bytes(compressed_bytes, context.temp_allocator)
	tst.expect(t_context, sl.equal(bytes, decompressed_bytes))
	free_all(context.temp_allocator) }

@(test)
database_test :: proc(t_context: ^tst.T) {
	// context.allocator = rt.panic_allocator()
	test_images := [2]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
	entries: [2]^db.Entry
	database_0 := db.make_database({ "Test-Data.bin", "data" }, context.temp_allocator)
	defer db.delete_database(database_0, context.temp_allocator)
	for test_image, i in test_images {
		img: ^im.Image; err: im.Error
		path := db.relpath_to_path(test_image, context.temp_allocator)
		log.infof("Loading %s.", path)
		img, err = jpg.load_from_file(path, allocator = context.temp_allocator)
		log.info(err)
		assert(err == nil)
		bytes: []u8 = img.pixels.buf[:]
		url: db.URL = db.url_join({ "image", cast(db.URL)sp.name(test_image, true, context.temp_allocator) }, context.temp_allocator)
		entry := db.make_entry(url, bytes)
		entries[i] = db.add_entry(&database_0, entry) }
	entry_0, _ := db.entry_from_url(&database_0, "image:cardboard-tile-4")
	entry_1, _ := db.entry_from_url(&database_0, "image:test")
	tst.expect(t_context, entries[0] == entry_0)
	tst.expect(t_context, entries[1] == entry_1)
	db.write_without_compressing(&database_0, context.temp_allocator)
	database_1 := db.read_without_decompressing(database_0.relpath, context.temp_allocator)
	defer db.delete_database(database_1, context.temp_allocator)
	// ident ~ (write -> read)
	tst.expect(t_context, db.equiv(&database_0, &database_1))
	database_0_compressed := db.clone(&database_0, context.temp_allocator)
	defer db.delete_database(database_0_compressed, context.temp_allocator)
	db.compress(&database_0_compressed, context.temp_allocator)
	database_0_decompressed := db.clone(&database_0_compressed, context.temp_allocator)
	defer db.delete_database(database_0_decompressed, context.temp_allocator)
	db.decompress(&database_0_decompressed, context.temp_allocator)
	// ident ~ (compress -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_0_decompressed))
	db.write_without_compressing(&database_0_compressed, context.temp_allocator)
	database_1_decompressed := db.read_and_decompress(database_0.relpath, context.temp_allocator)
	defer db.delete_database(database_1_decompressed, context.temp_allocator)
	// ident ~ (compress -> write -> read -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_1_decompressed))
	database_1_compressed := db.read_without_decompressing(database_0.relpath, context.temp_allocator)
	defer db.delete_database(database_1_compressed, context.temp_allocator)
	// compress ~ (compress -> write -> read)
	tst.expect(t_context, db.equiv(&database_0_compressed, &database_1_compressed))
	free_all(context.temp_allocator) }

@(test)
two_stack_test :: proc(t_context: ^tst.T) {
	stack: ts.Two_Stack(int)
	ts.init(&stack)
	// ()
	tst.expect(t_context, ts.len(&stack) == 0)
	tst.expect(t_context, ts.push(&stack, 1))
	// (1)
	tst.expect(t_context, ts.len(&stack) == 1)
	elem, ok := ts.peek(&stack)
	tst.expect(t_context, ok && (elem == 1))
	elem, ok = ts.peek_bottom(&stack)
	tst.expect(t_context, ok && (elem == 1))
	tst.expect(t_context, ts.push(&stack, 2))
	// (1, 2)
	tst.expect(t_context, ts.len(&stack) == 2)
	elem, ok = ts.peek_bottom(&stack)
	tst.expect(t_context, ok && (elem == 1))
	elem, ok = ts.peek(&stack)
	tst.expect(t_context, ok && (elem == 2))
	tst.expect(t_context, ! ts.push(&stack, 3))
	elem, ok = ts.pop_bottom(&stack)
	// (2)
	tst.expect(t_context, ts.len(&stack) == 1)
	tst.expect(t_context, ok && (elem == 1))
	elem, ok = ts.peek(&stack)
	tst.expect(t_context, ok && (elem == 2))
	tst.expect(t_context, ts.push_bottom(&stack, 1))
	// (1, 2)
	tst.expect(t_context, ts.len(&stack) == 2)
	elem, ok = ts.peek(&stack)
	tst.expect(t_context, ok && (elem == 2))
	elem, ok = ts.peek_bottom(&stack)
	tst.expect(t_context, ok && (elem == 1))
	elem, ok = ts.pop(&stack)
	// (1)
	tst.expect(t_context, ts.len(&stack) == 1)
	elem, ok = ts.peek(&stack)
	tst.expect(t_context, ok && (elem == 1))
	elem, ok = ts.pop(&stack)
	// ()
	tst.expect(t_context, ts.len(&stack) == 0)
	elem, ok = ts.peek(&stack)
	tst.expect(t_context, ! ok && (elem == {}))
	elem, ok = ts.pop(&stack)
	tst.expect(t_context, ! ok && (elem == {})) }
