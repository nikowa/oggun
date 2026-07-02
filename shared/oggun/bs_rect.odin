#+feature using-stmt
package oggun
import "core:math"
import "base:runtime"
import "core:math/linalg"
import "core:log"

Rect :: struct #packed {
	position: [2]f32,
	size:     [2]f32 }

Rect_Range :: [2][2]f32

rect_range :: proc(rect: Rect) -> Rect_Range {
	return { rect_bottom_left_point(rect), rect_top_right_point(rect) } }

rect_from_range :: proc(range: Rect_Range) -> Rect {
	bottom_left := range[0]
	top_right := range[1]
	return rect_from_sides(bottom_left[0], top_right[0], bottom_left[1], top_right[1]) }

make_rect :: proc(position_x, position_y, size_x, size_y: f32) -> Rect {
	return Rect{ { position_x, position_y }, { size_x, size_y } } }

rect_left :: proc(rect: Rect) -> f32 {
	return rect.position.x - rect.size.x / 2 }

rect_left_point :: proc(rect: Rect) -> [2]f32 {
	return { rect.position.x - rect.size.x / 2, rect.position.y } }

rect_right :: proc(rect: Rect) -> f32 {
	return rect.position.x + rect.size.x / 2 }

rect_right_point :: proc(rect: Rect) -> [2]f32 {
	return { rect.position.x + rect.size.x / 2, rect.position.y } }

rect_bottom :: proc(rect: Rect) -> f32 {
	return rect.position.y - rect.size.y / 2 }

rect_bottom_point :: proc(rect: Rect) -> [2]f32 {
	return { rect.position.x, rect.position.y - rect.size.y / 2 } }

rect_top :: proc(rect: Rect) -> f32 {
	return rect.position.y + rect.size.y / 2 }

rect_top_point :: proc(rect: Rect) -> [2]f32 {
	return { rect.position.x, rect.position.y + rect.size.y / 2 } }

rect_top_left_point :: proc(rect: Rect) -> [2]f32 {
	return { rect_left(rect), rect_top(rect) } }

rect_top_right_point :: proc(rect: Rect) -> [2]f32 {
	return { rect_right(rect), rect_top(rect) } }

rect_bottom_left_point :: proc(rect: Rect) -> [2]f32 {
	return { rect_left(rect), rect_bottom(rect) } }

rect_bottom_right_point :: proc(rect: Rect) -> [2]f32 {
	return { rect_right(rect), rect_bottom(rect) } }

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

rect_to_4f32 :: proc(rect: Rect) -> [4]f32 {
	return { rect.position.x, rect.position.y, rect.size.x, rect.size.y } }

rect_is_empty :: proc(rect: Rect) -> bool {
	return rect.size.x <= 0 || rect.size.y <= 0 }

rects_distance :: proc(a: Rect, b: Rect) -> (distance: [2]f32) {
	return {
		a.position.x >= b.position.x ? max(0, rect_left(a) - rect_right(b)) : max(0, rect_left(b) - rect_right(a)),
		a.position.y >= b.position.y ? max(0, rect_bottom(a) - rect_top(b)) : max(0, rect_bottom(b) - rect_top(a)) } }

rect_side :: proc(rect: Rect, side: Compass) -> [2]f32 {
	switch side {
	case .East: return rect_right_point(rect)
	case .West: return rect_left_point(rect)
	case .North: return rect_top_point(rect)
	case .South: return rect_bottom_point(rect) }
	log.error("bad")
	return rect.position }
