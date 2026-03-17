package scene
import rt "base:runtime"
import gx "../graphics"
// import tr "../container/tree"



Tree :: struct {
	root: ^Node }

Node_Config :: struct {
	name: string,
	render_proc: proc(graphics_context: ^gx.Graphics_Context, node: ^Node),
	translate: [3]f32,
	rotate: [3]f32,
	scale: [3]f32 }

Node :: struct {
	using config: Node_Config,
	parent: ^Node,
	first_child: ^Node,
	last_child: ^Node,
	first_sibling: ^Node,
	next_sibling: ^Node,
	prev_sibling: ^Node,
	transform_translate: matrix[4, 4]f32,
	transform_rotate: matrix[4, 4]f32,
	transform_scale: matrix[4, 4]f32,
	transform: matrix[4, 4]f32 }

render_node :: proc(graphics_context: ^gx.Graphics_Context, node: ^Node) {
	if node.render_proc == nil do return
	node.render_proc(graphics_context, node) }

init_node :: proc(node: ^Node, config: Node_Config) {
	node.config = config
	node.first_sibling = node }

make_node :: proc(allocator: rt.Allocator, config: Node_Config) -> (node: ^Node) {
	node = new(Node, allocator)
	init_node(node, config)
	return node }

tree_attach_root :: proc(tree: ^Tree, node: ^Node) {
	tree.root = node }

node_is_only_sibling :: proc(node: ^Node) -> bool {
	return node.first_sibling == node }

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

node_detach :: proc(node: ^Node) {
	if node.prev_sibling != nil do node.prev_sibling.next_sibling = node.next_sibling
	if node.next_sibling != nil do node.next_sibling.prev_sibling = node.prev_sibling
	if node.parent.first_child == node do node.parent.first_child = node.next_sibling
	if node.parent.last_child == node do node.parent.last_child = node.prev_sibling
	node.parent = nil
	node.first_child = nil
	node.last_child = nil
	node.first_sibling = nil
	node.next_sibling = nil }

Tree_Iterator :: struct {
	curr: ^Node }

node_object :: proc(node: ^Node, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(node) - offset) }

tree_iterator_root :: proc(tree: ^Tree) -> Tree_Iterator {
	return { curr = tree.root } }

tree_iterator_node :: proc(node: ^Node) -> Tree_Iterator {
	return { curr = node } }

tree_iterate_next :: proc "contextless" (iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.next_sibling != nil do iterator.curr = node.next_sibling
	else do iterator.curr = (node.parent != nil) ? node.parent.first_child.first_child : node.first_child
	return node, true }

tree_iterate_prev :: proc "contextless" (iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.prev_sibling != nil do iterator.curr = node.prev_sibling
	else do iterator.curr = node.parent
	return node, true }

tree_iterate_next_sibling :: proc "contextless" (iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.next_sibling != nil do iterator.curr = node.next_sibling
	else do iterator.curr = nil
	return node, true }

tree_iterate_prev_sibling :: proc "contextless" (iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool) {
	node = iterator.curr
	if node == nil do return nil, false
	if node.prev_sibling != nil do iterator.curr = node.prev_sibling
	else do iterator.curr = nil
	return node, true }

tree_search_by_name :: proc(tree: ^Tree, name: string) -> (result: ^Node) {
	iterator: Tree_Iterator

	iterator = tree_iterator_root(tree)
	for node in tree_iterate_next(&iterator) {
		if node.name == name do return node }
	return nil }

tree_search_by_proc :: proc(tree: ^Tree, condition_proc: proc(node: ^Node, user_data: $T) -> bool, user_data: T) -> (result: ^Node) {
	iterator: Tree_Iterator

	iterator = tree_iterator_root(tree)
	for node in tree_iterate_next(&iterator) {
		if condition_proc(node, user_data) do return node }
	return nil }
