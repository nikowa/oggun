#+feature using-stmt
package oggun
import "base:runtime"
import "core:math/rand"
import "core:log"
import "core:math"
import "core:math/linalg"

Plot_Graph_Config :: struct {
	default_background_color: Color,
	default_stroke_color: Color,
	light_foreground_color: Color,
	dark_foreground_color: Color,
	// (TODO): Add "xlabel_color" maybe?
	text_style: Text_Style,
	margins: f32, // (TODO): Rename to node margins
	padding: f32, // (TODO): Rename to node padding
	canvas_padding: f32,
	edge_margins: f32,
	radius: f32,
	plot_rect: Rect,
	canvas_rect: Rect,
	arrowhead_size: UI_Size,
	orientation: Orientation,
	arrowhead: bool,
	outline: bool,
	edge_shape: UI_Path_Shape,
	control: bool }

DEFAULT_PLOT_GRAPH_CONFIG: Plot_Graph_Config : {
	default_background_color=COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK,
	default_stroke_color=COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
	light_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_DARK,
	dark_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
	text_style=DEFAULT_TEXT_STYLE,
	margins=4,
	padding=4,
	canvas_padding=32,
	edge_margins=0,
	radius=4,
	plot_rect={ { 0, 0 }, { 2, 2 } },
	canvas_rect={ { 0, 0 }, { 1024, 1024 } },
	arrowhead_size=.L,
	orientation=.Vertical,
	arrowhead=true,
	outline=true,
	edge_shape=.Rectilinear,
	control=true }

Plot_Graph :: struct {
	using config: Plot_Graph_Config,
	nodes: [dynamic]Plot_Node,
	edges: [dynamic]Plot_Edge,
	nodes_map: map[ID]^Plot_Node,
	graph: Poset,
	hovered_node: ^Plot_Node,
	node_was_hovered: bool,
	camera: Camera_2D }

Plot_Node :: struct {
	// (TODO): Put these in "Plot_Node_Config". //
	id: ID,
	class: string,
	background_color: Color,
	stroke_color: Color,
	size: Maybe([2]f32),
	label: string,
	position: Maybe([2]f32),
	pin: bool,
	root: bool,
	tooltip: string,
	xlabel: string,

	_rect: Rect }

PT_DEFAULT_NODE_SIZE: [2]f32 : { 120, 0 }

DEFAULT_PLOT_NODE: Plot_Node : {
	id = 1,
	class = DEFAULT_NAME,
	background_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT,
	stroke_color = COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
	size = PT_DEFAULT_NODE_SIZE,
	label = DEFAULT_NAME,
	position = {},
	pin = false,
	root = false,
	tooltip = DEFAULT_NAME,
	xlabel = DEFAULT_NAME,
	_rect = {} }

Plot_Edge :: struct {
	ids: [2]ID,
	stroke_color: Color,
	xlabel: string }

DEFAULT_PLOT_EDGE: Plot_Edge : {
	ids={ 1, 2 },
	stroke_color=WHITE,
	xlabel=DEFAULT_NAME }

pt_graph_init_begin :: proc(graph: ^Plot_Graph, config: Plot_Graph_Config) {
	graph.config = config
	graph.nodes = make([dynamic]Plot_Node)
	graph.edges = make([dynamic]Plot_Edge)
	graph.nodes_map = make(map[ID]^Plot_Node)
	// graph.canvas_rect = ui_rect_margins(graph.canvas_rect, Interval(graph.canvas_padding))
	sn_init_camera_2d(&graph.camera, DEFAULT_CAMERA_2D_CONFIG) }

pt_edge_nodes :: proc(graph: ^Plot_Graph, edge: Plot_Edge) -> (nodes: [2]^Plot_Node) {
	for i in 0 ..< 2 do nodes[i], _ = graph.nodes_map[edge.ids[i]]
	return nodes }

pt_edge_length :: proc(graph: ^Plot_Graph, edge: Plot_Edge) -> f32 {
	nodes := pt_edge_nodes(graph, edge)
	return linalg.distance(nodes[0].position.? or_else [2]f32{}, nodes[1].position.? or_else [2]f32{}) }

