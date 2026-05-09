#+feature using-stmt
package rect

Rect :: struct #packed {
	pos:  [2]f32,
	size: [2]f32 }

left :: proc(rect: Rect) -> f32 {
	return rect.pos.x - rect.size.x / 2 }

right :: proc(rect: Rect) -> f32 {
	return rect.pos.x + rect.size.x / 2 }

bottom :: proc(rect: Rect) -> f32 {
	return rect.pos.y - rect.size.y / 2 }

top :: proc(rect: Rect) -> f32 {
	return rect.pos.y + rect.size.y / 2 }

contains_point :: proc(rect: Rect, point: [2]f32) -> bool {
	return in_range(point.x, rect.pos.x - rect.size.x / 2, rect.pos.x + rect.size.x / 2) &&
		   in_range(point.y, rect.pos.y - rect.size.y / 2, rect.pos.y + rect.size.y / 2) }

make_rect :: proc(pos_x, pos_y, size_x, size_y: f32) -> Rect {
	return Rect{ { pos_x, pos_y }, { size_x, size_y } } }

@(private)
in_range :: proc(x: f32, lo: f32, hi: f32) -> bool {
	return (x >= lo) && (x <= hi) }
