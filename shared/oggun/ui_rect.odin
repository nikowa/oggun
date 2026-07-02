#+feature using-stmt
package oggun
import "core:math"
import "core:math/linalg"

ui_rect_screen :: proc() -> Rect {
	return make_rect(0.0, 0.0, engine.graphics_manager.active_resolution.x, engine.graphics_manager.active_resolution.y) }

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

ui_rect_split_h :: proc { ui_rect_split_h_rr, ui_rect_split_h_ri, ui_rect_split_h_ir, ui_rect_split_h_ii }

ui_rect_split_h_rr :: proc(a: Rect, s: Ratio, m: Ratio) -> (b: Rect, c: Rect) {
	return ui_rect_split_h_ii(a, Interval(f32(s) * a.size.x), Interval(f32(m) * a.size.x)) }

ui_rect_split_h_ri :: proc(a: Rect, s: Ratio, m: Interval) -> (b: Rect, c: Rect) {
	return ui_rect_split_h_ii(a, Interval(f32(s) * a.size.x), m) }

ui_rect_split_h_ir :: proc(a: Rect, s: Interval, m: Ratio) -> (b: Rect, c: Rect) {
	return ui_rect_split_h_ii(a, s, Interval(f32(m) * a.size.x)) }

ui_rect_split_h_ii :: proc(a: Rect, s: Interval, m: Interval) -> (b: Rect, c: Rect) {
	b  = a
	c = a

	b.size.x  = f32(s) - f32(m) / 2
	c.size.x = (a.size.x - f32(s)) - f32(m) / 2

	b.position.x  += - a.size.x / 2 + b.size.x  / 2
	c.position.x +=   a.size.x / 2 - c.size.x / 2

	return b, c }

ui_rect_split_v :: proc { ui_rect_split_v_rr, ui_rect_split_v_ri, ui_rect_split_v_ir, ui_rect_split_v_ii }

ui_rect_split_v_rr :: proc(a: Rect, s: Ratio, m: Ratio) -> (b: Rect, c: Rect) {
	return ui_rect_split_v_ii(a, Interval(f32(s) * a.size.y), Interval(f32(m) * a.size.y)) }

ui_rect_split_v_ri :: proc(a: Rect, s: Ratio, m: Interval) -> (b: Rect, c: Rect) {
	return ui_rect_split_v_ii(a, Interval(f32(s) * a.size.y), m) }

ui_rect_split_v_ir :: proc(a: Rect, s: Interval, m: Ratio) -> (b: Rect, c: Rect) {
	return ui_rect_split_v_ii(a, s, Interval(f32(m) * a.size.y)) }

ui_rect_split_v_ii :: proc(a: Rect, s: Interval, m: Interval) -> (b: Rect, c: Rect) {
	b = a
	c = a

	b.size.y    = f32(s) -       f32(m) / 2
	c.size.y = (a.size.y - f32(s)) - f32(m) / 2

	c.position.y += - a.size.y / 2 + c.size.y / 2
	b.position.y    +=   a.size.y / 2 - b.size.y    / 2

	return b, c }

ui_rect_slice_h :: proc { ui_rect_slice_h_append_i, ui_rect_slice_h_make_i, ui_rect_slice_h_append_r, ui_rect_slice_h_make_r }

Slice_H_Iterator :: struct {
	i: int,
	next: proc(iterator: ^Slice_H_Iterator) -> Rect }

// (TODO): Add iterator.
ui_rect_slice_h_append_i :: proc(a: Rect, s: Interval, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	slice_rects := ui_rect_slice_h_make_i(a, s, n_max, context.temp_allocator, inverse)
	for slice_rect in slice_rects do append(rects, slice_rect) }

