package oggun
import "core:relative"

Tree :: struct($V: typeid, $B: typeid) {
	root: Tree_Node(V, B) }

Tree_Node :: struct($V: typeid, $B: typeid) {
	value: V,
	parent, first_child, last_child, first_sibling, next_sibling, prev_sibling: relative.Pointer(rawptr, B) }

tree_node_parent :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.parent) }

tree_node_first_child :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.first_child) }

tree_node_last_child :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.last_child) }

tree_node_first_sibling :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.first_sibling) }

tree_node_next_sibling :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.next_sibling) }

tree_node_prev_sibling :: proc(node: ^Tree_Node($V, $B)) -> ^Tree_Node(V, B) {
	return relative.pointer_get(&node.prev_sibling) }

// tree_attach_root :: proc(tree: ^Tree, node: ^Node) {
// 	tree.root = node }

// node_attach_sibling :: proc(node: ^Node, sibling: ^Node) {
// 	node.parent.last_child.next_sibling = sibling
// 	sibling.prev_sibling = node.parent.last_child
// 	node.parent.last_child = sibling
// 	sibling.parent = node.parent }

// node_attach_child :: proc(node: ^Node, child: ^Node) {
// 	if node.first_child == nil {
// 		node.first_child = child
// 		node.last_child = child
// 		child.parent = node }
// 	else do node_attach_sibling(node.last_child, child) }
