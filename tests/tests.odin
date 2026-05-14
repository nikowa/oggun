package tests

@require import "asset"
// import rt "base:runtime"
// import sl "core:slice"
// import tst "core:testing"
// import im "core:image"
// import jpg "core:image/jpeg"
// import log "core:log"
// import sp "core:path/slashpath"
// import str "core:strings"
// import os "core:os"
// import ref "core:reflect"
// import b "core:bytes"
// import fmt "core:fmt"
// import ts "../container/two_stack"
// import gx "../graphics"
// import as "../asset_manager"
// import mp "../container/micro_pair"
// import scn "../scene"

// @(test)
// two_stack_test :: proc(t_context: ^tst.T) {
// 	stack: ts.Two_Stack(int)
// 	ts.init(&stack)
// 	// ()
// 	tst.expect(t_context, ts.len(&stack) == 0)
// 	tst.expect(t_context, ts.push(&stack, 1))
// 	// (1)
// 	tst.expect(t_context, ts.len(&stack) == 1)
// 	elem, ok := ts.peek(&stack)
// 	tst.expect(t_context, ok && (elem == 1))
// 	elem, ok = ts.peek_bottom(&stack)
// 	tst.expect(t_context, ok && (elem == 1))
// 	tst.expect(t_context, ts.push(&stack, 2))
// 	// (1, 2)
// 	tst.expect(t_context, ts.len(&stack) == 2)
// 	elem, ok = ts.peek_bottom(&stack)
// 	tst.expect(t_context, ok && (elem == 1))
// 	elem, ok = ts.peek(&stack)
// 	tst.expect(t_context, ok && (elem == 2))
// 	tst.expect(t_context, ! ts.push(&stack, 3))
// 	elem, ok = ts.pop_bottom(&stack)
// 	// (2)
// 	tst.expect(t_context, ts.len(&stack) == 1)
// 	tst.expect(t_context, ok && (elem == 1))
// 	elem, ok = ts.peek(&stack)
// 	tst.expect(t_context, ok && (elem == 2))
// 	tst.expect(t_context, ts.push_bottom(&stack, 1))
// 	// (1, 2)
// 	tst.expect(t_context, ts.len(&stack) == 2)
// 	elem, ok = ts.peek(&stack)
// 	tst.expect(t_context, ok && (elem == 2))
// 	elem, ok = ts.peek_bottom(&stack)
// 	tst.expect(t_context, ok && (elem == 1))
// 	elem, ok = ts.pop(&stack)
// 	// (1)
// 	tst.expect(t_context, ts.len(&stack) == 1)
// 	elem, ok = ts.peek(&stack)
// 	tst.expect(t_context, ok && (elem == 1))
// 	elem, ok = ts.pop(&stack)
// 	// ()
// 	tst.expect(t_context, ts.len(&stack) == 0)
// 	elem, ok = ts.peek(&stack)
// 	tst.expect(t_context, ! ok && (elem == {}))
// 	elem, ok = ts.pop(&stack)
// 	tst.expect(t_context, ! ok && (elem == {})) }

// @(test)
// image_test :: proc(t_context: ^tst.T) {
// 	allocator: rt.Allocator
// 	image: gx.Image_Asset
// 	deserialized_image: gx.Image_Asset
// 	relpath: string
// 	path: string
// 	url: as.URL
// 	err: os.Error
// 	bytes: []u8

// 	allocator = context.temp_allocator

// 	// serialize/deserialize test //
// 	relpath = "data/dev-colors.png"
// 	url = "image:dev-colors"
// 	path = as.relpath_to_path(relpath, allocator)
// 	image, err = gx.load_image_from_path(path, url, allocator)
// 	tst.expect(t_context, err == nil)
// 	bytes, err = gx.image_serialize(&image, allocator)
// 	tst.expect(t_context, err == nil)
// 	deserialized_image, err = gx.image_deserialize(bytes, allocator)
// 	tst.expect(t_context, err == nil)
// 	tst.expect(t_context, gx.image_equiv(&image, &deserialized_image))
// 	tst.expect(t_context, b.equal(image.pixels.buf[:], deserialized_image.pixels.buf[:]))

// 	// database test //
// 	url = "image:dev-oriented-grid"
// 	database := as.make_database({ "Test-Data.bin", "data", as.DEFAULT_AUTOSAVE_INTERVAL, as.DEFAULT_AUTOSAVE_CAP }, context.temp_allocator)
// 	as.remove_database(&database)
// 	tst.expect(t_context, ! as.contains_entry(&database, url))
// 	// (TODO): Fix this.
// 	// image, err = gx.import_or_retreive_image(&database, url, context.temp_allocator)
// 	// tst.expect(t_context, as.contains_entry(&database, url))
// 	// tst.expect(t_context, err == nil)

// 	free_all(allocator) }

// @(test)
// micro_pair_test :: proc(t_context: ^tst.T) {
// 	micro_pair: ^mp.Micro_Pair