ui_rect_slice_h_make_i :: proc(a: Rect, size: Interval, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	if n_max == 0 do return {}
	n: int = cast(int)linalg.ceil(a.size.x / f32(size))
	if n_max != -1 do n = min(n, n_max)
	rem: f32 = a.size.x - f32(n - 1) * f32(size)
	rects_out = make([]Rect, n, allocator)
	if n != 1 do for i in 0 ..< n - 1 {
		rect := a
		rect.size.x = f32(size)
		rect.position.x = a.position.x + (inverse ? -1 : 1) * (- a.size.x / 2 + (0.5 + cast(f32)i) * f32(size))
		rects_out[i] = rect }
	rect := a
	rect.size.x = rem
	rect.position.x = a.position.x + (inverse ? -1 : 1) * (a.size.x / 2 - rem / 2)
	rects_out[n - 1] = rect
	return rects_out }

ui_rect_slice_h_append_r :: proc(a: Rect, s: Ratio, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	ui_rect_slice_h_append_i(a, Interval(f32(s) * a.size.x), n_max, rects, inverse) }

ui_rect_slice_h_make_r :: proc(a: Rect, s: Ratio, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	return ui_rect_slice_h_make_i(a, Interval(f32(s) * a.size.x), n_max, allocator, inverse) }

ui_rect_slice_v :: proc { ui_rect_slice_v_append_i, ui_rect_slice_v_make_i, ui_rect_slice_v_append_r, ui_rect_slice_v_make_r }

ui_rect_slice_v_append_i :: proc(rect_in: Rect, size: Interval, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	slice_rects := ui_rect_slice_v_make_i(rect_in, size, n_max, context.temp_allocator, inverse)
	for slice_rect in slice_rects do append(rects, slice_rect) }

ui_rect_slice_v_make_i :: proc(rect_in: Rect, size: Interval, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
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

ui_rect_slice_v_append_r :: proc(rect_in: Rect, size: Ratio, n_max: int, rects: ^[dynamic]Rect, inverse: bool = false) {
	ui_rect_slice_v_append_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, rects, inverse) }

ui_rect_slice_v_make_r :: proc(rect_in: Rect, size: Ratio, n_max: int, allocator := context.allocator, inverse: bool = false) -> (rects_out: []Rect) {
	return ui_rect_slice_v_make_i(rect_in, Interval(f32(size) * rect_in.size.y), n_max, allocator, inverse) }

ui_rect_grid :: proc { ui_rect_grid_append, ui_rect_grid_make }

ui_rect_grid_append :: proc(rect_in: Rect, size: [2]int, rects: ^[dynamic]Rect) {
	grid_rects := ui_rect_grid_make(rect_in, size, context.temp_allocator)
	for grid_rect in grid_rects do append(rects, grid_rect) }

