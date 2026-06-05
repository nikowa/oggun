#+feature using-stmt
package willow
import "core:math"

Rect :: struct #packed {
	position: [2]f32,
	size:     [2]f32 }

make_rect :: proc(position_x, position_y, size_x, size_y: f32) -> Rect {
	return Rect{ { position_x, position_y }, { size_x, size_y } } }

rect_left :: proc(rect: Rect) -> f32 {
	return rect.position.x - rect.size.x / 2 }

rect_right :: proc(rect: Rect) -> f32 {
	return rect.position.x + rect.size.x / 2 }

rect_bottom :: proc(rect: Rect) -> f32 {
	return rect.position.y - rect.size.y / 2 }

rect_top :: proc(rect: Rect) -> f32 {
	return rect.position.y + rect.size.y / 2 }

rect_from_sides :: proc(left, right, bottom, top: f32) -> Rect {
	return {
		position = { (left + right) / 2, (top + bottom) / 2 },
		size = { right - left, top - bottom } } }

rect_sides :: proc(rect: Rect) -> (left, right, bottom, top: f32) {
	return rect_left(rect), rect_right(rect), rect_bottom(rect), rect_top(rect) }

rect_contains_point :: proc(rect: Rect, point: [2]f32) -> bool {
	return in_range(point.x, rect.position.x - rect.size.x / 2, rect.position.x + rect.size.x / 2) &&
		   in_range(point.y, rect.position.y - rect.size.y / 2, rect.position.y + rect.size.y / 2) }

in_range :: proc(x: f32, lo: f32, hi: f32) -> bool {
	return (x >= lo) && (x <= hi) }

rect_round :: proc(rect: Rect) -> Rect {
	rect := rect
	rect.position.x = math.round_f32(rect.position.x)
	rect.position.y = math.round_f32(rect.position.y)
	rect.size.x = math.round_f32(rect.size.x / 2) * 2
	rect.size.y = math.round_f32(rect.size.y / 2) * 2
	return rect }

rect_round_offset :: proc(rect: Rect, offset: [2]f32) -> Rect {
	rect := rect
	rect.position.x = math.round_f32(rect.position.x) + offset.x
	rect.position.y = math.round_f32(rect.position.y) + offset.y
	rect.size.x = math.round_f32(rect.size.x / 2) * 2
	rect.size.y = math.round_f32(rect.size.y / 2) * 2
	return rect }

rect_hovered :: proc(rect: Rect) -> bool {
	return rect_contains_point(rect, engine.input_manager.mouse_position) }

rect_to_4f32 :: proc(rect: Rect) -> [4]f32 {
	return { rect.position.x, rect.position.y, rect.size.x, rect.size.y } }

rect_is_empty :: proc(rect: Rect) -> bool {
	return rect.size.x <= 0 || rect.size.y <= 0 }

rect_sect :: proc(rect_a, rect_b: Rect) -> (rect: Rect) {
	a_left, a_right, a_bottom, a_top := rect_sides(rect_a)
	b_left, b_right, b_bottom, b_top := rect_sides(rect_b)
	return rect_from_sides(
		left   = max(a_left, b_left),
		right  = min(a_right, b_right),
		bottom = max(a_bottom, b_bottom),
		top    = min(a_top, b_top)) }

rect_union :: proc(rect_a, rect_b: Rect) -> (rect: Rect) {
	a_left, a_right, a_bottom, a_top := rect_sides(rect_a)
	b_left, b_right, b_bottom, b_top := rect_sides(rect_b)
	return rect_from_sides(
		left   = min(a_left, b_left),
		right  = max(a_right, b_right),
		bottom = min(a_bottom, b_bottom),
		top    = max(a_top, b_top)) }