// 	context.user_ptr = mp.to_rawptr(mp.make_micro_pair())
// 	tst.expect(t_context, mp.is_empty(mp.from_rawptr(context.user_ptr)))
// 	context.user_ptr = mp.to_rawptr(mp.add_by_index(mp.from_rawptr(context.user_ptr), 0))
// 	context.user_ptr = mp.to_rawptr(mp.add_by_index(mp.from_rawptr(context.user_ptr), 1))
// 	tst.expect(t_context, ! mp.is_empty(mp.from_rawptr(context.user_ptr)))
// 	tst.expect(t_context, mp.from_rawptr(context.user_ptr)[0] == 0)
// 	tst.expect(t_context, mp.from_rawptr(context.user_ptr)[1] == 1) }

// @(test)
// model_test :: proc(t_context: ^tst.T) {
// 	allocator: rt.Allocator
// 	model: gx.Model
// 	deserialized_model: gx.Model
// 	relpath: string
// 	path: string
// 	url: as.URL
// 	err: os.Error
// 	bytes: []u8
// 	model_node: ^scn.Model_Node

// 	allocator = context.temp_allocator

// 	// serialize/deserialize test //
// 	relpath = "data/castle.glb"
// 	url = "model:castle"
// 	path = as.relpath_to_path(relpath, allocator)
// 	model, err = gx.load_model(path, url, allocator)
// 	tst.expect(t_context, err == nil)
// 	bytes, err = gx.model_serialize(&model, allocator)
// 	tst.expect(t_context, err == nil)
// 	deserialized_model, err = gx.model_deserialize(bytes, allocator)
// 	tst.expect(t_context, err == nil)
// 	tst.expect(t_context, gx.model_equiv(&model, &deserialized_model))

// 	// model node test //
// 	model_node = scn.make_model_node(scn.DEFAULT_NODE_CONFIG, &model, allocator)
// 	model_node.url = "model:castle"
// 	// scn.render_node(nil, model_node)

// 	free_all(allocator) }

// @(test)
// scene_test :: proc(t_context: ^tst.T) {
// 	allocator: rt.Allocator
// 	tree: scn.Tree
// 	node, other_node: ^scn.Node
// 	tree_iterator: scn.Tree_Iterator
// 	ok: bool

// 	allocator = context.temp_allocator
// 	N :: 4

// 	// attach root test //
// 	node = scn.make_node({ name = "root" }, allocator)
// 	tst.expect(t_context, node != nil)
// 	scn.tree_attach_root(&tree, node)
// 	tst.expect(t_context, tree.root == node)

// 	// attach child test //
// 	node = tree.root
// 	for i in 0 ..< N {
// 		other_node = scn.make_node({ name = fmt.tprintf("node-1-%d", i) }, allocator)
// 		tst.expect(t_context, other_node != nil)
// 		scn.node_attach_child(node, other_node)
// 		tst.expect(t_context, node.last_child == other_node) }

// 	// attach sibling test //
// 	node = scn.make_node({ name = "node-2-0" }, allocator)
// 	scn.node_attach_child(tree.root.first_child, node)
// 	for i in 1 ..< N + 1 {
// 		other_node = scn.make_node({ name = fmt.tprintf("node-2-%d", i) }, allocator)
// 		tst.expect(t_context, other_node != nil)
// 		scn.node_attach_sibling(node, other_node)
// 		tst.expect(t_context, node.parent.last_child == other_node) }

// 	// root iterator test //
// 	tree_iterator = scn.tree_iterator_root(&tree)
// 	node, ok = scn.tree_iterate_next(&tree_iterator)
// 	tst.expect(t_context, node.name == "root")
// 	for i in 0 ..< N {
// 		node, ok = scn.tree_iterate_next(&tree_iterator)
// 		tst.expect(t_context, node.name == fmt.tprintf("node-1-%d", i)) }
// 	for i in 0 ..< N + 1 {
// 		node, ok = scn.tree_iterate_next(&tree_iterator)
// 		tst.expect(t_context, node.name == fmt.tprintf("node-2-%d", i)) }

// 	// node iterator test //
// 	tree_iterator = scn.tree_iterator_node(tree.root.first_child.first_child)
// 	for i in 0 ..< N + 1 {
// 		node, ok = scn.tree_iterate_next(&tree_iterator)
// 		tst.expect(t_context, node.name == fmt.tprintf("node-2-%d", i)) }

// 	// sibling iterator test //
// 	tree_iterator = scn.tree_iterator_root(&tree)
// 	node, ok = scn.tree_iterate_next(&tree_iterator)
// 	tst.expect(t_context, node.name == "root")
// 	for i in 0 ..< N {
// 		node, ok = scn.tree_iterate_next_sibling(&tree_iterator)
// 		tst.expect(t_context, node.name == fmt.tprintf("node-1-%d", i)) }
// 	node, ok = scn.tree_iterate_next_sibling(&tree_iterator)
// 	tst.expect(t_context, ! ok)

// 	// search by name test //
// 	tst.expect(t_context, scn.tree_search_by_name(&tree, "root").name == "root")
// 	tst.expect(t_context, scn.tree_search_by_name(&tree, "node-2-3").name == "node-2-3")

// 	// search by proc test //
// 	condition_proc :: proc(node: ^scn.Node, name: string) -> bool {
// 		if node.parent == nil do return false
// 		return node.parent.name == name }
// 	tst.expect(t_context, scn.tree_search_by_proc(&tree, condition_proc, "root").parent.name == "root")
// 	tst.expect(t_context, scn.tree_search_by_proc(&tree, condition_proc, "node-1-0").parent.name == "node-1-0")

// 	free_all(allocator) }
