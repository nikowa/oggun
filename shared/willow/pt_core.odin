#+feature using-stmt
package willow

Plot_Graph_Config :: struct {
	default_background_color: Color,
	default_stroke_color: Color,
	light_foreground_color: Color,
	dark_foreground_color: Color,
	text_style: Text_Style,
	margins: f32,
	padding: f32,
	radius: f32,
	range_x: [2]f32,
	range_y: [2]f32 }

DEFAULT_PLOT_GRAPH_CONFIG: Plot_Graph_Config : {
	default_background_color=COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK,
	default_stroke_color=COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
	light_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_DARK,
	dark_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
	text_style=DEFAULT_TEXT_STYLE,
	margins=4,
	padding=4,
	radius=4,
	range_x={ -1, 1 },
	range_y={ -1, 1 } }

Plot_Graph :: struct {
	using config: Plot_Graph_Config,
	nodes: [dynamic]Plot_Node }

Plot_Node :: struct {
	// (TODO): Put these in "Plot_Node_Config". //
	id: u32,
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

pt_graph_init :: proc(plot_graph: ^Plot_Graph, config: Plot_Graph_Config) {
	plot_graph.config = config
	plot_graph.nodes = make([dynamic]Plot_Node) }

pt_append_node :: proc(plot_graph: ^Plot_Graph, node: Plot_Node) -> (ptr: ^Plot_Node) {
	append(&plot_graph.nodes, node)
	return &plot_graph.nodes[len(plot_graph.nodes) - 1] }
