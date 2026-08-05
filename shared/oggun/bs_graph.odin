#+feature using-stmt
package oggun
import "base:runtime"

Graph :: struct($Label: typeid) {
	order: u32,
	adjacency_matrix: TMatrix(Label) }

make_graph :: proc($Label: typeid, order: u32, allocator := context.allocator, loc := #caller_location) -> (graph: Graph(Label), err: runtime.Allocator_Error) #optional_allocator_error {
	adjacency_matrix: Matrix; adjacency_matrix, err = make_tmatrix(order, allocator, loc)
	return { order = order, adjacency_matrix = adjacency_matrix }, err }

graph_size :: proc(graph: ^Graph($Label)) -> (size: u32) {
	order := graph_order(graph)
	for i in 0 ..< order do for j in i + 1 ..< order do if graph_connected(graph, i, j) do size += 1
	return size }

graph_order :: proc(graph: ^Graph($Label)) -> u32 {
	return graph.adjacency_matrix.shape.x }

graph_connect :: proc(graph: ^Graph($Label), vert0, vert1: u32, label: Label) {
	write(&graph.adjacency_matrix, index2_triangulate({ vert0, vert1 }), label) }

graph_disconnect :: proc(graph: ^Graph($Label), vert0, vert1: u32) {
	write(&graph.adjacency_matrix, index2_triangulate({ vert0, vert1 }), Label({})) }

graph_connected :: proc(graph: ^Graph($Label), vert0, vert1: u32) -> bool {
	return cast(bool)read(&graph.adjacency_matrix, index2_triangulate({ vert0, vert1 })) }

graph_neighbors :: proc(graph: ^Graph($Label), vert0: u32, allocator := context.allocator) -> []u32 {
	neighbors_dynamic := make_dynamic_array_len_cap([dynamic]u32, 0, graph_order(graph), allocator)
	for vert1 in 0 ..< graph_order(graph) do if graph_connected(graph, vert0, vert1) do append(&neighbors_dynamic, vert1)
	shrink(&neighbors_dynamic)
	return neighbors_dynamic[:] }

graph_degree :: proc(graph: ^Graph($Label), vert0: u32, allocator := context.allocator) -> (degree: u32) {
	for vert1 in 0 ..< graph_order(graph) do if graph_connected(graph, vert0, vert1) do degree += 1
	return degree }
