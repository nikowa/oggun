#+feature using-stmt
package oggun
import "base:runtime"

Poset :: struct {
	adjacency_matrix: Bit_Matrix }

make_poset :: proc(order: u32, allocator := context.allocator, loc := #caller_location) -> (poset: Poset, err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Bit_Matrix; adjacency_matrix, err = make_square_bit_matrix(order, allocator, loc)
	return { adjacency_matrix = adjacency_matrix }, err }

poset_size :: proc(poset: ^Poset) -> (size: u32) {
	order := poset_order(poset)
	for i in 0 ..< order do for j in i + 1 ..< order do if poset_biconnected(poset, i, j) do size += 1
	return size }

poset_order :: proc(poset: ^Poset) -> (order: u32) {
	return poset.adjacency_matrix.shape.x }

poset_connect :: proc(poset: ^Poset, vert0, vert1: u32) {
	write(&poset.adjacency_matrix, [2]u32{ vert0, vert1 }, 1) }

poset_biconnect :: proc(poset: ^Poset, vert0, vert1: u32) {
	write(&poset.adjacency_matrix, index2_triangulate({ vert0, vert1 }), 1) }

poset_disconnect :: proc(poset: ^Poset, vert0, vert1: u32) {
	write(&poset.adjacency_matrix, [2]u32{ vert0, vert1 }, 0) }

poset_bidisconnect :: proc(poset: ^Poset, vert0, vert1: u32) {
	write(&poset.adjacency_matrix, index2_triangulate({ vert0, vert1 }), 0) }

poset_connected :: proc(poset: ^Poset, vert0, vert1: u32) -> bool {
	return cast(bool)read(&poset.adjacency_matrix, [2]u32{ vert0, vert1 }) }

poset_biconnected :: proc(poset: ^Poset, vert0, vert1: u32) -> bool {
	return cast(bool)read(&poset.adjacency_matrix, index2_triangulate({ vert0, vert1 })) }

// (TODO): Make these functions generic, so they can be reused for the other graph types. //
poset_neighbors :: proc(poset: ^Poset, vert0: u32, allocator := context.allocator) -> []u32 {
	order := poset_order(poset)
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, order, allocator)
	for vert1 in 0 ..< order do if poset_biconnected(poset, vert0, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_outneighbors :: proc(poset: ^Poset, vert0: u32, allocator := context.allocator) -> []u32 {
	order := poset_order(poset)
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, order, allocator)
	for vert1 in 0 ..< order do if poset_connected(poset, vert0, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_inneighbors :: proc(poset: ^Poset, vert1: u32, allocator := context.allocator) -> []u32 {
	order := poset_order(poset)
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, order, allocator)
	for vert0 in 0 ..< order do if poset_connected(poset, vert0, vert1) do append(&neighbors_dynamic, vert0)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

poset_outdegree :: proc(poset: ^Poset, vert0: u32, allocator := context.allocator) -> (degree: u32) {
	for vert1 in 0 ..< poset_order(poset) do if poset_connected(poset, vert0, vert1) do degree += 1
	return degree }

poset_indegree :: proc(poset: ^Poset, vert1: u32, allocator := context.allocator) -> (degree: u32) {
	for vert0 in 0 ..< poset_order(poset) do if poset_connected(poset, vert0, vert1) do degree += 1
	return degree }