pt_node_index :: proc(graph: ^Plot_Graph, node: ^Plot_Node) -> u32 {
	return auto_cast ((cast(uintptr)node - cast(uintptr)&graph.nodes[0]) / size_of(Plot_Node)) }

pt_graph_init_end :: proc(graph: ^Plot_Graph) {
	for _, i in graph.nodes do graph.nodes_map[graph.nodes[i].id] = &graph.nodes[i]
	graph.graph = make_poset(cast(u32)len(graph.nodes))
	for edge in graph.edges {
		indexes: [2]u32
		for i in 0 ..< 2 do indexes[i] = pt_node_index(graph, graph.nodes_map[edge.ids[i]])
		poset_connect(&graph.graph, indexes[0], indexes[1]) } }

pt_graph_update :: pt_graph_init_end

pt_append_node :: proc(graph: ^Plot_Graph, node: Plot_Node) -> (ptr: ^Plot_Node) {
	append(&graph.nodes, node)
	ptr = &graph.nodes[len(graph.nodes) - 1]
	// graph.nodes_map[node.id] = ptr
	return ptr }

pt_append_edge :: proc(graph: ^Plot_Graph, edge: Plot_Edge) -> (ptr: ^Plot_Edge) {
	append(&graph.edges, edge)
	return &graph.edges[len(graph.edges) - 1] }

// graph.hovered_node
pt_connected :: proc(graph: ^Plot_Graph, nodes: [2]^Plot_Node) -> bool {
	if nodes[0] == nil || nodes[1] == nil do return false
	indexes: [2]u32 = { pt_node_index(graph, nodes[0]), pt_node_index(graph, nodes[1]) }
	return poset_connected(&graph.graph, indexes[0], indexes[1]) }

PT_Layout_Builder_Variant :: enum {
	Random,
	Eades,
	Permuter,
	// 1. spread nodes randomly, without touching. perhap spawning them one by one
	// 2. swap pairs to minimize total edge length
	// 3. repeat until edge length cannot be reduced any further
}

PT_Layout_Proc :: #type proc(data: rawptr, graph: ^Plot_Graph)

PT_Layout_Builder :: struct {
	variant: PT_Layout_Builder_Variant,
	data: rawptr,
	graph: ^Plot_Graph,
	initialize: PT_Layout_Proc,
	process: PT_Layout_Proc,
	post_process: PT_Layout_Proc }

pt_layout_initialize :: proc(builder: ^PT_Layout_Builder) {
	builder.initialize(builder.data, builder.graph) }

pt_layout_process :: proc(builder: ^PT_Layout_Builder) {
	builder.process(builder.data, builder.graph) }

pt_layout_post_process :: proc(builder: ^PT_Layout_Builder) {
	builder.post_process(builder.data, builder.graph) }

PT_Random_Layout_Builder_Config :: struct {
	max_steps: int,
	radius: f32 }

PT_Random_Layout_Builder :: struct {
	using config: PT_Random_Layout_Builder_Config,
	steps: int,
	_: u8 }

pt_random_point :: proc(graph: ^Plot_Graph) -> [2]f32 {
	return {
		rand.float32_range(rect_left(graph.plot_rect), rect_right(graph.plot_rect)),
		rand.float32_range(rect_bottom(graph.plot_rect), rect_top(graph.plot_rect)) } }

pt_random_layout_initialize :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Random_Layout_Builder = auto_cast data
	for &node in graph.nodes do node.position = pt_random_point(graph) }

pt_random_layout_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Random_Layout_Builder = auto_cast data }

pt_random_layout_post_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Random_Layout_Builder = auto_cast data }

pt_random_layout_builder :: proc(graph: ^Plot_Graph, config: PT_Random_Layout_Builder_Config) -> PT_Layout_Builder {
	builder := new(PT_Random_Layout_Builder)
	builder.config = config
	return {
		variant=.Random,
		data=cast(rawptr)builder,
		graph=graph,
		initialize=pt_random_layout_initialize,
		process=pt_random_layout_process,
		post_process=pt_random_layout_post_process } }

PT_Eades_Layout_Builder_Config :: struct {
	// (TODO): Implement these parameters. //
	c1: f32,
	c2: f32,
	c3: f32,
	steps: u32 }

