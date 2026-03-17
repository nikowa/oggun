package tests
import rt "base:runtime"
import sl "core:slice"
import tst "core:testing"
import im "core:image"
import jpg "core:image/jpeg"
import log "core:log"
import sp "core:path/slashpath"
import str "core:strings"
import os "core:os"
import ref "core:reflect"
import b "core:bytes"
import fmt "core:fmt"
import ts "../container/two_stack"
import gx "../graphics"
import db "../database"
import mp "../container/micro_pair"
import scn "../scene"



@(test)
database_compression_test :: proc(t_context: ^tst.T) {
	img: ^im.Image; err: im.Error
	img, err = jpg.load_from_file("assets/test.jpg", allocator = context.temp_allocator)
	if ! tst.expect(t_context, err == nil) do return
	bytes: []u8 = img.pixels.buf[:]
	compressed_bytes: []u8 = db._compress_bytes(bytes, context.temp_allocator)
	decompressed_bytes: []u8 = db._decompress_bytes(compressed_bytes, context.temp_allocator)
	tst.expect(t_context, sl.equal(bytes, decompressed_bytes))
	free_all(context.temp_allocator) }

@(test)
database_test :: proc(t_context: ^tst.T) {
	err: os.Error
	img: ^im.Image
	img_err: im.Error
	entries: [2]^db.Entry

	// context.allocator = rt.panic_allocator()
	test_images := [2]string{ "assets/cardboard-tile-4.jpg", "assets/test.jpg" }
	database_0 := db.make_database({ "Test-Data.bin", "data", db.DEFAULT_AUTOSAVE_INTERVAL, db.DEFAULT_AUTOSAVE_CAP }, context.temp_allocator)
	db.remove_database(&database_0)
	defer db.delete_database(database_0, context.temp_allocator)
	for test_image, i in test_images {
		path := db.relpath_to_path(test_image, context.temp_allocator)
		log.infof("Loading %s.", path)
		img, img_err = jpg.load_from_file(path, allocator = context.temp_allocator)
		tst.expect(t_context, img_err == nil)
		bytes: []u8 = img.pixels.buf[:]
		url: db.URL = db.url_join({ "image", cast(db.URL)sp.name(test_image, true, context.temp_allocator) }, context.temp_allocator)
		entry := db.make_entry(url, bytes)
		entries[i], err = db.add_entry(&database_0, entry, true)
		tst.expect(t_context, err == nil) }
	entry_0, _ := db.entry_from_url(&database_0, "image:cardboard-tile-4")
	entry_1, _ := db.entry_from_url(&database_0, "image:test")
	tst.expect(t_context, entries[0] == entry_0)
	tst.expect(t_context, entries[1] == entry_1)
	db._write_without_compressing(&database_0, context.temp_allocator)
	database_1 := db._read_without_decompressing(database_0.config, context.temp_allocator)
	defer db.delete_database(database_1, context.temp_allocator)
	// ident ~ (write -> read)
	tst.expect(t_context, db.equiv(&database_0, &database_1))
	database_0_compressed := db.clone(&database_0, context.temp_allocator)
	defer db.delete_database(database_0_compressed, context.temp_allocator)
	db._compress(&database_0_compressed, context.temp_allocator)
	database_0_decompressed := db.clone(&database_0_compressed, context.temp_allocator)
	defer db.delete_database(database_0_decompressed, context.temp_allocator)
	db._decompress(&database_0_decompressed, context.temp_allocator)
	// ident ~ (compress -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_0_decompressed))
	db._write_without_compressing(&database_0_compressed, context.temp_allocator)
	database_1_decompressed := db.read_and_decompress(database_0.config, context.temp_allocator)
	defer db.delete_database(database_1_decompressed, context.temp_allocator)
	// ident ~ (compress -> write -> read -> decompress)
	tst.expect(t_context, db.equiv(&database_0, &database_1_decompressed))
	database_1_compressed := db._read_without_decompressing(database_0.config, context.temp_allocator)
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

@(test)
image_test :: proc(t_context: ^tst.T) {
	allocator: rt.Allocator
	image: gx.Image
	deserialized_image: gx.Image
	relpath: string
	path: string
	url: db.URL
	err: os.Error
	bytes: []u8

	allocator = context.temp_allocator

	// serialize/deserialize test //
	relpath = "data/dev-colors.png"
	url = "image:dev-colors"
	path = db.relpath_to_path(relpath, allocator)
	image, err = gx.load_image_from_path(path, url, allocator)
	tst.expect(t_context, err == nil)
	bytes, err = gx.image_serialize(&image, allocator)
	tst.expect(t_context, err == nil)
	deserialized_image, err = gx.image_deserialize(bytes, allocator)
	tst.expect(t_context, err == nil)
	tst.expect(t_context, gx.image_equiv(&image, &deserialized_image))
	tst.expect(t_context, b.equal(image.pixels.buf[:], deserialized_image.pixels.buf[:]))

	// database test //
	url = "image:dev-oriented-grid"
	database := db.make_database({ "Test-Data.bin", "data", db.DEFAULT_AUTOSAVE_INTERVAL, db.DEFAULT_AUTOSAVE_CAP }, context.temp_allocator)
	db.remove_database(&database)
	tst.expect(t_context, ! db.contains_entry(&database, url))
	image, err = gx.import_or_retreive_image(&database, url, context.temp_allocator)
	tst.expect(t_context, db.contains_entry(&database, url))
	tst.expect(t_context, err == nil)

	free_all(allocator) }

@(test)
micro_pair_test :: proc(t_context: ^tst.T) {
	micro_pair: ^mp.Micro_Pair

	context.user_ptr = mp.to_rawptr(mp.make_micro_pair())
	tst.expect(t_context, mp.is_empty(mp.from_rawptr(context.user_ptr)))
	context.user_ptr = mp.to_rawptr(mp.add_by_index(mp.from_rawptr(context.user_ptr), 0))
	context.user_ptr = mp.to_rawptr(mp.add_by_index(mp.from_rawptr(context.user_ptr), 1))
	tst.expect(t_context, ! mp.is_empty(mp.from_rawptr(context.user_ptr)))
	tst.expect(t_context, mp.from_rawptr(context.user_ptr)[0] == 0)
	tst.expect(t_context, mp.from_rawptr(context.user_ptr)[1] == 1) }

@(test)
model_test :: proc(t_context: ^tst.T) {
	allocator: rt.Allocator
	model: gx.Model
	deserialized_model: gx.Model
	relpath: string
	path: string
	url: db.URL
	err: os.Error
	bytes: []u8
	model_node: ^scn.Model_Node

	allocator = context.temp_allocator

	// serialize/deserialize test //
	relpath = "data/castle.glb"
	url = "model:castle"
	path = db.relpath_to_path(relpath, allocator)
	model, err = gx.load_model_from_path(path, url, allocator)
	tst.expect(t_context, err == nil)
	bytes, err = gx.model_serialize(&model, allocator)
	tst.expect(t_context, err == nil)
	deserialized_model, err = gx.model_deserialize(bytes, allocator)
	tst.expect(t_context, err == nil)
	tst.expect(t_context, gx.model_equiv(&model, &deserialized_model))

	// model node test //
	model_node = scn.make_model_node(scn.DEFAULT_NODE_CONFIG, &model, allocator)
	model_node.name = "castle"
	// scn.render_node(nil, model_node)

	free_all(allocator) }

@(test)
scene_test :: proc(t_context: ^tst.T) {
	allocator: rt.Allocator
	tree: scn.Tree
	node, other_node: ^scn.Node
	tree_iterator: scn.Tree_Iterator
	ok: bool

	allocator = context.temp_allocator
	N :: 4

	// attach root test //
	node = scn.make_node({ name = "root" }, allocator)
	tst.expect(t_context, node != nil)
	scn.tree_attach_root(&tree, node)
	tst.expect(t_context, tree.root == node)

	// attach child test //
	node = tree.root
	for i in 0 ..< N {
		other_node = scn.make_node({ name = fmt.tprintf("node-1-%d", i) }, allocator)
		tst.expect(t_context, other_node != nil)
		scn.node_attach_child(node, other_node)
		tst.expect(t_context, node.last_child == other_node) }

	// attach sibling test //
	node = scn.make_node({ name = "node-2-0" }, allocator)
	scn.node_attach_child(tree.root.first_child, node)
	for i in 1 ..< N + 1 {
		other_node = scn.make_node({ name = fmt.tprintf("node-2-%d", i) }, allocator)
		tst.expect(t_context, other_node != nil)
		scn.node_attach_sibling(node, other_node)
		tst.expect(t_context, node.parent.last_child == other_node) }

	// root iterator test //
	tree_iterator = scn.tree_iterator_root(&tree)
	node, ok = scn.tree_iterate_next(&tree_iterator)
	tst.expect(t_context, node.name == "root")
	for i in 0 ..< N {
		node, ok = scn.tree_iterate_next(&tree_iterator)
		tst.expect(t_context, node.name == fmt.tprintf("node-1-%d", i)) }
	for i in 0 ..< N + 1 {
		node, ok = scn.tree_iterate_next(&tree_iterator)
		tst.expect(t_context, node.name == fmt.tprintf("node-2-%d", i)) }

	// node iterator test //
	tree_iterator = scn.tree_iterator_node(tree.root.first_child.first_child)
	for i in 0 ..< N + 1 {
		node, ok = scn.tree_iterate_next(&tree_iterator)
		tst.expect(t_context, node.name == fmt.tprintf("node-2-%d", i)) }

	// sibling iterator test //
	tree_iterator = scn.tree_iterator_root(&tree)
	node, ok = scn.tree_iterate_next(&tree_iterator)
	tst.expect(t_context, node.name == "root")
	for i in 0 ..< N {
		node, ok = scn.tree_iterate_next_sibling(&tree_iterator)
		tst.expect(t_context, node.name == fmt.tprintf("node-1-%d", i)) }
	node, ok = scn.tree_iterate_next_sibling(&tree_iterator)
	tst.expect(t_context, ! ok)

	// search by name test //
	tst.expect(t_context, scn.tree_search_by_name(&tree, "root").name == "root")
	tst.expect(t_context, scn.tree_search_by_name(&tree, "node-2-3").name == "node-2-3")

	// search by proc test //
	condition_proc :: proc(node: ^scn.Node, name: string) -> bool {
		if node.parent == nil do return false
		return node.parent.name == name }
	tst.expect(t_context, scn.tree_search_by_proc(&tree, condition_proc, "root").parent.name == "root")
	tst.expect(t_context, scn.tree_search_by_proc(&tree, condition_proc, "node-1-0").parent.name == "node-1-0")

	free_all(allocator) }
