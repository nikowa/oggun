#+feature using-stmt
package gui
import "../container/rect"
import "../asset_manager"
import "../graphics"
import "base:runtime"
import "core:math/linalg"

rect_margins :: proc(rect_in: rect.Rect, margins: f32) -> (rect_out: rect.Rect) {
	rect_out = rect_in
	rect_out.size.x -= margins * 2
	rect_out.size.y -= margins * 2
	return rect_out }

// Rename this to "_split_ratio" and add a second one "_split_interval" which splits at a specified point on the X-axis.
rect_split_h :: proc(rect_in: rect.Rect, ratio: f32, margin: f32) -> (rect_left: rect.Rect, rect_right: rect.Rect) {
	rect_left  = rect_in
	rect_right = rect_in

	rect_left.size.x  = rect_in.size.x * ratio -         margin / 2
	rect_right.size.x = rect_in.size.x * (1.0 - ratio) - margin / 2

	rect_left.pos.x  += - rect_in.size.x / 2 + rect_left.size.x  / 2
	rect_right.pos.x +=   rect_in.size.x / 2 - rect_right.size.x / 2

	return rect_left, rect_right }

rect_split_v :: proc(rect_in: rect.Rect, ratio: f32, margin: f32) -> (rect_top: rect.Rect, rect_bottom: rect.Rect) {
	rect_top    = rect_in
	rect_bottom = rect_in

	rect_top.size.y    = rect_in.size.y * ratio -         margin / 2
	rect_bottom.size.y = rect_in.size.y * (1.0 - ratio) - margin / 2

	rect_bottom.pos.y += - rect_in.size.y / 2 + rect_bottom.size.y / 2
	rect_top.pos.y    +=   rect_in.size.y / 2 - rect_top.size.y    / 2

	return rect_top, rect_bottom }

