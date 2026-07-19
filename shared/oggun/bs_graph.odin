#+feature using-stmt
package oggun
import "base:runtime"

// A static graph. Cannot insert or delete vertexes. Can only modify edges.
Graph :: struct {
	order: u32, // number of vertexes
	size: u32,  // number of edges
	adjacency_matrix: Bit_Matrix }

make_graph :: proc(order: u32, allocator := context.allocator, loc := #caller_location) -> (graph: Graph, err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Bit_Matrix; adjacency_matrix, err = make_square_bit_matrix(order, allocator, loc)
	return { order = order, size = 0, adjacency_matrix = adjacency_matrix }, err }

graph_connect :: proc(graph: ^Graph, src, dest: u32) {
	write(&graph.adjacency_matrix, [2]u32{ src, dest }, 1) }

graph_simple_connect :: proc(graph: ^Graph, src, dest: u32) {
	write(&graph.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }, 1) }

graph_disconnect :: proc(graph: ^Graph, src, dest: u32) {
	write(&graph.adjacency_matrix, [2]u32{ src, dest }, 0) }

graph_simple_disconnect :: proc(graph: ^Graph, src, dest: u32) {
	write(&graph.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }, 0) }

graph_connected :: proc(graph: ^Graph, src, dest: u32) -> bool {
	return cast(bool)read(&graph.adjacency_matrix, [2]u32{ src, dest }) }

graph_simply_connected :: proc(graph: ^Graph, src, dest: u32) -> bool {
	return cast(bool)read(&graph.adjacency_matrix, [2]u32{ max(src, dest), min(src, dest) }) }

graph_neighbors :: proc(graph: ^Graph, src: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, graph.order, allocator)
	for dest in 0 ..< graph.order do if graph_connected(graph, src, dest) do append(&neighbors_dynamic, dest)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

graph_reverse_neighbors :: proc(graph: ^Graph, dest: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, graph.order, allocator)
	for src in 0 ..< graph.order do if graph_connected(graph, src, dest) do append(&neighbors_dynamic, src)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

graph_simple_neighbors :: proc(graph: ^Graph, src: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, graph.order, allocator)
	for dest in 0 ..< graph.order do if graph_simply_connected(graph, src, dest) do append(&neighbors_dynamic, dest)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

graph_outdegree :: proc(graph: ^Graph, src: u32, allocator := context.allocator) -> (degree: u32) {
	for dest in 0 ..< graph.order do if graph_connected(graph, src, dest) do degree += 1
	return degree }

graph_indegree :: proc(graph: ^Graph, dest: u32, allocator := context.allocator) -> (degree: u32) {
	for src in 0 ..< graph.order do if graph_connected(graph, src, dest) do degree += 1
	return degree }
