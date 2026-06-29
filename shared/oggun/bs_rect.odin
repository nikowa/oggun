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

rect_split_h :: proc { rect_split_h_rr, rect_split_h_ri, rect_split_h_ir, rect_split_h_ii }

rect_split_h_rr :: proc(rect_in: Rect, split: Ratio, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_h_ii(rect_in, Interval(f32(split) * rect_in.size.x), Interval(f32(margin) * rect_in.size.x)) }

rect_split_h_ri :: proc(rect_in: Rect, split: Ratio, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_h_ii(rect_in, Interval(f32(split) * rect_in.size.x), margin) }

rect_split_h_ir :: proc(rect_in: Rect, split: Interval, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_h_ii(rect_in, split, Interval(f32(margin) * rect_in.size.x)) }

rect_split_h_ii :: proc(rect_in: Rect, split: Interval, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	rect_left  = rect_in
	rect_right = rect_in

	rect_left.size.x  = f32(split) - f32(margin) / 2
	rect_right.size.x = (rect_in.size.x - f32(split)) - f32(margin) / 2

	rect_left.position.x  += - rect_in.size.x / 2 + rect_left.size.x  / 2
	rect_right.position.x +=   rect_in.size.x / 2 - rect_right.size.x / 2

	return rect_left, rect_right }

rect_split_v :: proc { rect_split_v_rr, rect_split_v_ri, rect_split_v_ir, rect_split_v_ii }

rect_split_v_rr :: proc(rect_in: Rect, split: Ratio, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_v_ii(rect_in, Interval(f32(split) * rect_in.size.y), Interval(f32(margin) * rect_in.size.y)) }

rect_split_v_ri :: proc(rect_in: Rect, split: Ratio, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_v_ii(rect_in, Interval(f32(split) * rect_in.size.y), margin) }

rect_split_v_ir :: proc(rect_in: Rect, split: Interval, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return rect_split_v_ii(rect_in, split, Interval(f32(margin) * rect_in.size.y)) }

rect_split_v_ii :: proc(rect_in: Rect, split: Interval, margin: Interval) -> (rect_top: Rect, rect_bottom: Rect) {
	rect_top    = rect_in
	rect_bottom = rect_in

	rect_top.size.y    = f32(split) -       f32(margin) / 2
	rect_bottom.size.y = (rect_in.size.y - f32(split)) - f32(margin) / 2

	rect_bottom.position.y += - rect_in.size.y / 2 + rect_bottom.size.y / 2
	rect_top.position.y    +=   rect_in.size.y / 2 - rect_top.size.y    / 2

	return rect_top, rect_bottom }

rect_slice_h :: proc { rect_slice_h_append_i, rect_slice_h_make_i, rect_slice_h_append_r, rect_slice_h_make_r }

rect_slice_h_append_i :: proc(rect_in: Rect, size: Interval, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	slice_rects := rect_slice_h_make_i(rect_in, size, n_max, context.temp_allocator, inverse)
	for slice_rect in slice_rects do append(rects, slice_rect) }

rect_slice_h_make_i :: proc(rect_in: Rect, size: Interval, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.x / f32(size))
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.x - f32(n - 1) * f32(size)
	rects_out = make([]Rect, n, allocator)
	if n != 1 do for i in 0 ..< n - 1 {
		rect := rect_in
		rect.size.x = f32(size)
		rect.position.x = rect_in.position.x + (inverse ? -1 : 1) * (- rect_in.size.x / 2 + (0.5 + cast(f32)i) * f32(size))
		rects_out[i] = rect }
	rect := rect_in
	rect.size.x = rem
	rect.position.x = rect_in.position.x + (inverse ? -1 : 1) * (rect_in.size.x / 2 - rem / 2)
	rects_out[n - 1] = rect
	return rects_out }

rect_slice_h_append_r :: proc(rect_in: Rect, size: Ratio, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	rect_slice_h_append_i(rect_in, Interval(f32(size) * rect_in.size.x), n_max, rects, inverse) }

