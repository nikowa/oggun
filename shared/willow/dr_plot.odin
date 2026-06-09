#+feature using-stmt
package willow

// (TODO): Create a "Camera_2D" type for mapping points to the screen. //

dr_plot_node :: proc(plot_node: ^Plot_Node, graph: ^Plot_Graph) {
	rect: Rect
	rect.position = plot_node.position.([2]f32) or_else { 0, 0 }
	if plot_node.size == nil do rect.size = { 80, 40 }
	else {
		rect.size = plot_node.size.([2]f32)
		if rect.size.y == 0 do rect.size.y = gi_measure_text_box(plot_node.label, rect.size.x) }
	text_rect := rect
	rect = gi_rect_extend(rect, Interval(graph.padding))

	dr_rect(
		rect=rect,
		fill_color=plot_node.background_color,
		stroke_color=plot_node.stroke_color,
		radius=graph.radius,
		stroke=1)
	dr_text_box(
		rect=text_rect,
		text=plot_node.label)
	xlabel_rect := gi_rect_top_to(gi_rect_resize(rect, { rect.size.x, cast(f32)graph.text_style.font_size }), rect_bottom(rect))
	xlabel_rect = gi_rect_translate(xlabel_rect, { 0, -graph.margins })
	dr_text_box(
		rect=xlabel_rect,
		text=plot_node.xlabel)

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
