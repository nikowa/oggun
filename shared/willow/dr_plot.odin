#+feature using-stmt
package willow

// (TODO): Create a "Camera_2D" type for mapping points to the screen. //

dr_plot_node :: proc(plot_node: ^Plot_Node, graph: ^Plot_Graph, position: [2]f32, scale: f32) {
	rect: Rect
	rect.position = position
	// rect.position = plot_node.position.([2]f32) or_else { 0, 0 }
	if plot_node.size == nil do rect.size = { 80, 40 }
	else {
		rect.size = plot_node.size.([2]f32)
		if rect.size.y == 0 do rect.size.y = gi_measure_text_box(plot_node.label, rect.size.x) }
	rect = gi_rect_scale(rect, { scale, scale })
	text_rect := rect
	rect = gi_rect_extend(rect, Interval(graph.padding))
	background_color: Color = plot_node.background_color if plot_node.background_color != 0 else graph.default_background_color
	stroke_color: Color = plot_node.stroke_color if plot_node.stroke_color != 0 else graph.default_stroke_color
	dr_rect(
		rect=rect,
		fill_color=background_color,
		stroke_color=stroke_color,
		radius=graph.radius,
		stroke=1)
	text_style := graph.text_style
	text_style.color = gx_color_is_light(background_color) ? graph.dark_foreground_color : graph.light_foreground_color
	{	gi_text_style_scope(text_style)
		dr_text_box(
			rect=text_rect,
			text=plot_node.label, integer=true) }
	xlabel_rect := gi_rect_top_to(gi_rect_resize(rect, { rect.size.x, cast(f32)graph.text_style.font_size }), rect_bottom(rect))
	xlabel_rect = gi_rect_translate(xlabel_rect, { 0, -graph.margins })
	dr_text_box(
		rect=xlabel_rect,
		text=plot_node.xlabel, integer=true)

	// Plot_Node :: struct {
	// 	id: u32,
	// 	class: string,
	// 	background_color: Color,
	// 	foreground_color: Color,
	// 	stroke_color: Color,
	// 	size: Maybe([2]f32),
	// 	label: string,
	// 	position: Maybe([2]f32),
	// 	pin: bool,
	// 	root: bool,
	// 	radius: f32,
	// 	tooltip: string,
	// 	xlabel: string }
}

dr_plot_graph :: proc(plot_graph: ^Plot_Graph, rect: Rect) {
	for &plot_node in plot_graph.nodes {
		dr_plot_node(&plot_node, plot_graph, plot_node.position.([2]f32) or_else { 0, 0 }, 1.0)
	}
}
