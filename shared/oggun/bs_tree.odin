package oggun
import "base:runtime"
import "core:relative"
import "core:strings"
import "core:fmt"
import "core:log"

Tree_Builder :: struct($V: typeid, $B: typeid) {
	allocator: runtime.Allocator,
	root: ^Tree(V, B),
	stack: [dynamic]^Tree(V, B) }

Tree :: struct($V: typeid, $B: typeid) #packed {
	value: V,
	parent, first_child, next_sibling: relative.Pointer(rawptr, B) }

Tree_Iterator :: struct($V: typeid, $B: typeid) {
	curr: ^Tree(V, B),
	stack: [dynamic]^Tree(V, B),
	next: proc(iter: ^Tree_Iterator(V, B)) -> (node: ^Tree(V, B), ok: bool) }

// tree_add_child :: proc(builder: ^Tree_Builder($V, $B), value: V) {
// 	child := new(Tree, builder.allocator)
// 	tree_attach_child(builder.current,
// 	// Tree :: struct($V: typeid, $B: typeid)
// }

// (DESC): Acceleration structure for walking a tree. //
Tree_Walker :: struct($V: typeid, $B: typeid) {
	tree: ^Tree(V, B) }

tree_root :: proc(tree: ^Tree($V, $B)) -> (root: ^Tree(V, B)) {
	if tree == nil do return nil
	node := tree
	for {
		parent := tree_parent(node)
		if parent == nil do return node
		node = parent }
	return nil }

tree_degree :: proc(node: ^Tree($V, $B)) -> (degree: uint) {
	degree = 0
	child := tree_first_child(node)
	for child != nil {
		degree += 1
		child = tree_next_sibling(node) }
	return degree }

tree_first_child :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	return auto_cast relative.pointer_get(&node.first_child) }

tree_last_child :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	curr := tree_first_child(node)
	if curr == nil do return nil
	for {
		sibling := tree_next_sibling(curr)
		if sibling == nil do return curr
		curr = sibling }
	return nil }

tree_next_sibling :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	return auto_cast relative.pointer_get(&node.next_sibling) }

tree_prev_sibling :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	sibling := tree_first_child(tree_parent())
	for {
		next := tree_next_sibling(node)
		if next == node do return sibling
		sibling = next }
	return nil }

tree_first_sibling :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	parent := tree_parent(node)
	if parent == nil do return node
	else do return tree_first_child(parent) }

tree_last_sibling :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	curr := node
	for {
		sibling := tree_next_sibling(curr)
		if sibling == nil do return curr
		curr = sibling }
	return nil }

tree_parent :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	return auto_cast relative.pointer_get(&node.parent) }

tree_first_leaf :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	descendant := node
	for {
		child := tree_first_child(descendant)
		if child == nil do return descendant
		descendant = child }
	return nil }

tree_last_leaf :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	if node == nil do return nil
	descendant := node
	for {
		child := tree_last_child(descendant)
		if child == nil do return descendant
		descendant = child }
	return nil }

tree_is_root :: proc(node: ^Tree($V, $B)) -> bool {
	if node == nil do return false
	return tree_parent(node) == nil }

tree_is_leaf :: proc(node: ^Tree($V, $B)) -> bool {
	if node == nil do return false
	return tree_first_child(node) == nil }

tree_is_branching :: proc(node: ^Tree($V, $B)) -> bool {
	if node == nil do return false
	first_child := tree_first_child(node)
	second_child := tree_next_sibling(first_child)
	return first_child != nil && second_child != nil }

@(deprecated="not unimplemented")
tree_height :: proc(node: ^Tree($V, $B)) -> uint {
	return 0 }

@(deprecated="not unimplemented")
tree_size :: proc(node: ^Tree($V, $B)) -> uint {
	return 0 }

tree_is_ancestor :: proc(node: ^Tree($V, $B), ancestor: ^Tree(V, B)) -> bool {
	return true }

make_tree_preorder_iterator :: proc(tree: ^Tree($V, $B)) -> Tree_Iterator(V, B) {
	return {
		curr = tree,
		stack = make([dynamic]^Tree(V, B)),
		next = proc(iter: ^Tree_Iterator(V, B)) -> (node: ^Tree(V, B), ok: bool) {
			node, ok = iter.curr, iter.curr != nil
			next_sibling := tree_next_sibling(node)
			first_child := tree_first_child(node)
			if next_sibling != nil do push(&iter.stack, next_sibling)
			if first_child != nil do iter.curr = first_child
			else {
				if len(iter.stack) > 0 do iter.curr = pop(&iter.stack)
				else do iter.curr = nil }
			return node, ok } } }

make_tree_postorder_iterator :: proc(tree: ^Tree($V, $B)) -> Tree_Iterator(V, B) {
	return {
		curr = tree_first_leaf(tree),
		next = proc(iter: ^Tree_Iterator(V, B)) -> (node: ^Tree(V, B), ok: bool) {
			node, ok = iter.curr, iter.curr != nil
			next_sibling := tree_next_sibling(node)
			parent := tree_parent(node)
			if next_sibling == nil do iter.curr = parent
			else do iter.curr = tree_first_leaf(next_sibling)
			return node, ok } } }

tree_n_children :: proc(tree: ^Tree($V, $B)) -> uint {
	return 0 }

