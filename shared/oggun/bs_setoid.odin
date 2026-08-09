#+feature using-stmt
package oggun
import "base:runtime"

Setoid :: struct {
	adjacency_matrix: Bit_Matrix }

make_setoid :: proc(order: u32, allocator := context.allocator, loc := #caller_location) -> (setoid: Setoid, err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Bit_Matrix; adjacency_matrix, err = make_bit_matrix({ order, order }, allocator, loc)
	return { adjacency_matrix = adjacency_matrix }, err }

setoid_size :: proc(setoid: ^Setoid) -> (size: u32) {
	order := setoid_order(setoid)
	for i in 0 ..< order do for j in i + 1 ..< order do if setoid_connected(setoid, i, j) do size += 1
	return size }

setoid_order :: proc(setoid: ^Setoid) -> (order: u32) {
	return setoid.adjacency_matrix.shape.x }

setoid_connect :: proc(setoid: ^Setoid, vert0, vert1: u32) {
	write(&setoid.adjacency_matrix, index2_triangulate({ vert0, vert1 }), 1) }

setoid_disconnect :: proc(setoid: ^Setoid, vert0, vert1: u32) {
	write(&setoid.adjacency_matrix, index2_triangulate({ vert0, vert1 }), 0) }

setoid_connected :: proc(setoid: ^Setoid, vert0, vert1: u32) -> bool {
	return cast(bool)read(&setoid.adjacency_matrix, index2_triangulate({ vert0, vert1 })) }

setoid_neighbors :: proc(setoid: ^Setoid, vert: u32, allocator := context.allocator) -> []u32 {
	order := setoid_order(setoid)
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, order, allocator)
	for vert1 in 0 ..< order do if setoid_connected(setoid, vert, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

setoid_degree :: proc(setoid: ^Setoid, vert: u32, allocator := context.allocator) -> (degree: u32) {
	for vert1 in 0 ..< setoid_order(setoid) do if setoid_connected(setoid, vert, vert1) do degree += 1
	return degree }
