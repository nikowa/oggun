#+feature using-stmt
package willow

Plot_Graph_Config :: struct {
	background_color: Color,
	text_style: Text_Style,
	margins: f32,
	padding: f32,
	radius: f32 }

Plot_Graph :: struct {
	using config: Plot_Graph_Config,
	nodes: [dynamic]Plot_Node }

Plot_Node :: struct {
	id: u32,
	class: string,
	background_color: Color,
	foreground_color: Color,
	stroke_color: Color,
	size: Maybe([2]f32),
	label: string,
	position: Maybe([2]f32),
	pin: bool,
	root: bool,
	tooltip: string,
	xlabel: string }

DEFAULT_PLOT_NODE: Plot_Node : {
	id = 1,
	class = DEFAULT_NAME,
	background_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT,
	foreground_color = COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
	stroke_color = COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
	size = {},
	label = DEFAULT_NAME,
	position = {},
	pin = false,
	root = false,
	tooltip = DEFAULT_NAME,
	xlabel = DEFAULT_NAME }

pt_graph_init :: proc(plot_graph: ^Plot_Graph, config: Plot_Graph_Config) {
	plot_graph.config = config
	plot_graph.nodes = make([dynamic]Plot_Node) }
