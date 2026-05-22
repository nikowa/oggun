#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"

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

	rect_left.position.x  += - rect_in.size.x / 2 + rect_left.size.x  / 2
	rect_right.position.x +=   rect_in.size.x / 2 - rect_right.size.x / 2

	return rect_left, rect_right }

gui_split_ratio_v :: proc(rect_in: Rect, ratio: f32, margin: f32) -> (rect_top: Rect, rect_bottom: Rect) {
	rect_top    = rect_in
	rect_bottom = rect_in

	rect_top.size.y    = rect_in.size.y * ratio -         margin / 2
	rect_bottom.size.y = rect_in.size.y * (1.0 - ratio) - margin / 2

	rect_bottom.position.y += - rect_in.size.y / 2 + rect_bottom.size.y / 2
	rect_top.position.y    +=   rect_in.size.y / 2 - rect_top.size.y    / 2

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
		rect.position.x = rect_in.position.x - rect_in.size.x / 2 + (0.5 + cast(f32)i) * size
		rects_out[i] = rect }
	rect := rect_in
	rect.size.x = rem
	rect.position.x = rect_in.position.x + rect_in.size.x / 2 - rem / 2
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
		rect.position.y = rect_in.position.y - rect_in.size.y / 2 + (0.5 + cast(f32)i) * size
		rects_out[i] = rect }
	rect := rect_in
	rect.size.y = rem
	rect.position.y = rect_in.position.y + rect_in.size.y / 2 - rem / 2
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
		rect.position.x += - rect_in.size.x / 2 + rect_width  * (cast(f32)i + 0.5)
		rect.position.y += - rect_in.size.y / 2 + rect_height * (cast(f32)j + 0.5)
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
	rect_out.position.x -= left / 2

	rect_out.size.x += right
	rect_out.position.x += right / 2

	rect_out.size.y += bottom
	rect_out.position.y -= bottom / 2

	rect_out.size.y += top
	rect_out.position.y += top / 2

	return rect_out }

gui_rotate :: proc(rect_in: Rect) -> (rect_out: Rect) {
	rect_out = rect_in
	rect_out.size.x = rect_in.size.y
	rect_out.size.y = rect_in.size.x
	return rect_out }

gui_mirror_x :: proc(rect_in: Rect, center: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.x - center
	rect_out.position.x -= 2 * delta
	return rect_out }

