#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"

GUI_Action :: enum {
	Press,
	Hover }

Ratio :: distinct f32
Interval :: distinct f32

H_Align :: enum {
	Left,
	Center,
	Justify,
	Right }

V_Align :: enum {
	Bottom,
	Center,
	Top }

Fit :: enum {
	None,
	Fill,
	Cover,
	Contain,
	Scale_Down }

// ok //
gui_fit :: proc(rect, container: Rect, fit: Fit) -> (rect_out: Rect) {
	switch fit {
	case .None:
		return { container.position, rect.size }
	case .Fill:
		return container
	case .Cover:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		rect_out = container
		if container_ratio < rect_ratio do rect_out.size.x = rect_ratio * rect_out.size.y
		else do rect_out.size.y = rect_out.size.x / rect_ratio
		return rect_out
	case .Contain:
		rect_ratio: f32 = rect.size.x / rect.size.y
		container_ratio: f32 = container.size.x / container.size.y
		rect_out = container
		if container_ratio > rect_ratio do rect_out.size.x = rect_ratio * rect_out.size.y
		else do rect_out.size.y = rect_out.size.x / rect_ratio
		return rect_out
	case .Scale_Down:
		variant_a := gui_fit(rect, container, .Contain)
		variant_b := gui_fit(rect, container, .None)
		if variant_a.size.x < variant_b.size.x do return variant_a
		else do return variant_b }
	return rect_out }

// ok //
gui_embed :: proc(rect_in: Rect, size: [2]f32, pivot: bit_set[Compass] = {}) -> (rect_out: Rect) {
	rect_out = { rect_in.position, size }
	delta: [2]f32 = rect_in.size / 2 - size / 2
	if .East in pivot do rect_out.position.x += delta.x
	if .West in pivot do rect_out.position.x -= delta.x
	if .North in pivot do rect_out.position.y += delta.y
	if .South in pivot do rect_out.position.y -= delta.y
	return rect_out }

// ok //
gui_margins :: proc { gui_margins_i, gui_margins_r }

// ok //
gui_margins_i :: proc(rect_in: Rect, margins: Interval) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x -= f32(margins) * 2
	rect_out.size.y -= f32(margins) * 2
	return rect_out }

// ok //
gui_margins_r :: proc(rect_in: Rect, margins: Ratio) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x -= f32(margins) * rect_out.size.x * 2
	rect_out.size.y -= f32(margins) * rect_out.size.y * 2
	return rect_out }

// ok //
gui_margins_variate :: proc { gui_margins_variate_r, gui_margins_variate_i }

// ok //
gui_margins_variate_r :: proc(rect_in: Rect, west: Ratio = 0, east: Ratio = 0, south: Ratio = 0, north: Ratio = 0) -> (rect_out: Rect) {
	return gui_margins_variate_i(rect_in,
		Interval(f32(west) * rect_in.size.x), Interval(f32(east) * rect_in.size.x),
		Interval(f32(south) * rect_in.size.y), Interval(f32(north) * rect_in.size.y)) }

// ok //
gui_margins_variate_i :: proc(rect_in: Rect, west: Interval = 0, east: Interval = 0, south: Interval = 0, north: Interval = 0) -> (rect_out: Rect) {
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

// ok //
gui_split_h :: proc { gui_split_h_rr, gui_split_h_ri, gui_split_h_ir, gui_split_h_ii }

// ok //
gui_split_h_rr :: proc(rect_in: Rect, split: Ratio, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_h_ii(rect_in, Interval(f32(split) * rect_in.size.x), Interval(f32(margin) * rect_in.size.x)) }

// ok //
gui_split_h_ri :: proc(rect_in: Rect, split: Ratio, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_h_ii(rect_in, Interval(f32(split) * rect_in.size.x), margin) }

// ok //
gui_split_h_ir :: proc(rect_in: Rect, split: Interval, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_h_ii(rect_in, split, Interval(f32(margin) * rect_in.size.x)) }

// ok //
gui_split_h_ii :: proc(rect_in: Rect, split: Interval, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	rect_left  = rect_in
	rect_right = rect_in

	rect_left.size.x  = f32(split) - f32(margin) / 2
	rect_right.size.x = (rect_in.size.x - f32(split)) - f32(margin) / 2

	rect_left.position.x  += - rect_in.size.x / 2 + rect_left.size.x  / 2
	rect_right.position.x +=   rect_in.size.x / 2 - rect_right.size.x / 2

	return rect_left, rect_right }

// ok //
gui_split_v :: proc { gui_split_v_rr, gui_split_v_ri, gui_split_v_ir, gui_split_v_ii }

// ok //
gui_split_v_rr :: proc(rect_in: Rect, split: Ratio, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_v_ii(rect_in, Interval(f32(split) * rect_in.size.y), Interval(f32(margin) * rect_in.size.y)) }

// ok //
gui_split_v_ri :: proc(rect_in: Rect, split: Ratio, margin: Interval) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_v_ii(rect_in, Interval(f32(split) * rect_in.size.y), margin) }