PT_Eades_Layout_Builder :: struct {
	using config: PT_Eades_Layout_Builder_Config,
	momentums: [][2]f32,
	forces: [][2]f32,
	allocator: runtime.Allocator }

pt_eades_layout_initialize :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Eades_Layout_Builder = auto_cast data
	builder.momentums = make([][2]f32, len(graph.nodes), builder.allocator)
	builder.forces = make([][2]f32, len(graph.nodes), builder.allocator)
	for &node in graph.nodes do node.position = pt_random_point(graph) }

pt_eades_layout_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	spring_force :: proc(source: [2]f32, target: [2]f32, distance, c1, c2: f32) -> [2]f32 {
		if distance == 0 do return 0
		force := linalg.normalize(source - target) * (c1 * math.log10_f32(distance / c2 + 1))
		// log.info(distance, force)
		return force }
	repulsion_force :: proc(source: [2]f32, target: [2]f32, distance, c3: f32) -> [2]f32 {
		if distance == 0 do return 0
		force := linalg.normalize(target - source) * (c3 / math.sqrt_f32(distance))
		// log.warn(distance, force)
		return force }
	builder: ^PT_Eades_Layout_Builder = auto_cast data
	for i in 0 ..< builder.steps {
		for &node, i in graph.nodes {
			builder.forces[i] = 0
			for &other_node, j in graph.nodes {
				distance := linalg.distance(node.position.([2]f32), other_node.position.([2]f32))
				if poset_connected(&graph.graph, cast(u32)i, cast(u32)j) {
					builder.forces[i] += spring_force(other_node.position.([2]f32), node.position.([2]f32), distance,  0.0001, 1.0) }
				// else {
					builder.forces[i] += repulsion_force(other_node.position.([2]f32), node.position.([2]f32), distance,  0.0000005) } //}
			builder.momentums[i] += builder.forces[i] }
		for &node, i in graph.nodes {
			node.position = (node.position.([2]f32) or_else [2]f32{ 0, 0 }) + builder.momentums[i]
			builder.momentums[i] *= 0.99 } } }

pt_node_positions :: proc(graph: ^Plot_Graph, allocator := context.allocator) -> [][2]f32 {
	points := make([][2]f32, len(graph.nodes), allocator)
	for node, i in graph.nodes do points[i] = node.position.([2]f32)
	return points }

pt_fit_post_process :: proc(graph: ^Plot_Graph) {
	points := pt_node_positions(graph)
	domain := points_bounding_rect(points)
	range := ui_rect_margins(ui_rect_fit(domain, graph.plot_rect.size, .CONTAIN), Ratio(0.1))
	for &node, i in graph.nodes do node.position = rect_to_rect_map(domain, range, node.position.([2]f32)) }

pt_eades_layout_post_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Eades_Layout_Builder = auto_cast data
	pt_fit_post_process(graph) }

pt_edge_hovered :: proc(graph: ^Plot_Graph, edge: Plot_Edge) -> bool {
	if graph.hovered_node == nil do return false
	hovered_id := graph.hovered_node.id
	return edge.ids[0] == hovered_id || edge.ids[1] == hovered_id }

pt_eades_layout_builder :: proc(graph: ^Plot_Graph, config: PT_Eades_Layout_Builder_Config, allocator := context.allocator) -> PT_Layout_Builder {
	builder := new(PT_Eades_Layout_Builder, allocator)
	builder.config = config
	builder.allocator = allocator
	return {
		variant=.Eades,
		data=cast(rawptr)builder,
		graph=graph,
		initialize=pt_eades_layout_initialize,
		process=pt_eades_layout_process,
		post_process=pt_eades_layout_post_process } }

PT_Permuter_Layout_Builder_Config :: struct {
	steps: u32,
	distance: f32 }

PT_Permuter_Layout_Builder :: struct {
	using config: PT_Permuter_Layout_Builder_Config,
	allocator: runtime.Allocator,
	grid_x: [2]i32,
	grid_y: [2]i32,
	// DICK
	// grid_nodes: []Plot_Node,
	occupancy: Bit_Matrix }

pt_swap_node_positions :: proc(node0, node1: ^Plot_Node) {
	temp := node0.position
	node0.position = node1.position
	node1.position = temp }