rect_slice_h_append :: proc(rect_in: rect.Rect, size: f32, n_max: int, rects: ^[dynamic]rect.Rect) {
	slice_rects := rect_slice_h_make(rect_in, size, n_max, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

rect_slice_h_make :: proc(rect_in: rect.Rect, size: f32, n_max: int, allocator: runtime.Allocator) -> (rects_out: []rect.Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.x / size)
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.x - f32(n - 1) * size
	rects_out = make([]rect.Rect, n, allocator)
	if n != 1 do for i in 0 ..< n - 1 {
		rect := rect_in
		rect.size.x = size
		rect.pos.x = rect_in.pos.x - rect_in.size.x / 2 + (0.5 + cast(f32)i) * size
		rects_out[i] = rect }
	rect := rect_in
	rect.size.x = rem
	rect.pos.x = rect_in.pos.x + rect_in.size.x / 2 - rem / 2
	rects_out[n - 1] = rect
	return rects_out }

rect_slice_v_append :: proc(rect_in: rect.Rect, size: f32, n_max: int, rects: ^[dynamic]rect.Rect) {
	slice_rects := rect_slice_v_make(rect_in, size, n_max, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

rect_slice_v_make :: proc(rect_in: rect.Rect, size: f32, n_max: int, allocator: runtime.Allocator) -> (rects_out: []rect.Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.y / size)
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.y - f32(n - 1) * size
	rects_out = make([]rect.Rect, n, allocator)
	if n != 1 do for i in 0 ..< n - 1 {
		rect := rect_in
		rect.size.y = size
		rect.pos.y = rect_in.pos.y - rect_in.size.y / 2 + (0.5 + cast(f32)i) * size
		rects_out[i] = rect }
	rect := rect_in
	rect.size.y = rem
	rect.pos.y = rect_in.pos.y + rect_in.size.y / 2 - rem / 2
	rects_out[n - 1] = rect
	return rects_out }

rect_grid :: proc { rect_grid_append, rect_grid_make }

rect_grid_append :: proc(rect_in: rect.Rect, size: [2]int, rects: ^[dynamic]rect.Rect) {
	grid_rects := rect_grid_make(rect_in, size, context.temp_allocator)
	for grid_rect in grid_rects do append(rects, grid_rect) }

rect_grid_make :: proc(rect_in: rect.Rect, size: [2]int, allocator: runtime.Allocator) -> (rects_out: []rect.Rect) {
	rects_out = make([]rect.Rect, size.x * size.y, allocator)
	rect_width:  f32 = rect_in.size.x / cast(f32)size.x
	rect_height: f32 = rect_in.size.y / cast(f32)size.y
	for _, i in 0 ..< size.x do for _, j in 0 ..< size.y {
		rect := &rects_out[j * size.x + i]
		rect^ = rect_in
		rect.pos.x += - rect_in.size.x / 2 + rect_width  * (cast(f32)i + 0.5)
		rect.pos.y += - rect_in.size.y / 2 + rect_height * (cast(f32)j + 0.5)
		rect.size.x = rect_width
		rect.size.y = rect_height }
	return rects_out }

rect_grid_index :: proc(size: [2]int, i, j: int) -> int {
	return j * size.x + i }

rect_screen :: proc(graphics_manager: ^graphics.Graphics_Manager) -> rect.Rect {
	return rect.make_rect(0.0, 0.0, graphics_manager.active_resolution.x, graphics_manager.active_resolution.y) }

rect_extend :: proc(rect_in: rect.Rect, left: f32 = 0, right: f32 = 0, bottom: f32 = 0, top: f32 = 0) -> (rect_out: rect.Rect) {
	rect_out = rect_in

	rect_out.size.x += left
	rect_out.pos.x -= left / 2

	rect_out.size.x += right
	rect_out.pos.x += right / 2

	rect_out.size.y += bottom
	rect_out.pos.y -= bottom / 2

	rect_out.size.y += top
	rect_out.pos.y += top / 2

	return rect_out }

rect_rotate :: proc(rect_in: rect.Rect) -> (rect_out: rect.Rect) {
	rect_out = rect_in
	rect_out.size.x = rect_in.size.y
	rect_out.size.y = rect_in.size.x
	return rect_out }

rect_mirror_x :: proc(rect_in: rect.Rect, center: f32) -> (rect_out: rect.Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.pos.x - center
	rect_out.pos.x -= 2 * delta
	return rect_out }

rect_mirror_y :: proc(rect_in: rect.Rect, center: f32) -> (rect_out: rect.Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.pos.y - center
	rect_out.pos.y -= 2 * delta
	return rect_out }

rects_mirror_x :: proc { rects_mirror_x_make, rects_mirror_x_edit }

rects_mirror_y :: proc { rects_mirror_y_make, rects_mirror_y_edit }

rects_mirror_x_make :: proc(rects_in: []rect.Rect, center: f32, allocator: runtime.Allocator) -> (rects_out: []rect.Rect) {
	rects_out = make([]rect.Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = rect_mirror_x(rect, center)
	return rects_out }

rects_mirror_y_make :: proc(rects_in: []rect.Rect, center: f32, allocator: runtime.Allocator) -> (rects_out: []rect.Rect) {
	rects_out = make([]rect.Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = rect_mirror_y(rect, center)
	return rects_out }

rects_mirror_x_edit :: proc(rects: []rect.Rect, center: f32) {
	for &rect, i in rects do rect = rect_mirror_x(rect, center) }

rects_mirror_y_edit :: proc(rects: []rect.Rect, center: f32) {
	for &rect, i in rects do rect = rect_mirror_y(rect, center) }

rects_merge :: proc(rect_a: rect.Rect, rect_b: rect.Rect) -> (rect_out: rect.Rect) {
	x0: f32 = min(rect_a.pos.x - rect_a.size.x / 2, rect_b.pos.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.pos.x + rect_a.size.x / 2, rect_b.pos.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.pos.y - rect_a.size.y / 2, rect_b.pos.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.pos.y + rect_a.size.y / 2, rect_b.pos.y + rect_b.size.y / 2)
	rect_out = {
		pos = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return rect_out }

rects_remove_range :: proc(rects: ^[dynamic]rect.Rect, range: [2]int) {
	for i, j in range[0] ..< range[1] {
		ordered_remove(rects, i - j) } }

rects_merge_range :: proc(rects: ^[dynamic]rect.Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	rects_remove_range(rects, { range.x + 1, range.y })
	rects[range.x] = rects_merge(rect_a, rect_b) }

rects_merge_range_retaining :: proc(rects: ^[dynamic]rect.Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	ordered_remove(rects, range.y - 1)
	rects[range.x] = rects_merge(rect_a, rect_b) }
