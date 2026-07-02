package oggun
import "base:runtime"
import "core:math/linalg"

// (TODO): Add a memory arena field. When all the nodes are in that arena, that will make it much easier to serialize and
// deserialize. To maintain links, use relative pointers.
Scene_Config :: struct #all_or_none {
	url: URL,
	haze_color: Color }

DEFAULT_SCENE_CONFIG: Scene_Config : {
	url = DEFAULT_URL,
	haze_color = WHITE }

Scene :: struct {
	using config: Scene_Config,
	tree: Scene_Tree }

make_scene :: proc(url: URL) -> (scene: Scene) {
	scene.url = url
	scene.tree.root = make_node(DEFAULT_NODE_CONFIG, context.allocator)
	return scene }

scene_attach :: proc(scene: ^Scene, child: ^Node) {
	node_attach_child(scene.tree.root, child) }

// (TODO): Add an url.
// (TODO): Add serialize, deserialize, import, and save.
// (TODO): Rename to "Scene_Scene_Tree"
Scene_Tree :: struct {
	root: ^Node }

Node_Render_Proc :: #type proc(scene: ^Scene, camera_node: ^Camera_Node, node: ^Node)

Node_Tick_Proc :: #type proc(node: ^Node)

Node_Config :: struct {
	name: string,
	id: u32,
	render_proc: Node_Render_Proc,
	tick_proc: Node_Tick_Proc,
	translate: [3]f32,
	rotate: quaternion128,
	scale: [3]f32,
	visible: bool }

stub_node_render_proc :: proc(scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) { }
stub_node_tick_proc :: proc(node: ^Node) {}

DEFAULT_NODE_CONFIG: Node_Config : {
	name = DEFAULT_NAME,
	id = 0,
	render_proc = stub_node_render_proc,
	tick_proc = stub_node_tick_proc,
	translate = { 0, 0, 0 },
	rotate = 1 + 0i + 0j + 0k,
	scale = { 1, 1, 1 },
	visible = true }

Node :: struct {
	using config: Node_Config,
	parent: ^Node,
	first_child: ^Node,
	last_child: ^Node,
	first_sibling: ^Node,
	next_sibling: ^Node,
	prev_sibling: ^Node,
	transform: Node_Transform }
// (NOTE):
	// transform_translate: matrix[4, 4]f32,
	// transform_rotate: matrix[4, 4]f32,
	// transform_scale: matrix[4, 4]f32,
	// transform: matrix[4, 4]f32

// (TODO): Implement this, so I can nest nodes and tarnsforms are applied recursively.
// (TODO): Rename to "Transform". //
Node_Transform :: struct {
	translate: matrix[4, 4]f32,
	rotate: matrix[4, 4]f32,
	scale: matrix[4, 4]f32,
	total: matrix[4, 4]f32,
	total_cumulative: matrix[4, 4]f32 }

// node_transform_cumulative :: proc(node: ^Node) -> (transform: Node_Transform) { }

render_node :: proc(scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	if node.render_proc == nil do return
	node.render_proc(scene, camera_node, node) }

tick_node :: proc(node: ^Node) {
	if node.tick_proc == nil do return
	node.tick_proc(node) }

// (TODO): A default tick_node proc, which calculates the cumulative transform.

render_scene :: proc(scene: ^Scene, camera_node: ^Camera_Node) {
	render_node(scene, nil, &camera_node.node) }

tick_scene :: proc(scene: ^Scene) {
	tree_iterator: Scene_Tree_Iterator

	assert(scene != nil)
	tree_iterator = tree_iterator_root(&scene.tree)
	for node in tree_iterate_next(&tree_iterator) do tick_node(node) }

init_node :: proc(node: ^Node, config: Node_Config) {
	node.config = config
	node.first_sibling = node }

make_node :: proc(config: Node_Config, allocator: runtime.Allocator) -> (node: ^Node) {
	node = new(Node, allocator)
	init_node(node, config)
	return node }

