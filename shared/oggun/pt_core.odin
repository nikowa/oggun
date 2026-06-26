#+feature using-stmt
package oggun
import "core:math/rand"
import "core:log"

Plot_Graph_Config :: struct {
	default_background_color: Color,
	default_stroke_color: Color,
	light_foreground_color: Color,
	dark_foreground_color: Color,
	// (TODO): Add "xlabel_color" maybe?
	text_style: Text_Style,
	margins: f32,
	padding: f32,
	edge_margins: f32,
	radius: f32,
	range_x: [2]f32,
	range_y: [2]f32,
	arrowhead_size: UI_Size,
	orientation: Orientation,
	arrowhead: bool }

DEFAULT_PLOT_GRAPH_CONFIG: Plot_Graph_Config : {
	default_background_color=COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK,
	default_stroke_color=COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
	light_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_DARK,
	dark_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
	text_style=DEFAULT_TEXT_STYLE,
	margins=4,
	padding=4,
	edge_margins=0,
	radius=4,
	range_x={ -1, 1 },
	range_y={ -1, 1 },
	arrowhead_size=.M,
	orientation=.Vertical,
	arrowhead=true }

Plot_Graph :: struct {
	using config: Plot_Graph_Config,
	nodes: [dynamic]Plot_Node,
	edges: [dynamic]Plot_Edge,
	nodes_map: map[ID]^Plot_Node }

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

pt_graph_init :: proc(graph: ^Plot_Graph, config: Plot_Graph_Config) {
	graph.config = config
	graph.nodes = make([dynamic]Plot_Node)
	graph.edges = make([dynamic]Plot_Edge)
	graph.nodes_map = make(map[ID]^Plot_Node) }

pt_append_node :: proc(graph: ^Plot_Graph, node: Plot_Node) -> (ptr: ^Plot_Node) {
	append(&graph.nodes, node)
	ptr = &graph.nodes[len(graph.nodes) - 1]
	graph.nodes_map[node.id] = ptr
	return ptr }

pt_append_edge :: proc(graph: ^Plot_Graph, edge: Plot_Edge) -> (ptr: ^Plot_Edge) {
	append(&graph.edges, edge)
	return &graph.edges[len(graph.edges) - 1] }

PT_Layout_Builder_Variant :: enum {
	NUDGE,
	DOT,
	FDP,
	NEATO,
	OSAGE,
	PATCHWORK }

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

PT_FDP_Layout_Builder :: struct {
	_: u8 }

pt_fdp_layout_initialize :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_FDP_Layout_Builder = auto_cast data }

pt_fdp_layout_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_FDP_Layout_Builder = auto_cast data }

pt_fdp_layout_post_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_FDP_Layout_Builder = auto_cast data }

pt_fdp_layout_builder :: proc() -> PT_Layout_Builder {
	return {
		variant=.FDP,
		data=cast(rawptr)new(PT_FDP_Layout_Builder),
		initialize=pt_fdp_layout_initialize,
		process=pt_fdp_layout_process,
		post_process=pt_fdp_layout_post_process } }

PT_NUDGE_Layout_Builder_Config :: struct {
	max_steps: int,
	radius: f32 }

PT_NUDGE_Layout_Builder :: struct {
	using config: PT_NUDGE_Layout_Builder_Config,
	steps: int,
	_: u8 }

pt_nudge_layout_initialize :: proc(data: rawptr, graph: ^Plot_Graph) {
	log.info("initializing")
	builder: ^PT_NUDGE_Layout_Builder = auto_cast data
	for &node in graph.nodes {
		node.position = [2]f32{
			rand.float32_range(graph.range_x[0], graph.range_x[1]),
			rand.float32_range(graph.range_y[0], graph.range_y[1]) } } }

pt_nudge_layout_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_NUDGE_Layout_Builder = auto_cast data }

pt_nudge_layout_post_process :: proc(data: rawptr, graph: ^Plot_Graph) {
	builder: ^PT_NUDGE_Layout_Builder = auto_cast data }

pt_nudge_layout_builder :: proc(graph: ^Plot_Graph, config: PT_NUDGE_Layout_Builder_Config) -> PT_Layout_Builder {
	builder := new(PT_NUDGE_Layout_Builder)
	builder.config = config
	return {
		variant=.NUDGE,
		data=cast(rawptr)builder,
		graph=graph,
		initialize=pt_nudge_layout_initialize,
		process=pt_nudge_layout_process,
		post_process=pt_nudge_layout_post_process } }

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