rect_slice_h_make_r :: proc(rect_in: Rect, size: Ratio, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	return rect_slice_h_make_i(rect_in, Interval(f32(size) * rect_in.size.x), n_max, allocator, inverse) }

rect_slice_v :: proc { rect_slice_v_append_i, rect_slice_v_make_i, rect_slice_v_append_r, rect_slice_v_make_r }

rect_slice_v_append_i :: proc(rect_in: Rect, size: Interval, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	slice_rects := rect_slice_v_make_i(rect_in, size, n_max, context.temp_allocator, inverse)
	for slice_rect in slice_rects do append(rects, slice_rect) }

rect_slice_v_make_i :: proc(rect_in: Rect, size: Interval, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(rect_in.size.y / f32(size))
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = rect_in.size.y - f32(n - 1) * f32(size)
	rects_out = make([]Rect, n, allocator)
	if n != 1 do for i in 0 ..< n - 1 {
		rect := rect_in
		rect.size.y = f32(size)
		rect.position.y = rect_in.position.y + (inverse ? 1 : -1) * (- rect_in.size.y / 2 + (0.5 + cast(f32)i) * f32(size))
		rects_out[i] = rect }
	rect := rect_in
	rect.size.y = rem
	rect.position.y = rect_in.position.y + (inverse ? 1 : -1) * (rect_in.size.y / 2 - rem / 2)
	rects_out[n - 1] = rect
	return rects_out }

rect_slice_v_append_r :: proc(rect_in: Rect, size: Ratio, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	rect_slice_v_append_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, rects, inverse) }

rect_slice_v_make_r :: proc(rect_in: Rect, size: Ratio, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	return rect_slice_v_make_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, allocator, inverse) }

rect_grid :: proc { rect_grid_append, rect_grid_make }

rect_grid_append :: proc(rect_in: Rect, size: [2]int, rects: ^[dynamic]Rect) {
	grid_rects := rect_grid_make(rect_in, size, context.temp_allocator)
	for grid_rect in grid_rects do append(rects, grid_rect) }

rect_grid_make :: proc(rect_in: Rect, size: [2]int, allocator := context.allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, size.x * size.y, allocator)
	rect_width:  f32 = rect_in.size.x / cast(f32)size.x
	rect_height: f32 = rect_in.size.y / cast(f32)size.y
	for _, i in 0 ..< size.x do for _, j in 0 ..< size.y {
		rect := &rects_out[j * size.x + i]
		rect^ = rect_in
		rect.position.x += - rect_in.size.x / 2 + rect_width  * (cast(f32)i + 0.5)
		rect.position.y += - rect_in.size.y / 2 + rect_height * (cast(f32)j + 0.5)
		rect.size.x = rect_width
		rect.size.y = rect_height }
	return rects_out }

rect_grid_index :: proc(size: [2]int, i, j: int) -> int {
	return j * size.x + i }

rect_screen :: proc() -> Rect {
	return make_rect(0.0, 0.0, engine.graphics_manager.active_resolution.x, engine.graphics_manager.active_resolution.y) }

rect_rotate :: proc(rect_in: Rect) -> (result: Rect) {
	result = rect_in
	result.size.x = rect_in.size.y
	result.size.y = rect_in.size.x
	return result }

rect_mirror_x :: proc { rect_mirror_x_centered, rect_mirror_x_offset, rect_multi_mirror_x_offset_make, rect_multi_mirror_x_centered_make, rect_multi_mirror_x_offset_edit, rect_multi_mirror_x_centered_edit }

rect_mirror_x_centered :: proc(rect_in: Rect) -> (result: Rect) {
	return rect_mirror_x_offset(rect_in, 0) }

rect_mirror_x_offset :: proc(rect_in: Rect, offset: f32) -> (result: Rect) {
	result = rect_in
	delta: f32 = rect_in.position.x - offset
	result.position.x -= 2 * delta
	return result }

