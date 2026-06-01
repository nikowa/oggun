#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"

Ratio :: distinct f32
Interval :: distinct f32

GUI_H_Align :: enum {
	LEFT,
	CENTER,
	JUSTIFY,
	RIGHT }

GUI_V_Align :: enum {
	BOTTOM,
	CENTER,
	TOP }

GUI_Fit :: enum {
	NONE,
	FILL,
	COVER,
	CONTAIN,
	SCALE_DOWN }

GUI_Action :: enum {
	PRESS,
	HOVER }

rect_fit :: proc(rect, container: Rect, fit: GUI_Fit) -> (rect_out: Rect) {
	switch fit {
	case .NONE:
		return { container.position, rect.size }
	case .FILL:
		return container
	case .COVER:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		rect_out = container
		if container_ratio < rect_ratio do rect_out.size.x = rect_ratio * rect_out.size.y
		else do rect_out.size.y = rect_out.size.x / rect_ratio
		return rect_out
	case .CONTAIN:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		rect_out = container
		if container_ratio > rect_ratio do rect_out.size.x = rect_ratio * rect_out.size.y
		else do rect_out.size.y = rect_out.size.x / rect_ratio
		return rect_out
	case .SCALE_DOWN:
		variant_a := rect_fit(rect, container, .CONTAIN)
		variant_b := rect_fit(rect, container, .NONE)
		if variant_a.size.x < variant_b.size.x do return variant_a
		else do return variant_b }
	return rect_out }

rect_embed :: proc(rect_in: Rect, size: [2]f32, pivot: bit_set[Compass] = {}) -> (rect_out: Rect) {
	rect_out = { rect_in.position, size }
	delta: [2]f32 = rect_in.size / 2 - size / 2
	if .East in pivot do rect_out.position.x += delta.x
	if .West in pivot do rect_out.position.x -= delta.x
	if .North in pivot do rect_out.position.y += delta.y
	if .South in pivot do rect_out.position.y -= delta.y
	return rect_out }

rect_margins :: proc { rect_margins_i, rect_margins_r }

rect_margins_i :: proc(rect_in: Rect, margins: Interval) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x -= f32(margins) * 2
	rect_out.size.y -= f32(margins) * 2
	return rect_out }

rect_margins_r :: proc(rect_in: Rect, margins: Ratio) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x -= f32(margins) * rect_out.size.x * 2
	rect_out.size.y -= f32(margins) * rect_out.size.y * 2
	return rect_out }

rect_margins_variate :: proc { rect_margins_variate_r, rect_margins_variate_i }

rect_margins_variate_r :: proc(rect_in: Rect, west: Ratio = 0, east: Ratio = 0, south: Ratio = 0, north: Ratio = 0) -> (rect_out: Rect) {
	return rect_margins_variate_i(rect_in,
		Interval(f32(west) * rect_in.size.x), Interval(f32(east) * rect_in.size.x),
		Interval(f32(south) * rect_in.size.y), Interval(f32(north) * rect_in.size.y)) }

rect_margins_variate_i :: proc(rect_in: Rect, west: Interval = 0, east: Interval = 0, south: Interval = 0, north: Interval = 0) -> (rect_out: Rect) {
	rect_out = rect_in

	rect_out.size.x -= f32(west)
	rect_out.position.x += f32(west) / 2

	rect_out.size.x -= f32(east)
	rect_out.position.x -= f32(east) / 2

	rect_out.size.y -= f32(south)
	rect_out.position.y += f32(south) / 2

	rect_out.size.y -= f32(north)
	rect_out.position.y -= f32(north) / 2

	return rect_out }

rect_extend :: proc { rect_extend_i, rect_extend_r }

rect_extend_i :: proc(rect_in: Rect, margins: Interval) -> (rect_out: Rect) {
	return rect_margins_i(rect_in, -margins) }

rect_extend_r :: proc(rect_in: Rect, margins: Ratio) -> (rect_out: Rect) {
	return rect_extend_r(rect_in, -margins) }

rect_extend_variate :: proc { rect_extend_variate_r, rect_extend_variate_i }

rect_extend_variate_r :: proc(rect_in: Rect, west: Ratio = 0, east: Ratio = 0, south: Ratio = 0, north: Ratio = 0) -> (rect_out: Rect) {
	return rect_margins_variate_r(rect_in, -west, -east, -south, -north) }

rect_extend_variate_i :: proc(rect_in: Rect, west: Interval = 0, east: Interval = 0, south: Interval = 0, north: Interval = 0) -> (rect_out: Rect) {
	return rect_margins_variate_i(rect_in, -west, -east, -south, -north) }

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

rect_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x = rect_in.size.y
	rect_out.size.y = rect_in.size.x
	return rect_out }

rect_mirror_x :: proc { rect_mirror_x_centered, rect_mirror_x_offset, rect_multi_mirror_x_offset_make, rect_multi_mirror_x_centered_make, rect_multi_mirror_x_offset_edit, rect_multi_mirror_x_centered_edit }

rect_mirror_x_centered :: proc(rect_in: Rect) -> (rect_out: Rect) {
	return rect_mirror_x_offset(rect_in, 0) }

rect_mirror_x_offset :: proc(rect_in: Rect, offset: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.x - offset
	rect_out.position.x -= 2 * delta
	return rect_out }

rect_mirror_y :: proc { rect_mirror_y_centered, rect_mirror_y_offset, rect_multi_mirror_y_offset_make, rect_multi_mirror_y_centered_make, rect_multi_mirror_y_offset_edit, rect_multi_mirror_y_centered_edit }

rect_mirror_y_centered :: proc(rect_in: Rect) -> (rect_out: Rect) {
	return rect_mirror_y_offset(rect_in, 0) }

rect_mirror_y_offset :: proc(rect_in: Rect, offset: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.y - offset
	rect_out.position.y -= 2 * delta
	return rect_out }

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

rect_merge_pair :: proc(rect_a: Rect, rect_b: Rect) -> (rect_out: Rect) {
	x0: f32 = min(rect_a.position.x - rect_a.size.x / 2, rect_b.position.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.position.x + rect_a.size.x / 2, rect_b.position.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.position.y - rect_a.size.y / 2, rect_b.position.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.position.y + rect_a.size.y / 2, rect_b.position.y + rect_b.size.y / 2)
	rect_out = {
		position = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return rect_out }

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

rect_translate :: proc(rect_in: Rect, offset: [2]f32) -> (rect_out: Rect) {
	return { rect_in.position + offset, rect_in.size } }

rect_scale :: proc(rect_in: Rect, scale: [2]f32) -> (rect_out: Rect) {
	return { rect_in.position, scale * rect_in.size } }

rect_top_to :: proc(rect_in: Rect, target: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.position.y = target - rect_out.size.y / 2
	return rect_out }

rect_bottom_to :: proc(rect_in: Rect, target: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.position.y = target + rect_out.size.y / 2
	return rect_out }

rect_left_to :: proc(rect_in: Rect, target: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.position.x = target - rect_out.size.x / 2
	return rect_out }
