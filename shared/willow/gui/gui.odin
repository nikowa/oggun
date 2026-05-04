#+feature using-stmt
package gui
import "../container/rect"

margins :: proc(rect_in: rect.Rect, margins: f32) -> (rect_out: rect.Rect) {
	rect_out = rect_in
	rect_out.pos.x += margins
	rect_out.pos.y += margins
	rect_out.size.x -= margins * 2
	rect_out.size.y -= margins * 2
	return rect_out }

// u_rect_split_h :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_left: Rect, rect_right: Rect) {
// 	rect_left = rect_in
// 	rect_right = rect_in
// 	rect_left.size.x = rect_in.size.x * ratio
// 	rect_right.size.x = rect_in.size.x * (1.0 - ratio)
// 	rect_right.pos.x += rect_left.size.x
// 	rect_left.size.x -= margin / 2
// 	rect_right.size.x -= margin / 2
// 	rect_right.pos.x += margin / 2
// 	return rect_left, rect_right }

// u_rect_split_v :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_top: Rect, rect_bottom: Rect) {
// 	rect_top = rect_in
// 	rect_bottom = rect_in
// 	rect_top.size.y = rect_in.size.y * ratio
// 	rect_bottom.size.y = rect_in.size.y * (1.0 - ratio)
// 	rect_bottom.pos.y += rect_top.size.y
// 	rect_top.size.y -= margin / 2
// 	rect_bottom.size.y -= margin / 2
// 	rect_bottom.pos.y += margin / 2
// 	return rect_top, rect_bottom }

// u_rect_grid :: proc(rect_in: Rect, size: [2]int) -> (rects_out: [][]Rect) {
// 	rects_out = make([][]Rect, size.x)
// 	rect_width: f32 = rect_in.size.x / cast(f32)size.x
// 	rect_height: f32 = rect_in.size.y / cast(f32)size.y
// 	for _, i in 0 ..< size.x do rects_out[i] = make([]Rect, size.y)
// 	for _, i in 0 ..< size.x do for _, j in 0 ..< size.y {
// 		rect := &rects_out[i][j]
// 		rect^ = rect_in
// 		rect.pos.x += rect_width * cast(f32)i
// 		rect.pos.y += rect_height * cast(f32)j
// 		rect.size.x = rect_width
// 		rect.size.y = rect_height }
// 	return rects_out }

// u_screen_rect :: proc() -> Rect {
// 	return Rect{ 0.0, 0.0, state.resolution.x, state.resolution.y } }

// u_rect_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
// 	center := rect_center(rect_in)
// 	rect_out = Rect{
// 		x = center.pos.x - rect_in.size.y / 2,
// 		y = center.pos.y - rect_in.size.x / 2,
// 		width = rect_in.size.y,
// 		height = rect_in.size.x }
// 	return rect_out }

// u_grid :: proc(mask_rect: Rect) {

// 	// grid_size
// }

// u_begin_playarea :: proc() {
// 	raylib.BeginTextureMode(state.playarea_texture)
// 	raylib.BeginBlendMode(.ALPHA) }

// u_end_playarea :: proc() {
// 	raylib.EndBlendMode()
// 	raylib.EndTextureMode() }

// u_mask_grid :: proc() {
// 	for i in 0 ..< len(state.rect_mask_grid) do for j in 0 ..< len(state.rect_mask_grid[0]) {
// 		rect := state.rect_mask_grid[i][j]
// 		hovered := u_hover_rect(rect)
// 		if state.grabbed_mask_class != "" do for point, i in state.grabbed_mask_points {
// 			if state.grabbed_mask_shape[i] == 1 do if u_point_inside_rect(rect, point) do hovered = true }
// 		g_draw_rect_lines(rect, hovered ? YELLOW : BLACK) } }

// u_hover_rect :: proc(rect: Rect) -> bool {
// 	return raylib.CheckCollisionPointRec(state.mouse_pos, rect) }

// u_point_inside_rect :: proc(rect: Rect, point: [2]f32) -> bool {
// 	return raylib.CheckCollisionPointRec(point, rect) }

// u_rect_around_point :: proc(point: [2]f32, size: [2]f32) -> Rect {
// 	return Rect{ point.x - size.x / 2, point.y - size.y / 2, size.x, size.y } }
