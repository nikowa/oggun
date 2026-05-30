#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"

// (TODO): Add TGUI versions of all of these, using the default TGUI styles.

draw_text_line :: proc(style: Text_Style, position: [2]f32, args: ..any, pivot: bit_set[Compass] = { .South }, depth: f32 = 0.0, sep: string = "", desired_width: Maybe(f32) = nil, integer: bool = true) {
	style := style
	using style
	// draw_rect({ position = position, size = { 4, 4 } }, BLUE)
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	text := fmt.aprint(..args, sep = sep)
	position := position
	width, space_count := _measure_text(style, text, scale_factor)
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	space_delta: f32 = 0
	if space_count != 0 && desired_width != nil do space_delta = (desired_width.(f32) - width) / cast(f32)space_count
	if space_delta != 0 { width = desired_width.(f32) }
	position.x -= 0.5 * width
	position.y -= cast(f32)font_group.normal.origin * scale_factor
	position.y -= 0.5 * height
	if .East  in pivot do position.x -= 0.5 * width
	if .West  in pivot do position.x += 0.5 * width
	if .North  in pivot do position.y -= 0.5 * height
	if .South  in pivot do position.y += 0.5 * height
	// draw_line(graphics_manager, { position, position + { width, 0 } }, RED)
	// draw_rect(graphics_manager, { position + { width / 2, height / 2 }, { width, height } }, GREEN, depth = 0.1)
	// position.y -= cast(f32)font_group.normal.origin * scale_factor
	symbol_position: [2]f32 = position
	for symbol, i in text {
		if symbol == '_' {
			style.italic = ! style.italic; continue }
		if symbol == '*' {
			style.bold = ! style.bold; continue }
		font := font_group_select(font_group, style)
		draw_text_symbol(cast(u8)symbol, symbol_position, depth, style, integer = integer)
		symbol_delta: f32 = 0.0
		symbol_delta = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
		if desired_width == nil && symbol == ' ' do symbol_delta *= spacing
		if symbol == ' ' do symbol_delta += space_delta
		symbol_position.x += symbol_delta } }

draw_text_box :: proc(style: Text_Style, rect: Rect, args: ..any, h_align: GUI_H_Align = .CENTER, v_align: GUI_V_Align = .CENTER, depth: f32 = 0.0, sep: string = "", integer: bool = true) {
	style := style
	using style
	// draw_rect_outline(graphics_manager, rect, BLUE, 0.1)
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	if h_align == .JUSTIFY do spacing = 1.0
	text := fmt.aprint(..args, sep = sep)
	// (TODO): This looks wrong v
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	line_distance: f32 = height * style.leading
	line_height: f32 = height * (1.0 + style.leading)
	position: [2]f32 = rect.position
	lines := _text_box_lines(style, rect, text, scale_factor)
	n: int = len(lines)
	total_height := height * f32(n) + cast(f32)max(0, n - 1) * line_distance
	desired_width: Maybe(f32)
	pivot: bit_set[Compass]
	switch v_align {
	case .TOP: position.y += rect.size.y / 2 - height
	case .BOTTOM: position.y += -rect.size.y / 2 + total_height - height
	case .CENTER: position.y += 0.5 * total_height - line_height + height / 2 }
	switch h_align {
	case .JUSTIFY:
		desired_width = rect.size.x
	case .CENTER:
	case .LEFT:
		pivot = { .West }
		position.x -= rect.size.x / 2
	case .RIGHT:
		desired_width = nil
		pivot = { .East }
		position.x += rect.size.x / 2
	}
	for line, i in lines {
		if h_align == .JUSTIFY && i == len(lines) - 1 {
			desired_width = nil
			pivot = { .West }
			position.x -= rect.size.x / 2 }
		draw_text_line(style, position, line, pivot = pivot + { .South }, desired_width = desired_width, depth = depth, integer = integer)
		position.y -= line_height } }

_measure_text :: proc(style: Text_Style, text: string, scale_factor: f32) -> (width: f32, space_count: int) {
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

_measure_text_iterate :: proc(style: ^Text_Style, text: string, i: ^int, width: ^f32, space_count: ^int, scale_factor: f32) -> bool {
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

_text_box_lines :: proc(style: Text_Style, rect: Rect, text: string, scale_factor: f32) -> []string {
	using style
	lines := make([dynamic]string, context.temp_allocator)
	line_start_i, prev_i, curr_i, prev_word_end_i, space_count: int
	width, width_acc: f32
	_style := style
	for {
		ok := _measure_text_iterate(&_style, text, &curr_i, &width, &space_count, scale_factor)
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

_measure_text_box :: proc(style: Text_Style, width: f32, args: ..any, sep: string = "") -> (total_height: f32) {
	using style
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	text := fmt.aprint(..args, sep = sep)
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	line_distance: f32 = height * style.leading
	rect := make_rect(0, 0, width, 0)
	lines := _text_box_lines(style, rect, text, scale_factor)
	n: int = len(lines)
	total_height = height * f32(n) + cast(f32)max(0, n - 1) * line_distance
	return total_height }


