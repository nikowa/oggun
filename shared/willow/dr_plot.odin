#+feature using-stmt
package willow
import "core:log"
import "core:math"

// (TODO): Create a "Camera_2D" type for mapping points to the screen. //

dr_plot_node :: proc(plot_node: ^Plot_Node, graph: ^Plot_Graph, position: [2]f32, scale: f32) -> (size: [2]f32) {
	rect: Rect
	rect.position = position
	// rect.position = plot_node.position.([2]f32) or_else { 0, 0 }
	if plot_node.size == nil {
		rect.size = PT_DEFAULT_NODE_SIZE
		rect = rect_scale(rect, { scale, scale }) }
	else {
		rect.size = plot_node.size.([2]f32)
		rect = rect_scale(rect, { scale, scale })
		if rect.size.y == 0 do rect.size.y = ui_measure_text_box(plot_node.label, rect.size.x) }
	text_rect := rect
	rect = rect_extend(rect, Interval(graph.padding))
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
	{	ui_text_style_scope(text_style)
		dr_text_box(
			rect=text_rect,
			text=plot_node.label, integer=true) }
	xlabel_rect := rect_top_to(rect_resize(rect, { rect.size.x, cast(f32)graph.text_style.font_size }), rect_bottom(rect))
	xlabel_rect = rect_translate(xlabel_rect, { 0, -graph.margins })
	dr_text_box(
		rect=xlabel_rect,
		text=plot_node.xlabel, integer=true)
	return rect.size }

dr_plot_graph :: proc(graph: ^Plot_Graph, camera: ^Camera_2D, rect: Rect) {
	scale := sn_camera_2d_scale(camera)
	// range_x
	scale *= rect.size
	dr_rect_outline(sn_camera_2d_map_rect(camera, rect, camera.initial_rect), WHITE)
	for &plot_node in graph.nodes {
		gx_depth_scope(0.5)
		position: [2]f32 = plot_node.position.([2]f32) or_else { 0, 0 }
		// (TODO): The following two lines break the camera panning. Why? //
		position.x = math.lerp(
			rect_left(camera.initial_rect),
			rect_right(camera.initial_rect),
			math.unlerp(graph.range_x[0], graph.range_x[1], position.x))
		position.y = math.lerp(
			rect_bottom(camera.initial_rect),
			rect_top(camera.initial_rect),
			math.unlerp(graph.range_y[0], graph.range_y[1], position.y))
		position = sn_camera_2d_map_point(camera, rect, position)
		size := dr_plot_node(&plot_node, graph, position, scale.y)
		plot_node._rect = { position, size } }
	gx_depth_scope(0.1)
	for edge in graph.edges do dr_plot_edge(graph, edge, graph.margins, graph.radius, edge.stroke_color) }

rectilinear_vectors_are_antiparallel :: proc(vecs: [2][2]f32) -> bool {
	if (vecs[0].x == vecs[1].x) && (math.sign(vecs[0].y) == -math.sign(vecs[1].y)) do return true
	if (vecs[0].y == vecs[1].y) && (math.sign(vecs[0].x) == -math.sign(vecs[1].x)) do return true
	return false }

dr_plot_edge :: proc(graph: ^Plot_Graph, edge: Plot_Edge, margin: f32, radius: f32, color: Color=WHITE) {
	// (TODO): Implement "edge.xlabel" //
	nodes: [2]^Plot_Node
	nodes[0], _ = graph.nodes_map[edge.ids[0]]
	nodes[1], _ = graph.nodes_map[edge.ids[1]]
	sides: [2]Compass
	switch graph.orientation {
	case .Horizontal:
		if nodes[0]._rect.position.x < nodes[1]._rect.position.x do sides = { .East, .West }
		else do sides = { .West, .East }
	case .Vertical, .None:
		if nodes[0]._rect.position.y < nodes[1]._rect.position.y do sides = { .North, .South }
		else do sides = { .South, .North } }
	// DICK
	rects: [2]Rect = { rect_extend(nodes[0]._rect, Interval(graph.edge_margins)), rect_extend(nodes[1]._rect, Interval(graph.edge_margins)) }
	a, b := rect_side(rects[0], sides[0]), rect_side(rects[1], sides[1])
	a1, b1 := a + margin * compass_normal(sides[0]), b + margin * compass_normal(sides[1])
	c: [2]f32 = { a1.x, b1.y }
	if rectilinear_vectors_are_antiparallel({ c - a, a1 - a }) ||
	   rectilinear_vectors_are_antiparallel({ c - b, b1 - b }) { c = { b1.x, a1.y } }
	dr_path_rounded({ a, a1, c, b1, b }, radius=radius, color=color, integer=true)
	if graph.arrowhead do dr_arrow_rectilinear(b, compass_invert(sides[1]), color, graph.arrowhead_size) }

dr_plot_edge_horizontal :: proc(a: Rect, b: Rect, margin: f32, color: Color=WHITE) {
	distance := rect_distance(a, b)
	if (distance.x < 2 * margin) || (distance.y < 2 * margin) do return
	positions: [2][2]f32
	py: f32 = a.size.x >= b.size.x ? a.position.y : b.position.y
	if a.position.x > b.position.x do positions = { rect_left_point(a), rect_right_point(b) }
	else do positions = { rect_left_point(b), rect_right_point(a) }
	dr_edge_horizontal(positions[0], positions[1], margin, py, color) }

dr_edge_vertical :: proc(a: [2]f32, b: [2]f32, margin: f32, px: f32, color: Color) {
	if a.y > b.y do _dr_edge_vertical(a, b, margin, px, color)
	else do _dr_edge_vertical(b, a, margin, px, color) }

_dr_edge_vertical :: proc(a: [2]f32, b: [2]f32, margin: f32, px: f32, color: Color) {
	a1 := a + { 0, -margin }
	a2 := a1
	a2.x = px
	b1 := b + { 0, margin }
	b2 := b1
	b2.x = px
	if px == a.x do dr_path_rounded({ a, b2, b1, b }, radius=8, color=color, integer=true)
	if px == b.x do dr_path_rounded({ a, a1, a2, b }, radius=8, color=color, integer=true)
	dr_path_rounded({ a, a1, a2, b2, b1, b }, radius=8, color=color, integer=true) }

dr_edge_horizontal :: proc(a: [2]f32, b: [2]f32, margin: f32, py: f32, color: Color=WHITE) {
	a1 := a + { -margin, 0 }
	a2 := a1
	a2.y = py
	b1 := b + { margin, 0 }
	b2 := b1
	b2.y = py
	if py == a.y do dr_path_rounded({ a, b2, b1, b }, radius=8, color=color, integer=true)
	if py == b.y do dr_path_rounded({ a, a1, a2, b }, radius=8, color=color, integer=true)
	dr_path_rounded({ a, a1, a2, b2, b1, b }, radius=8, color=color, integer=true) }
