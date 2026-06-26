package oggun

// (TODO): Add an url.
// (TODO): Add serialize, deserialize, import, and save.
// Tree :: struct {
// 	root: ^Node }

// Node :: struct {
// 	using config: Node_Config,
// 	parent: ^Node,
// 	first_child: ^Node,
// 	last_child: ^Node,
// 	first_sibling: ^Node,
// 	next_sibling: ^Node,
// 	prev_sibling: ^Node,
// 	transform: Node_Transform }

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
