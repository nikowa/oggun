#+feature using-stmt
package oggun

ui_rect_hovered :: proc(r: Rect) -> bool {
	return rect_contains_point(r, engine.input_manager.mouse_position) }

ui_rect_sect :: proc(a, b: Rect) -> (c: Rect) {
	a_left, a_right, a_bottom, a_top := rect_sides(a)
	b_left, b_right, b_bottom, b_top := rect_sides(b)
	return rect_from_sides(
		left   = max(a_left, b_left),
		right  = min(a_right, b_right),
		bottom = max(a_bottom, b_bottom),
		top    = min(a_top, b_top)) }

ui_rect_union :: proc(a, b: Rect) -> (c: Rect) {
	a_left, a_right, a_bottom, a_top := rect_sides(a)
	b_left, b_right, b_bottom, b_top := rect_sides(b)
	return rect_from_sides(
		left   = min(a_left, b_left),
		right  = max(a_right, b_right),
		bottom = min(a_bottom, b_bottom),
		top    = max(a_top, b_top)) }

ui_rect_interpolate :: proc(r: Rect, t: [2]f32) -> (p: [2]f32) {
	return {
		math.lerp(rect_left(r), rect_right(r), t.x),
		math.lerp(rect_bottom(r), rect_top(r), t.y) } }

ui_rect_interpolate_centered :: proc(r: Rect, t: [2]f32) -> (p: [2]f32) {
	return ui_rect_interpolate(r, (t + { 1, 1 }) / 2) }

ui_rect_fit :: proc(rect, container: Rect, fit: UI_Fit) -> (result: Rect) {
	switch fit {
	case .NONE:
		return { container.position, rect.size }
	case .FILL:
		return container
	case .COVER:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		result = container
		if container_ratio < rect_ratio do result.size.x = rect_ratio * result.size.y
		else do result.size.y = result.size.x / rect_ratio
		return result
	case .CONTAIN:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		result = container
		if container_ratio > rect_ratio do result.size.x = rect_ratio * result.size.y
		else do result.size.y = result.size.x / rect_ratio
		return result
	case .SCALE_DOWN:
		variant_a := ui_rect_fit(rect, container, .CONTAIN)
		variant_b := ui_rect_fit(rect, container, .NONE)
		if variant_a.size.x < variant_b.size.x do return variant_a
		else do return variant_b }
	return result }

ui_rect_embed :: proc(rect: Rect, size: [2]f32, pivot: bit_set[Compass] = {}) -> (result: Rect) {
	result = { rect.position, size }
	delta: [2]f32 = rect.size / 2 - size / 2
	if .East in pivot do result.position.x += delta.x
	if .West in pivot do result.position.x -= delta.x
	if .North in pivot do result.position.y += delta.y
	if .South in pivot do result.position.y -= delta.y
	return result }

ui_rect_margins :: proc { ui_rect_margins_i, ui_rect_margins_r }

ui_rect_margins_i :: proc(rect: Rect, margin: Interval) -> (result: Rect) {
	result = rect
	result.size.x -= f32(margin) * 2
	result.size.y -= f32(margin) * 2
	return result }

ui_rect_margins_r :: proc(rect: Rect, margin: Ratio) -> (result: Rect) {
	result = rect
	result.size.x -= f32(margin) * result.size.x * 2
	result.size.y -= f32(margin) * result.size.y * 2
	return result }

ui_rect_margins_variate :: proc { ui_rect_margins_variate_r, ui_rect_margins_variate_i }

ui_rect_margins_variate_r :: proc(rect: Rect, west: Ratio = 0, east: Ratio = 0, south: Ratio = 0, north: Ratio = 0) -> (result: Rect) {
	return ui_rect_margins_variate_i(rect,
		Interval(f32(west) * rect.size.x), Interval(f32(east) * rect.size.x),
		Interval(f32(south) * rect.size.y), Interval(f32(north) * rect.size.y)) }

ui_rect_margins_variate_i :: proc(rect: Rect, west: Interval = 0, east: Interval = 0, south: Interval = 0, north: Interval = 0) -> (result: Rect) {
	result = rect

	result.size.x -= f32(west)
	result.position.x += f32(west) / 2

	result.size.x -= f32(east)
	result.position.x -= f32(east) / 2

	result.size.y -= f32(south)
	result.position.y += f32(south) / 2

	result.size.y -= f32(north)
	result.position.y -= f32(north) / 2

	return result }

ui_rect_extend :: proc { ui_rect_extend_i, ui_rect_extend_r }

ui_rect_extend_i :: proc(rect_in: Rect, extent: Interval) -> (result: Rect) {
	return ui_rect_margins_i(rect_in, -extent) }

ui_rect_extend_r :: proc(rect_in: Rect, extent: Ratio) -> (result: Rect) {
	return ui_rect_extend_r(rect_in, -extent) }

ui_rect_extend_variate :: proc { ui_rect_extend_variate_r, ui_rect_extend_variate_i }

ui_rect_extend_variate_r :: proc(rect: Rect, west: Ratio = 0, east: Ratio = 0, south: Ratio = 0, north: Ratio = 0) -> (result: Rect) {
	return ui_rect_margins_variate_r(rect, -west, -east, -south, -north) }

ui_rect_extend_variate_i :: proc(rect: Rect, west: Interval = 0, east: Interval = 0, south: Interval = 0, north: Interval = 0) -> (result: Rect) {
	return ui_rect_margins_variate_i(rect, -west, -east, -south, -north) }