ui_rect_grid_make :: proc(rect_in: Rect, size: [2]int, allocator := context.allocator) -> (rects_out: []Rect) {
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

ui_rect_grid_index :: proc(size: [2]int, i, j: int) -> int {
	return j * size.x + i }

ui_rect_mirror_x :: proc { ui_rect_mirror_x_centered, ui_rect_mirror_x_offset/*, rects_mirror_x_offset_make, rects_mirror_x_centered_make, rects_mirror_x_offset_edit, rects_mirror_x_centered_edit*/ }

ui_rect_mirror_x_centered :: proc(rect_in: Rect) -> (result: Rect) {
	return ui_rect_mirror_x_offset(rect_in, 0) }

ui_rect_mirror_x_offset :: proc(rect_in: Rect, offset: f32) -> (result: Rect) {
	result = rect_in
	delta: f32 = rect_in.position.x - offset
	result.position.x -= 2 * delta
	return result }

ui_rect_mirror_y :: proc { ui_rect_mirror_y_centered, ui_rect_mirror_y_offset/*, rects_mirror_y_offset_make, rects_mirror_y_centered_make, rects_mirror_y_offset_edit, rects_mirror_y_centered_edit*/ }

ui_rect_mirror_y_centered :: proc(rect_in: Rect) -> (result: Rect) {
	return ui_rect_mirror_y_offset(rect_in, 0) }

ui_rect_mirror_y_offset :: proc(rect_in: Rect, offset: f32) -> (result: Rect) {
	result = rect_in
	delta: f32 = rect_in.position.y - offset
	result.position.y -= 2 * delta
	return result }

// rects_mirror_x :: proc { rects_mirror_x_offset_make, rects_mirror_x_centered_make, rects_mirror_x_offset_edit, rects_mirror_x_centered_edit }

// rects_mirror_x_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
// 	rects_out = make([]Rect, len(rects_in))
// 	for rect, i in rects_in do rects_out[i] = ui_rect_mirror_x(rect, offset)
// 	return rects_out }

// rects_mirror_x_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
// 	return rects_mirror_x_offset_make(rects_in, 0, allocator) }

// rects_mirror_x_offset_edit :: proc(rects: []Rect, offset: f32) {
// 	for &rect, i in rects do rect = ui_rect_mirror_x(rect, offset) }

// rects_mirror_x_centered_edit :: proc(rects: []Rect) {
// 	rects_mirror_x_offset_edit(rects, 0) }

// rects_mirror_y :: proc { rects_mirror_y_offset_make, rects_mirror_y_centered_make, rects_mirror_y_offset_edit, rects_mirror_y_centered_edit }

// rects_mirror_y_offset_make :: proc(rects_in: []Rect, offset: f32, allocator: runtime.Allocator) -> (rects_out: []Rect) {
// 	rects_out = make([]Rect, len(rects_in))
// 	for rect, i in rects_in do rects_out[i] = ui_rect_mirror_y(rect, offset)
// 	return rects_out }

// rects_mirror_y_centered_make :: proc(rects_in: []Rect, allocator: runtime.Allocator) -> (rects_out: []Rect) {
// 	return rects_mirror_y_offset_make(rects_in, 0, allocator) }

// rects_mirror_y_offset_edit :: proc(rects: []Rect, offset: f32) {
// 	for &rect, i in rects do rect = ui_rect_mirror_y(rect, offset) }

// rects_mirror_y_centered_edit :: proc(rects: []Rect) {
// 	rects_mirror_y_offset_edit(rects, 0) }

ui_rects_merge :: proc { ui_rects_merge_pair, ui_rects_merge_range }

ui_rects_merge_pair :: proc(rect_a: Rect, rect_b: Rect) -> (result: Rect) {
	x0: f32 = min(rect_a.position.x - rect_a.size.x / 2, rect_b.position.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.position.x + rect_a.size.x / 2, rect_b.position.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.position.y - rect_a.size.y / 2, rect_b.position.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.position.y + rect_a.size.y / 2, rect_b.position.y + rect_b.size.y / 2)
	result = {
		position = { (x0 + x1) / 2, (y0 + y1) / 2 },
		size = { (x1 - x0), (y1 - y0) } }
	return result }

ui_rects_merge_range :: proc(rects: ^[dynamic]Rect, range: [2]int, remove_range: bool=true) {
	rect_a := rects[range[0]]
	rect_b := rects[range[1] - 1]
	if remove_range do ui_rects_remove_range(rects, { range.x + 1, range.y })
	else do ordered_remove(rects, range.y - 1)
	rects[range.x] = ui_rects_merge(rect_a, rect_b) }

ui_rects_remove_range :: proc(rects: ^[dynamic]Rect, range: [2]int) {
	for i, j in range[0] ..< range[1] {
		ordered_remove(rects, i - j) } }

ui_rect_rotate :: proc(rect_in: Rect) -> (result: Rect) {
	result = rect_in
	result.size.x = rect_in.size.y
	result.size.y = rect_in.size.x
	return result }

ui_rect_translate :: proc(rect_in: Rect, offset: [2]f32) -> (result: Rect) {
	return { rect_in.position + offset, rect_in.size } }

ui_rect_scale :: proc(rect_in: Rect, scale: [2]f32) -> (result: Rect) {
	return { rect_in.position, scale * rect_in.size } }

ui_rect_resize :: proc(rect_in: Rect, size: [2]f32) -> (result: Rect) {
	return { rect_in.position, size } }

ui_rect_top_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.y = target - result.size.y / 2
	return result }

ui_rect_bottom_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.y = target + result.size.y / 2
	return result }

ui_rect_left_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.x = target + result.size.x / 2
	return result }

ui_rect_right_to :: proc(rect_in: Rect, target: f32) -> (result: Rect) {
	result = rect_in
	result.position.x = target - result.size.x / 2
	return result }
