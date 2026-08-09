#+feature using-stmt
package oggun
import "base:runtime"

Digraph :: struct($Label: typeid) {
	adjacency_matrix: Matrix(Label) }

make_digraph :: proc($Label: typeid, order: u32, allocator := context.allocator, loc := #caller_location) -> (digraph: Digraph(Label), err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Matrix($Label); adjacency_matrix, err = make_bit_matrix({ order, order }, allocator, loc)
	return { order = order, size = 0, adjacency_matrix = adjacency_matrix }, err }

digraph_size :: proc(digraph: ^Digraph($Label)) -> (size: u32) {
	order := digraph_order(digraph)
	for i in 0 ..< order do for j in i + 1 ..< order do if digraph_biconnected(digraph, i, j) do size += 1
	return size }

digraph_order :: proc(digraph: ^Digraph($Label)) -> (order: u32) {
	return digraph.adjacency_matrix.shape.x }

digraph_connect :: proc(digraph: ^Digraph($Label), vert0, vert1: u32, label: Label) {
	write(&digraph.adjacency_matrix, [2]u32{ vert0, vert1 }, label) }

digraph_biconnect :: proc(digraph: ^Digraph($Label), vert0, vert1: u32, label: Label) {
	write(&digraph.adjacency_matrix, index2_triangulate({ vert0, vert1 }), label) }

digraph_disconnect :: proc(digraph: ^Digraph($Label), vert0, vert1: u32) {
	write(&digraph.adjacency_matrix, [2]u32{ vert0, vert1 }, auto_cast nil) }

digraph_bidisconnect :: proc(digraph: ^Digraph($Label), vert0, vert1: u32) {
	write(&digraph.adjacency_matrix, index2_triangulate({ vert0, vert1 }), auto_cast nil) }

digraph_connected :: proc(digraph: ^Digraph($Label), vert0, vert1: u32) -> (bool, Label) {
	return cast(bool)read(&digraph.adjacency_matrix, [2]u32{ vert0, vert1 }) }

digraph_biconnected :: proc(digraph: ^Digraph($Label), vert0, vert1: u32) -> (bool, Label, Label) {
	return cast(bool)read(&digraph.adjacency_matrix, index2_triangulate({ vert0, vert1 })) }

// (TODO): Make these functions generic, so they can be reused for the other graph types. //
digraph_neighbors :: proc(digraph: ^Digraph($Label), vert0: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, digraph.order, allocator)
	for vert1 in 0 ..< digraph.order do if digraph_biconnected(digraph, vert0, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

digraph_outneighbors :: proc(digraph: ^Digraph($Label), vert0: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, digraph.order, allocator)
	for vert1 in 0 ..< digraph.order do if digraph_connected(digraph, vert0, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

digraph_inneighbors :: proc(digraph: ^Digraph($Label), vert1: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, digraph.order, allocator)
	for vert0 in 0 ..< digraph.order do if digraph_connected(digraph, vert0, vert1) do append(&neighbors_dynamic, vert0)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

digraph_outdegree :: proc(digraph: ^Digraph($Label), vert0: u32, allocator := context.allocator) -> (degree: u32) {
	for vert1 in 0 ..< digraph.order do if digraph_connected(digraph, vert0, vert1) do degree += 1
	return degree }

digraph_indegree :: proc(digraph: ^Digraph($Label), vert1: u32, allocator := context.allocator) -> (degree: u32) {
	for vert0 in 0 ..< digraph.order do if digraph_connected(digraph, vert0, vert1) do degree += 1
	return degree }