// ok //
gui_split_v_ir :: proc(rect_in: Rect, split: Interval, margin: Ratio) -> (rect_left: Rect, rect_right: Rect) {
	return gui_split_v_ii(rect_in, split, Interval(f32(margin) * rect_in.size.y)) }

// ok //
gui_split_v_ii :: proc(rect_in: Rect, split: Interval, margin: Interval) -> (rect_top: Rect, rect_bottom: Rect) {
	rect_top    = rect_in
	rect_bottom = rect_in

	rect_top.size.y    = f32(split) -       f32(margin) / 2
	rect_bottom.size.y = (rect_in.size.y - f32(split)) - f32(margin) / 2

	rect_bottom.position.y += - rect_in.size.y / 2 + rect_bottom.size.y / 2
	rect_top.position.y    +=   rect_in.size.y / 2 - rect_top.size.y    / 2

	return rect_top, rect_bottom }

// ok //
gui_slice_h :: proc { gui_slice_h_append_i, gui_slice_h_make_i, gui_slice_h_append_r, gui_slice_h_make_r }

// ok //
gui_slice_h_append_i :: proc(rect_in: Rect, size: Interval, n_max: int, inverse: bool = false, rects: ^[dynamic]Rect) {
	slice_rects := gui_slice_h_make_i(rect_in, size, n_max, inverse, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

// ok //
gui_slice_h_make_i :: proc(rect_in: Rect, size: Interval, n_max: int, inverse: bool = false, allocator := context.allocator) -> (rects_out: []Rect) {
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

// ok //
gui_slice_h_append_r :: proc(rect_in: Rect, size: Ratio, n_max: int, inverse: bool = false, rects: ^[dynamic]Rect) {
	gui_slice_h_append_i(rect_in, Interval(f32(size) * rect_in.size.x), n_max, inverse, rects) }

// ok //
gui_slice_h_make_r :: proc(rect_in: Rect, size: Ratio, n_max: int, inverse: bool = false, allocator := context.allocator) -> (rects_out: []Rect) {
	return gui_slice_h_make_i(rect_in, Interval(f32(size) * rect_in.size.x), n_max, inverse, allocator) }

// ok //
gui_slice_v :: proc { gui_slice_v_append_i, gui_slice_v_make_i, gui_slice_v_append_r, gui_slice_v_make_r }

// ok //
gui_slice_v_append_i :: proc(rect_in: Rect, size: Interval, n_max: int, inverse: bool = false, rects: ^[dynamic]Rect) {
	slice_rects := gui_slice_v_make_i(rect_in, size, n_max, inverse, context.temp_allocator)
	for slice_rect in slice_rects do append(rects, slice_rect) }

// ok //
gui_slice_v_make_i :: proc(rect_in: Rect, size: Interval, n_max: int, inverse: bool = false, allocator := context.allocator) -> (rects_out: []Rect) {
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

// ok //
gui_slice_v_append_r :: proc(rect_in: Rect, size: Ratio, n_max: int, inverse: bool = false, rects: ^[dynamic]Rect) {
	gui_slice_v_append_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, inverse, rects) }

// ok //
gui_slice_v_make_r :: proc(rect_in: Rect, size: Ratio, n_max: int, inverse: bool = false, allocator := context.allocator) -> (rects_out: []Rect) {
	return gui_slice_v_make_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, inverse, allocator) }

// ok //
gui_grid :: proc { gui_grid_append, gui_grid_make }

// ok //
gui_grid_append :: proc(rect_in: Rect, size: [2]int, rects: ^[dynamic]Rect) {
	grid_rects := gui_grid_make(rect_in, size, context.temp_allocator)
	for grid_rect in grid_rects do append(rects, grid_rect) }

// ok //
gui_grid_make :: proc(rect_in: Rect, size: [2]int, allocator := context.allocator) -> (rects_out: []Rect) {
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

// ok //
gui_grid_index :: proc(size: [2]int, i, j: int) -> int {
	return j * size.x + i }

// ok //
gui_screen :: proc() -> Rect {
	return make_rect(0.0, 0.0, engine.graphics_manager.active_resolution.x, engine.graphics_manager.active_resolution.y) }

// ok //
gui_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x = rect_in.size.y
	rect_out.size.y = rect_in.size.x
	return rect_out }

// ok //
gui_mirror_x :: proc { gui_mirror_x_centered, gui_mirror_x_offset, gui_multi_mirror_x_offset_make, gui_multi_mirror_x_centered_make, gui_multi_mirror_x_offset_edit, gui_multi_mirror_x_centered_edit }

// ok //
gui_mirror_x_centered :: proc(rect_in: Rect) -> (rect_out: Rect) {
	return gui_mirror_x_offset(rect_in, 0) }

// ok //
gui_mirror_x_offset :: proc(rect_in: Rect, offset: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.x - offset
	rect_out.position.x -= 2 * delta
	return rect_out }

// ok //
gui_mirror_y :: proc { gui_mirror_y_centered, gui_mirror_y_offset, gui_multi_mirror_y_offset_make, gui_multi_mirror_y_centered_make, gui_multi_mirror_y_offset_edit, gui_multi_mirror_y_centered_edit }

// ok //
gui_mirror_y_centered :: proc(rect_in: Rect) -> (rect_out: Rect) {
	return gui_mirror_y_offset(rect_in, 0) }

// ok //
gui_mirror_y_offset :: proc(rect_in: Rect, offset: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.y - offset
	rect_out.position.y -= 2 * delta
	return rect_out }

// ok //
gui_multi_mirror_x :: proc { gui_multi_mirror_x_offset_make, gui_multi_mirror_x_centered_make, gui_multi_mirror_x_offset_edit, gui_multi_mirror_x_centered_edit }

// ok //
gui_multi_mirror_x_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = gui_mirror_x(rect, offset)
	return rects_out }

// ok //
gui_multi_mirror_x_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	return gui_multi_mirror_x_offset_make(rects_in, 0, allocator) }