gui_mirror_y :: proc(rect_in: Rect, center: f32) -> (rect_out: Rect) {
	rect_out = rect_in
	delta: f32 = rect_in.position.y - center
	rect_out.position.y -= 2 * delta
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
	x0: f32 = min(rect_a.position.x - rect_a.size.x / 2, rect_b.position.x - rect_b.size.x / 2)
	x1: f32 = max(rect_a.position.x + rect_a.size.x / 2, rect_b.position.x + rect_b.size.x / 2)
	y0: f32 = min(rect_a.position.y - rect_a.size.y / 2, rect_b.position.y - rect_b.size.y / 2)
	y1: f32 = max(rect_a.position.y + rect_a.size.y / 2, rect_b.position.y + rect_b.size.y / 2)
	rect_out = {
		position = { (x0 + x1) / 2, (y0 + y1) / 2 },
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
	rect_out.position += offset
	return rect_out }

H_Align :: enum { Left, Center, Justify, Right }
V_Align :: enum { Bottom, Center, Top }

@(private="file") text_measure :: proc(style: Text_Style, text: string) -> (width: f32, space_count: int) {
	style := style
	using style
	for symbol, i in text {
		font := font_group_select(font_group, style)
		if symbol == '_' {
			style.italic = ! style.italic; continue }
		if symbol == '*' {
			style.bold = ! style.bold; continue }
		symbol_delta: f32 = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
		if symbol == ' ' do symbol_delta *= spacing
		width += symbol_delta
		if symbol == ' ' do space_count += 1 }
	return width, space_count }

@(private="file") text_measure_iterate :: proc(style: ^Text_Style, text: string, i: ^int, width: ^f32, space_count: ^int) -> bool {
	using style
	if i^ >= len(text) do return false
	font := font_group_select(font_group, style^)
	symbol: u8 = text[i^]
	if symbol == '_' || symbol == '*' {
		style.italic = ! style.italic
		style.bold = ! style.bold
		i^ += 1
		return true }
	symbol_delta: f32 = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
	if symbol == ' ' do symbol_delta *= spacing
	width^ += symbol_delta
	if symbol == ' ' do space_count^ += 1
	i^ += 1
	return true }

@(private="file") text_box_lines :: proc(style: Text_Style, rect: Rect, text: string) -> []string {
	using style
	lines := make([dynamic]string, context.temp_allocator)
	line_start_i, prev_i, curr_i, prev_word_end_i, space_count: int
	width, width_acc: f32
	_style := style
	for {
		ok := text_measure_iterate(&_style, text, &curr_i, &width, &space_count)
		if (width <= rect.size.x) && ok {
			if text[prev_i] == ' ' && text[prev_i - 1] != ' ' {
				prev_word_end_i = prev_i
				width_acc = width - cast(f32)font_group.normal.advances[' '] * scale_factor + tracking }
			prev_i = curr_i
		} else {
			if (line_start_i == prev_word_end_i + 1) || !ok do prev_word_end_i = prev_i
			append(&lines, text[line_start_i:prev_word_end_i])
			if !ok do break
			i: int = 0
			for strings.is_space(cast(rune)text[prev_word_end_i + i]) do i += 1
			line_start_i = prev_word_end_i + i
			curr_i += i
			width -= width_acc } }
	shrink(&lines)
	return lines[:] }

SKIP_CUTSET :: "_*"

gui_text_line :: proc(graphics_man: ^Graphics_Manager, style: Text_Style, position: [2]f32, args: ..any, pivot: bit_set[Compass] = {}, depth: f32 = 0.0, sep: string = "", desired_width: Maybe(f32) = nil) {
	style := style
	using style
	text := fmt.aprint(..args, sep = sep)
	position := position
	width, space_count := text_measure(style, text)
	space_delta: f32 = 0
	if space_count != 0 && desired_width != nil do space_delta = (desired_width.(f32) - width) / cast(f32)space_count
	height: f32 = f32(font_group.normal.symbol_size.y) * scale_factor
	if space_delta != 0 { width = desired_width.(f32) }
	position = position - 0.5 * { width, height }
	if .East  in pivot do position.x -= 0.5 * width
	if .West  in pivot do position.x += 0.5 * width
	if .North in pivot do position.y -= 0.5 * height
	if .South in pivot do position.y += 0.5 * height
	symbol_position: [2]f32 = position
	for symbol, i in text {
		if symbol == '_' {
			style.italic = ! style.italic; continue }
		if symbol == '*' {
			style.bold = ! style.bold; continue }
		font := font_group_select(font_group, style)
		render_bitmap_symbol(graphics_man, cast(u8)symbol, symbol_position, depth, style)
		symbol_delta: f32 = 0.0
		symbol_delta = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
		if desired_width == nil && symbol == ' ' do symbol_delta *= spacing
		if symbol == ' ' do symbol_delta += space_delta
		symbol_position.x += symbol_delta } }

WHITESPACE_CUTSET :: "\t\n\v\f\r "

text_box_measure :: proc(style: Text_Style, width: f32, args: ..any, sep: string = "") -> (total_height: f32) {
	using style
	text := fmt.aprint(..args, sep = sep)
	height: f32 = f32(font_group.normal.symbol_size.y) * scale_factor
	rect := make_rect(0, 0, width, 0)
	lines := text_box_lines(style, rect, text)
	total_height = height * cast(f32)len(lines)
	return total_height }

gui_text_box :: proc(graphics_man: ^Graphics_Manager, style: Text_Style, rect: Rect, args: ..any, h_align: H_Align = .Center, v_align: V_Align = .Center, sep: string = "") {
	style := style
	using style
	if h_align == .Justify do spacing = 1.0
	text := fmt.aprint(..args, sep = sep)
	height: f32 = f32(font_group.normal.symbol_size.y) * scale_factor
	position: [2]f32 = rect.position
	lines := text_box_lines(style, rect, text)
	desired_width: Maybe(f32)
	pivot: bit_set[Compass]
	switch v_align {
	case .Top: position.y += rect.size.y / 2 - height / 2
	case .Bottom: position.y += -rect.size.y / 2 + (- 0.5 + cast(f32)len(lines)) * height
	case .Center: position.y += (-1 + 0.5 * cast(f32)len(lines)) * height }
	switch h_align {
	case .Justify:
		desired_width = rect.size.x
	case .Center:
	case .Left:
		pivot = { .West }
		position.x -= rect.size.x / 2
	case .Right:
		desired_width = nil
		pivot = { .East }
		position.x += rect.size.x / 2
	}
	for line, i in lines {
		if h_align == .Justify && i == len(lines) - 1 {
			desired_width = nil
			pivot = { .West }
			position.x -= rect.size.x / 2 }
		gui_text_line(graphics_man, style, position, line, pivot = pivot, desired_width = desired_width)
		position.y -= height } }