rect_mirror_y :: proc { rect_mirror_y_centered, rect_mirror_y_offset, rect_multi_mirror_y_offset_make, rect_multi_mirror_y_centered_make, rect_multi_mirror_y_offset_edit, rect_multi_mirror_y_centered_edit }

rect_mirror_y_centered :: proc(rect_in: Rect) -> (result: Rect) {
	return rect_mirror_y_offset(rect_in, 0) }

rect_mirror_y_offset :: proc(rect_in: Rect, offset: f32) -> (result: Rect) {
	result = rect_in
	delta: f32 = rect_in.position.y - offset
	result.position.y -= 2 * delta
	return result }

rect_multi_mirror_x :: proc { rect_multi_mirror_x_offset_make, rect_multi_mirror_x_centered_make, rect_multi_mirror_x_offset_edit, rect_multi_mirror_x_centered_edit }

rect_multi_mirror_x_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = rect_mirror_x(rect, offset)
	return rects_out }

rect_multi_mirror_x_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	return rect_multi_mirror_x_offset_make(rects_in, 0, allocator) }

rect_multi_mirror_x_offset_edit :: proc(rects: []Rect, offset: f32) {
	for &rect, i in rects do rect = rect_mirror_x(rect, offset) }

rect_multi_mirror_x_centered_edit :: proc(rects: []Rect) {
	rect_multi_mirror_x_offset_edit(rects, 0) }

rect_multi_mirror_y :: proc { rect_multi_mirror_y_offset_make, rect_multi_mirror_y_centered_make, rect_multi_mirror_y_offset_edit, rect_multi_mirror_y_centered_edit }

rect_multi_mirror_y_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = rect_mirror_y(rect, offset)
	return rects_out }

rect_multi_mirror_y_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	return rect_multi_mirror_y_offset_make(rects_in, 0, allocator) }

rect_multi_mirror_y_offset_edit :: proc(rects: []Rect, offset: f32) {
	for &rect, i in rects do rect = rect_mirror_y(rect, offset) }

rect_multi_mirror_y_centered_edit :: proc(rects: []Rect) {
	rect_multi_mirror_y_offset_edit(rects, 0) }

rect_merge :: proc { rect_merge_pair, rect_multi_merge_range }

rect_merge_pair :: proc(rect_a: Rect, rect_b: Rect) -> (result: Rect) {
	x0: f32 = min(rect_a.position.x - rect_a.size.x / 2, rect_b.position.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.position.x + rect_a.size.x / 2, rect_b.position.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.position.y - rect_a.size.y / 2, rect_b.position.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.position.y + rect_a.size.y / 2, rect_b.position.y + rect_b.size.y / 2)
	result = {
		position = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return result }

rect_multi_remove_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	for i, j in range[0] ..< range[1] {
		ordered_remove(rects, i - j) } }

rect_multi_merge_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	rect_multi_remove_range(rects, { range.x + 1, range.y })
	rects[range.x] = rect_merge(rect_a, rect_b) }

rect_merge_retaining :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	ordered_remove(rects, range.y - 1)
	rects[range.x] = rect_merge(rect_a, rect_b) }

rect_translate :: proc(rect_in: Rect, offset: [2]f32) -> (result: Rect) {
	return { rect_in.position + offset, rect_in.size } }

rect_scale :: proc(rect_in: Rect, scale: [2]f32) -> (result: Rect) {
	return { rect_in.position, scale * rect_in.size } }

rect_resize :: proc(rect_in: Rect, size: [2]f32) -> (result: Rect) {
	return { rect_in.position, size } }

rect_top_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.y = target - result.size.y / 2
	return result }

rect_bottom_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.y = target + result.size.y / 2
	return result }

rect_left_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.x = target + result.size.x / 2
	return result }

rect_right_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.x = target - result.size.x / 2
	return result }

rect_distance :: proc(a: Rect, b: Rect) -> (distance: [2]f32) {
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