make_derived_node :: proc($Derived_Node_Type: typeid, node_config: Node_Config, default_render_proc: Node_Render_Proc, default_tick_proc: Node_Tick_Proc, allocator: runtime.Allocator) -> (derived_node: ^Derived_Node_Type) {
	node_config := node_config
	derived_node = new(Derived_Node_Type, allocator)
	if node_config.render_proc == nil do node_config.render_proc = default_render_proc
	if node_config.tick_proc == nil do node_config.tick_proc = default_tick_proc
	init_node(&derived_node.node, node_config)
	return derived_node }

tree_attach_root :: proc(tree: ^Scene_Tree, node: ^Node) {
	tree.root = node }

node_attach_sibling :: proc(node: ^Node, sibling: ^Node) {
	node.parent.last_child.next_sibling = sibling
	sibling.prev_sibling = node.parent.last_child
	node.parent.last_child = sibling
	sibling.parent = node.parent }

node_attach_child :: proc(node: ^Node, child: ^Node) {
	if node.first_child == nil {
		node.first_child = child
		node.last_child = child
		child.parent = node }
	else do node_attach_sibling(node.last_child, child) }

// (TODO): Test this!
node_detach :: proc(node: ^Node) {
	if node.prev_sibling != nil do node.prev_sibling.next_sibling = node.next_sibling
	if node.next_sibling != nil do node.next_sibling.prev_sibling = node.prev_sibling
	if node.parent.first_child == node do node.parent.first_child = node.next_sibling
	if node.parent.last_child == node do node.parent.last_child = node.prev_sibling
	node.parent = nil
	node.first_sibling = nil
	node.next_sibling = nil }

Scene_Tree_Iterator :: struct {
	curr: ^Node }

node_object :: proc(node: ^Node, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(node) - offset) }

tree_iterator_root :: proc(tree: ^Scene_Tree) -> Scene_Tree_Iterator {
	return { curr = tree.root } }

tree_iterator_node :: proc(node: ^Node) -> Scene_Tree_Iterator {
	return { curr = node } }

tree_iterate_next :: proc "contextless" (iterator: ^Scene_Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.next_sibling != nil do iterator.curr = node.next_sibling
	else do iterator.curr = (node.parent != nil) ? node.parent.first_child.first_child : node.first_child
	return node, true }

tree_iterate_prev :: proc "contextless" (iterator: ^Scene_Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.prev_sibling != nil do iterator.curr = node.prev_sibling
	else do iterator.curr = node.parent
	return node, true }

tree_iterate_next_sibling :: proc "contextless" (iterator: ^Scene_Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.next_sibling != nil do iterator.curr = node.next_sibling
	else do iterator.curr = nil
	return node, true }

tree_iterate_prev_sibling :: proc "contextless" (iterator: ^Scene_Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.prev_sibling != nil do iterator.curr = node.prev_sibling
	else do iterator.curr = nil
	return node, true }

tree_search_by_name :: proc(tree: ^Scene_Tree, name: string) -> (result: ^Node) {
	iterator: Scene_Tree_Iterator

	iterator = tree_iterator_root(tree)
	for node in tree_iterate_next(&iterator) {
		if node.name == name do return node }
	return nil }

tree_search_by_proc :: proc(tree: ^Scene_Tree, condition_proc: proc(node: ^Node, user_data: $T) -> bool, user_data: T) -> (result: ^Node) {
	iterator: Scene_Tree_Iterator

	iterator = tree_iterator_root(tree)
	for node in tree_iterate_next(&iterator) {
		if condition_proc(node, user_data) do return node }
	return nil }

node_transforms :: proc(node: ^Node) -> (translate_matrix, rotate_matrix, scale_matrix, node_matrix: matrix[4, 4]f32) {
	translate_matrix = linalg.matrix4_translate_f32(node.translate)
	rotate_matrix = linalg.matrix4_rotate_f32(node.rotate.x, { 1, 0, 0 }) *
		linalg.matrix4_rotate_f32(node.rotate.y, { 0, 1, 0 }) *
		linalg.matrix4_rotate_f32(node.rotate.z, { 0, 0, 1 })
	scale_matrix = linalg.matrix4_scale_f32(node.scale)
	node_matrix = translate_matrix * rotate_matrix * scale_matrix
	return }
