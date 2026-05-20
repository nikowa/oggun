#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"

gui_margins :: proc(rect_in: Rect, margins: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x -= margins * 2
	rect_out.size.y -= margins * 2
	return rect_out }

// Add a version of this called "_split_interval" which splits at a specified point on the X-axis.
gui_split_ratio_h :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_left: Rect, rect_right: Rect) {
	rect_left  = rect_in
	rect_right = rect_in

	rect_left.size.x  = rect_in.size.x * ratio -         margin / 2
	rect_right.size.x = rect_in.size.x * (1.0 - ratio) - margin / 2

	rect_left.pos.x  += - rect_in.size.x / 2 + rect_left.size.x  / 2
	rect_right.pos.x +=   rect_in.size.x / 2 - rect_right.size.x / 2

	return rect_left, rect_right }

gui_split_ratio_v :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_top: Rect, rect_bottom: Rect) {
	rect_top    = rect_in
	rect_bottom = rect_in

	rect_top.size.y    = rect_in.size.y * ratio -         margin / 2
	rect_bottom.size.y = rect_in.size.y * (1.0 - ratio) - margin / 2

	rect_bottom.pos.y += - rect_in.size.y / 2 + rect_bottom.size.y / 2
	rect_top.pos.y    +=   rect_in.size.y / 2 - rect_top.size.y    / 2

	return rect_top, rect_bottom }

gui_slice_h_append :: proc(rect_in: Rect, size: f32, n_max: int, rects: ^[dynamic]Rect) {
	slice_rects := gui_slice_h_make(rect_in, size, n_max, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

gui_slice_h_make :: proc(rect_in: Rect, size: f32, n_max: int, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.x / size)
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.x - f32(n - 1) * size
	rects_out = make([]Rect, n, allocator)
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

gui_slice_v_append :: proc(rect_in: Rect, size: f32, n_max: int, rects: ^[dynamic]Rect) {
	slice_rects := gui_slice_v_make(rect_in, size, n_max, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

gui_slice_v_make :: proc(rect_in: Rect, size: f32, n_max: int, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.y / size)
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.y - f32(n - 1) * size
	rects_out = make([]Rect, n, allocator)
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

gui_grid :: proc { gui_grid_append, gui_grid_make }

gui_grid_append :: proc(rect_in: Rect, size: [2]int, rects: ^[dynamic]Rect) {
	grid_rects := gui_grid_make(rect_in, size, context.temp_allocator)
	for grid_rect in grid_rects do append(rects, grid_rect) }

gui_grid_make :: proc(rect_in: Rect, size: [2]int, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, size.x * size.y, allocator)
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

gui_grid_index :: proc(size: [2]int, i, j: int) -> int {
	return j * size.x + i }

gui_screen :: proc(graphics_manager: ^Graphics_Manager) -> Rect {
	return make_rect(0.0, 0.0, graphics_manager.active_resolution.x, graphics_manager.active_resolution.y) }

gui_extend :: proc(rect_in: Rect, left: f32 = 0, right: f32 = 0, bottom: f32 = 0, top: f32 = 0) -> (rect_out: Rect) {
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

gui_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x = rect_in.size.y
	rect_out.size.y = rect_in.size.x
	return rect_out }

gui_mirror_x :: proc(rect_in: Rect, center: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.pos.x - center
	rect_out.pos.x -= 2 * delta
	return rect_out }

gui_mirror_y :: proc(rect_in: Rect, center: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.pos.y - center
	rect_out.pos.y -= 2 * delta
	return rect_out }

gui_multi_mirror_x :: proc { gui_multi_mirror_x_make, gui_multi_mirror_x_edit }

gui_multi_mirror_y :: proc { gui_multi_mirror_y_make, gui_multi_mirror_y_edit }

gui_multi_mirror_x_make :: proc(rects_in: []Rect, center: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = gui_mirror_x(rect, center)
	return rects_out }

gui_multi_mirror_y_make :: proc(rects_in: []Rect, center: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = gui_mirror_y(rect, center)
	return rects_out }

gui_multi_mirror_x_edit :: proc(rects: []Rect, center: f32) {
	for &rect, i in rects do rect = gui_mirror_x(rect, center) }

gui_multi_mirror_y_edit :: proc(rects: []Rect, center: f32) {
	for &rect, i in rects do rect = gui_mirror_y(rect, center) }

gui_multi_merge :: proc(rect_a: Rect, rect_b: Rect) -> (rect_out: Rect) {
	x0: f32 = min(rect_a.pos.x - rect_a.size.x / 2, rect_b.pos.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.pos.x + rect_a.size.x / 2, rect_b.pos.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.pos.y - rect_a.size.y / 2, rect_b.pos.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.pos.y + rect_a.size.y / 2, rect_b.pos.y + rect_b.size.y / 2)
	rect_out = {
		pos = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return rect_out }

gui_multi_remove_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	for i, j in range[0] ..< range[1] {
		ordered_remove(rects, i - j) } }

gui_multi_merge_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	gui_multi_remove_range(rects, { range.x + 1, range.y })
	rects[range.x] = gui_multi_merge(rect_a, rect_b) }

gui_multi_merge_range_retaining :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	ordered_remove(rects, range.y - 1)
	rects[range.x] = gui_multi_merge(rect_a, rect_b) }

gui_offset :: proc(rect_in: Rect, offset: [2]f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.pos += offset
	return rect_out }

H_Align :: enum { Left, Center, Right }
V_Align :: enum { Bottom, Center, Top }

// (TODO): Make an iterator version of this, for looping till a certain width or space count is reached. //
gui_text_measure :: proc(style: Bitmap_Text_Style, text: string) -> (width: f32, space_count: int) {
	using style
	for c, i in text {
		width += f32(font.advances[c] - font.bearings[c]) * scale_factor + spacing
		if c == ' ' do space_count += 1 }
	return width, space_count }

gui_text_line :: proc(graphics_man: ^Graphics_Manager, style: Bitmap_Text_Style, position: [2]f32, args: ..any, pivot: bit_set[Compass] = {}, depth: f32 = 0.0, sep: string = "", desired_width: Maybe(f32) = nil) {
	using style
	text := fmt.aprint(..args, sep = sep)
	position := position
	// width: f32 = 0.0
	// space_count: int = 0
	// for c, i in text {
	// 	width += f32(font.advances[c] - font.bearings[c]) * scale_factor + spacing
	// 	if c == ' ' do space_count += 1 }
	width, space_count := gui_text_measure(style, text)
	space_delta: f32 = 0
	if space_count != 0 && desired_width != nil do space_delta = (desired_width.(f32) - width) / cast(f32)space_count
	height: f32 = f32(font.symbol_size.y)
	if space_delta != 0 { width = desired_width.(f32) }
	position = position - 0.5 * { width, height }
	if .East  in pivot do position.x -= 0.5 * width
	if .West  in pivot do position.x += 0.5 * width
	if .North in pivot do position.y -= 0.5 * height
	if .South in pivot do position.y += 0.5 * height
	symbol_position: [2]f32 = position
	for symbol, i in text {
		render_bitmap_symbol(graphics_man, cast(u8)symbol, symbol_position, depth, style)
		symbol_position.x += f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + spacing
		if symbol == ' ' do symbol_position.x += space_delta } }

gui_text_box :: proc(graphics_man: ^Graphics_Manager, style: Bitmap_Text_Style, rect: Rect, args: ..any, h_align: H_Align = .Center, v_align: V_Align = .Center, sep: string = "") {
	using style

}
