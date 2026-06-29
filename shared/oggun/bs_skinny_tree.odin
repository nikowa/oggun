package oggun
import "core:relative"

Skinny_Tree :: struct($Value_Type: typeid, $Pointer_Backing: typeid) {
	root: Skinny_Tree_Node(Value_Type, Pointer_Backing) }

Skinny_Tree_Node :: struct($Value_Type: typeid, $Pointer_Backing: typeid) {
	value:         Value_Type,
	parent:        ^Node,
	first_child:   ^Node,
	last_child:    ^Node,
	first_sibling: ^Node,
	next_sibling:  ^Node,
	prev_sibling:  ^Node,
	transform:     Node_Transform }