// ok //
gui_multi_mirror_x_offset_edit :: proc(rects: []Rect, offset: f32) {
	for &rect, i in rects do rect = gui_mirror_x(rect, offset) }

// ok //
gui_multi_mirror_x_centered_edit :: proc(rects: []Rect) {
	gui_multi_mirror_x_offset_edit(rects, 0) }

// ok //
gui_multi_mirror_y :: proc { gui_multi_mirror_y_offset_make, gui_multi_mirror_y_centered_make, gui_multi_mirror_y_offset_edit, gui_multi_mirror_y_centered_edit }

// ok //
gui_multi_mirror_y_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	rects_out = make([]Rect, len(rects_in))
	for rect, i in rects_in do rects_out[i] = gui_mirror_y(rect, offset)
	return rects_out }

// ok //
gui_multi_mirror_y_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
	return gui_multi_mirror_y_offset_make(rects_in, 0, allocator) }

// ok //
gui_multi_mirror_y_offset_edit :: proc(rects: []Rect, offset: f32) {
	for &rect, i in rects do rect = gui_mirror_y(rect, offset) }

// ok //
gui_multi_mirror_y_centered_edit :: proc(rects: []Rect) {
	gui_multi_mirror_y_offset_edit(rects, 0) }

// ok //
gui_merge :: proc { gui_merge_pair, gui_multi_merge_range }

// ok //
gui_merge_pair :: proc(rect_a: Rect, rect_b: Rect) -> (rect_out: Rect) {
	x0: f32 = min(rect_a.position.x - rect_a.size.x / 2, rect_b.position.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.position.x + rect_a.size.x / 2, rect_b.position.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.position.y - rect_a.size.y / 2, rect_b.position.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.position.y + rect_a.size.y / 2, rect_b.position.y + rect_b.size.y / 2)
	rect_out = {
		position = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return rect_out }

// ok //
gui_multi_remove_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	for i, j in range[0] ..< range[1] {
		ordered_remove(rects, i - j) } }

// ok //
gui_multi_merge_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	gui_multi_remove_range(rects, { range.x + 1, range.y })
	rects[range.x] = gui_merge(rect_a, rect_b) }

// ok //
gui_merge_retaining :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	ordered_remove(rects, range.y - 1)
	rects[range.x] = gui_merge(rect_a, rect_b) }

// ok //
gui_translate :: proc(rect_in: Rect, offset: [2]f32) -> (rect_out: Rect) {
	return { rect_in.position + offset, rect_in.size } }

// ok //
gui_scale :: proc(rect_in: Rect, scale: [2]f32) -> (rect_out: Rect) {
	return { rect_in.position, scale * rect_in.size } }
