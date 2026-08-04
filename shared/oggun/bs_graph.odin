#+feature using-stmt
package oggun
import "base:runtime"

Graph :: struct($Label: typeid) {
	order: u32,
	adjacency_matrix: TMatrix(Label) }

make_graph :: proc(order: u32, allocator := context.allocator, loc := #caller_location) -> (graph: Graph($Label), err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Matrix; adjacency_matrix, err = make_tmatrix(order, allocator, loc)
	return { order = order, adjacency_matrix = adjacency_matrix }, err }

poset_order :: proc(poset: ^Poset) -> u32 {
	return poset.adjacency_matrix.shape.x }

poset_connect :: proc(poset: ^Poset, src, dest: u32) {
	write(&poset.adjacency_matrix, [2]u32{ src, dest }, 1) }

poset_simple_connect :: proc(poset: ^Poset, src, dest: u32) {
	write(&poset.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }, 1) }

poset_disconnect :: proc(poset: ^Poset, src, dest: u32) {
	write(&poset.adjacency_matrix, [2]u32{ src, dest }, 0) }

poset_simple_disconnect :: proc(poset: ^Poset, src, dest: u32) {
	write(&poset.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }, 0) }

poset_connected :: proc(poset: ^Poset, src, dest: u32) -> bool {
	return cast(bool)read(&poset.adjacency_matrix, [2]u32{ src, dest }) }

poset_simply_connected :: proc(poset: ^Poset, src, dest: u32) -> bool {
	return cast(bool)read(&poset.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }) }

poset_neighbors :: proc(poset: ^Poset, src: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, poset_order(poset), allocator)
	for dest in 0 ..< poset_order(poset) do if poset_connected(poset, src, dest) do append(&neighbors_dynamic, dest)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_reverse_neighbors :: proc(poset: ^Poset, dest: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, poset_order(poset), allocator)
	for src in 0 ..< poset_order(poset) do if poset_connected(poset, src, dest) do append(&neighbors_dynamic, src)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_simple_neighbors :: proc(poset: ^Poset, src: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, poset_order(poset), allocator)
	for dest in 0 ..< poset_order(poset) do if poset_simply_connected(poset, src, dest) do append(&neighbors_dynamic, dest)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_outdegree :: proc(poset: ^Poset, src: u32, allocator := context.allocator) -> (degree: u32) {
	for dest in 0 ..< poset_order(poset) do if poset_connected(poset, src, dest) do degree += 1
	return degree }

poset_indegree :: proc(poset: ^Poset, dest: u32, allocator := context.allocator) -> (degree: u32) {
	for src in 0 ..< poset_order(poset) do if poset_connected(poset, src, dest) do degree += 1
	return degree }