pt_permuter_layout_initialize :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Permuter_Layout_Builder = auto_cast data
	radius: f32 = 0.05
	position: [2]f32 = { 0, 0 }
	rows: i32 = i32(1.2 * math.sqrt_f32(cast(f32)len(graph.nodes)))
	cols: i32 = cast(i32)len(graph.nodes) / rows
	for &node, i in graph.nodes {
		x := i32(i) % rows
		y := i32(i) / rows
		node.position = [2]f32{ f32(x), f32(y) } }
	builder.grid_x = { 0, rows - 1 }
	builder.grid_y = { 0, cols - 1 }
	builder.occupancy = make_bit_matrix({ cast(u32)rows, cast(u32)cols }, builder.allocator)
	bit_matrix_fill(&builder.occupancy, 1)
	log.infof("\n%s", aprint_bit_matrix(&builder.occupancy))
	log.info(bit_matrix_rank(&builder.occupancy, 0), bit_matrix_rank(&builder.occupancy, 1), bit_matrix_size(&builder.occupancy))
	// (NOTE): Objective function is "pt_total_edge_length"
	// for step in 0 ..< 100 {
		// DICK
	// }
	// for &node, i in graph.nodes {
	// 	node.position = [2]f32{ 0, 0 }
	// 	for angle: f32 = 0; angle < 2 * math.PI; angle += 0.3 {
	// 		collided: bool = false
	// 		new_position: [2]f32 = position + angle_vec(angle, radius)
	// 		for &other_node in graph.nodes[0:i] {
	// 			if linalg.distance(new_position, other_node.position.([2]f32)) < radius {
	// 				collided = true
	// 				break } }
	// 		if ! collided {
	// 			node.position = new_position
	// 			position = node.position.([2]f32)
	// 			break
	// 		}
	// 	}
	// }
}

pt_permuter_layout_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Permuter_Layout_Builder = auto_cast data
	current_length := pt_total_edge_length(graph)
	node := &graph.nodes[rand.int31_max(cast(i32)len(graph.nodes))]
	for &other_node in graph.nodes {
		if &other_node == node do continue
		pt_swap_node_positions(node, &other_node)
		new_length := pt_total_edge_length(graph)
		if new_length < current_length do break
		pt_swap_node_positions(node, &other_node) }
	// if _bit_matrix_rank(&builder.occupancy, 1) = _bit_matrix_size(&builder.occupancy) {
	// 	builder.grid_x += { -1, 1 }
	// 	builder.grid_y += { -1, 1 }
	// 	// DICK
	// }
	// (TODO): Keep a bit matrix record of the occupation of the grid.
	// * check if grid is all 1s, if so extend grid by 1
	// * pick random tile from grid, adjacent to exitsing node
	// * iterate through nodes and see if any of them can be placed there to reduce objective function
}

pt_permuter_layout_post_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_Permuter_Layout_Builder = auto_cast data
	pt_fit_post_process(graph) }

pt_permuter_layout_builder :: proc(graph: ^Plot_Graph, config: PT_Permuter_Layout_Builder_Config, allocator := context.allocator) -> PT_Layout_Builder {
	builder := new(PT_Permuter_Layout_Builder, allocator)
	builder.config = config
	builder.allocator = allocator
	return {
		variant=.Permuter,
		data=cast(rawptr)builder,
		graph=graph,
		initialize=pt_permuter_layout_initialize,
		process=pt_permuter_layout_process,
		post_process=pt_permuter_layout_post_process } }

pt_total_edge_length :: proc(graph: ^Plot_Graph) -> f32 {
	length: f32
	for edge in graph.edges do length += pt_edge_length(graph, edge)
	return length }


// pt_fdp_layout_builder :: proc(graph: ^Plot_Graph) {
// 	initialize: {
// 		fdp_init_graph(graph);
// 	}

// 	process: {
// 		if (fdpLayout(graph) != 0) {
// 		return;
// 		}
// 		neato_set_aspect(graph);
// 		if (EDGE_TYPE(graph) != EDGETYPE_NONE) fdpSplines (graph);
// 	}

// 	post_process: {
// 		gv_postprocess(graph, 0);
// 	}
// }