tree_nth_child :: proc(tree: ^Tree($V, $B), n: uint) -> (result: ^Tree(V, B)) {
	return nil }

tree_lowest_common_ancestor :: proc(tree_a: ^Tree($V, $B), tree_b: ^Tree(V, B)) -> (result: ^Tree(V, B)) {
	return nil }

tree_lowest_branching_ancestor :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	return nil }

tree_highest_branching_descendant :: proc(node: ^Tree($V, $B)) -> (result: ^Tree(V, B)) {
	return nil }

tree_n_leaves :: proc(tree: ^Tree($V, $B)) -> uint {
	return 0 }

tree_capacity_check_error :: proc(ptr: ^relative.Pointer(rawptr, $B), addr: [2]rawptr, loc := #caller_location) {
	if relative.pointer_get(ptr) != addr[1] {
		type_info := type_info_of(B)
		log.errorf("Tree capacity exceeded. Address 0x%x is out of reach of 0x%x using backing type %s%d.", addr[1], addr[0], type_info.variant.(runtime.Type_Info_Integer).signed ? "i" : "u", 8 * type_info.size, location=loc) } }

tree_set_parent :: proc(node: ^Tree($V, $B), parent: ^Tree(V, B)) {
	relative.pointer_set(&node.parent, parent)
	// log.info(rawptr(parent), rawptr(tree_parent(node)))
	tree_capacity_check_error(&node.parent, { cast(rawptr)node, cast(rawptr)parent }) }

tree_set_first_child :: proc(node: ^Tree($V, $B), first_child: ^Tree(V, B)) {
	relative.pointer_set(&node.first_child, first_child)
	tree_capacity_check_error(&node.first_child, { cast(rawptr)node, cast(rawptr)first_child }) }

tree_set_next_sibling :: proc(node: ^Tree($V, $B), next_sibling: ^Tree(V, B)) {
	relative.pointer_set(&node.next_sibling, next_sibling)
	tree_capacity_check_error(&node.next_sibling, { cast(rawptr)node, cast(rawptr)next_sibling }) }

tree_append_child :: proc(node: ^Tree($V, $B), child: ^Tree(V, B)) {
	last_child := tree_last_child(node)
	if last_child == nil do tree_set_first_child(node, child)
	else do tree_set_next_sibling(last_child, child)
	tree_set_parent(child, node) }

tree_append_sibling :: proc(node: ^Tree($V, $B), sibling: ^Tree(V, B)) {
	last_sibling := tree_last_sibling(node)
	tree_set_next_sibling(last_sibling, sibling)
	tree_set_parent(sibling, tree_parent(node)) }

make_tree_builder :: proc($V: typeid, $B: typeid, allocator := context.allocator) -> Tree_Builder(V, B) {
	return {
		allocator=allocator,
		root=nil,
		stack=make([dynamic]^Tree(V, B)) } }

tree_builder_capacity :: proc(builder: ^Tree_Builder($V, $B)) -> uint {
	return uint(abs(int(~ B(0)))) / size_of(Tree(V, B)) + 1 }

tree_builder_parent :: proc(builder: ^Tree_Builder($V, $B)) -> ^Tree(V, B) {
	if len(builder.stack) == 0 do return nil
	else do return builder.stack[len(builder.stack) - 1] }

tree_build_node :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	node := new(Tree(V, B), builder.allocator)
	node.value = value
	return node }

tree_build_node_begin :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	node := tree_build_node(builder, value)
	push(&builder.stack, node)
	return node }

tree_build_node_end :: proc(builder: ^Tree_Builder($V, $B)) {
	pop(&builder.stack) }

tree_build_root :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	builder.root = tree_build_node(builder, value)
	return builder.root }

tree_build_root_begin :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	root := tree_build_root(builder, value)
	push(&builder.stack, root)
	return root }

tree_build_root_end :: tree_build_node_end

tree_build_child :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	parent := tree_builder_parent(builder)
	child := tree_build_node(builder, value)
	tree_append_child(parent, child)
	return child }

tree_build_child_begin :: proc(builder: ^Tree_Builder($V, $B), value: V) -> ^Tree(V, B) {
	child := tree_build_child(builder, value)
	push(&builder.stack, child)
	return child }

tree_build_child_end :: tree_build_node_end

aprint_tree :: proc(tree: ^Tree($V, $B), allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, 10_000, allocator)
	sbprint_tree :: proc(sb: ^strings.Builder, node: ^Tree($V, $B), depth: int) {
		if node == nil do return
		for i in 0 ..< depth - 1 do fmt.sbprint(sb, "|  ")
		for i in 1 ..< depth - 1 do fmt.sbprint(sb, "   ")
		if depth > 0 do if tree_next_sibling(node) != nil do fmt.sbprint(sb, "|--")
			else do fmt.sbprint(sb, "'--")
		fmt.sbprint(sb, node.value)
		// fmt.sbprintfln(sb, " %x (%x %x %x)", cast(rawptr)node, cast(rawptr)tree_parent(node), cast(rawptr)tree_first_child(node), cast(rawptr)tree_next_sibling(node))
		fmt.sbprintln(sb)
		sbprint_tree(sb, tree_first_child(node), depth + 1)
		sbprint_tree(sb, tree_next_sibling(node), depth) }
	sbprint_tree(&sb, tree, 0)
	return strings.to_string(sb) }

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
