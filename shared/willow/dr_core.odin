#+feature using-stmt
package willow
import "base:runtime"
import "base:intrinsics"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:strings"
import "core:os"
import "core:math/linalg"
import "core:time"
import "core:log"
import "core:fmt"
import "core:math"
import "core:mem"

Draw_Rect_Command :: struct {
	using base: Generic_Command,
	using params: Draw_Rect_Params,
	using group_params: Draw_Rect_Group_Params }

Draw_Rect_Params :: struct {
	rect: Rect,
	fill_color: Color,
	radius: f32,
	depth: f32,
	stroke: f32,
	stroke_color: Color,
	clip: Clip }

Draw_Rect_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

// (TODO): Change "stroke" to u8
dr_rect :: proc(rect: Rect, fill_color: Color = BLACK, stroke_color: Color = GRAY, radius: f32 = 0.0, stroke: f32 = 0.0, render_buffer: Maybe(^Render_Buffer) = nil, integer: bool = true) {
	command: Draw_Rect_Command = {
		render_buffer = render_buffer,
		rect = integer ? rect_round(rect) : rect,
		// rect = integer ? rect_round_offset(rect, { 0.5, 0.5 }) : rect,
		fill_color = fill_color,
		stroke_color = stroke_color,
		radius = radius,
		stroke = stroke,
		depth = gx_depth_get(),
		clip = gx_clip_get() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

dr_rect_outline :: proc(rect: Rect, color: Color = BLACK, integer: bool = true) {
	a: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y - rect.size.y / 2 }
	b: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y - rect.size.y / 2 }
	c: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y + rect.size.y / 2 + 1 }
	d: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y + rect.size.y / 2 + 1 }
	dr_line({ a, b }, color, integer)
	dr_line({ b, d }, color, integer)
	dr_line({ d, c }, color, integer)
	dr_line({ c, a }, color, integer) }

Draw_Line_Command :: struct {
	using params: Draw_Line_Params,
	using group_params: Draw_Line_Group_Params }

Draw_Line_Params :: struct {
	point_a: [2]f32,
	point_b: [2]f32,
	color: Color,
	depth: f32,
	clip: Clip }

Draw_Line_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

dr_line :: proc(points: [2][2]f32, color: Color, integer: bool = true) {
	command: Draw_Line_Command = {
		point_a = integer ? { math.round_f32(points[0].x), math.round_f32(points[0].y) } : points[0],
		point_b = integer ? { math.round_f32(points[1].x), math.round_f32(points[1].y) } : points[1],
		color = color,
		depth = gx_depth_get(),
		clip = gx_clip_get() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

Draw_Image_Command :: struct {
	using base: Generic_Command,
	using params: dr_image_Params,
	using group_params: dr_image_Group_Params }

dr_image_Params :: struct {
	rect: Rect,
	depth: f32,
	clip: Clip }

dr_image_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer),
	image: ^Image_Asset }

dr_image :: proc(image: ^Image_Asset, rect: Rect, render_buffer: Maybe(^Render_Buffer) = nil, integer: bool = true) {
	command: Draw_Image_Command = {
		render_buffer = render_buffer,
		image = image,
		rect = integer ? rect_round(rect) : rect,
		depth = gx_depth_get(),
		clip = gx_clip_get() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

Draw_Text_Command :: struct {
	using base: Generic_Command,
	using group_params: Draw_Text_Group_Params,
	using params: Draw_Text_Params }

Draw_Text_Group_Params :: struct {
	font: ^Font,
	res: [2]f32,
	symbol_size: [2]f32 }

Draw_Text_Params :: struct {
	symbol: u8,
	color: Color,
	scale_factor: f32,
	position: [3]f32,
	italic: bool,
	bold: bool,
	angle: f32,
	uv_offset: [2]f32,
	clip: Clip }

// (TODO): implement "integer" param. It does nothng right now.
dr_text_symbol_rect :: proc(symbol: u8, rect: Rect, angle: f32 = 0.0, uv_offset: [2]f32 = { 0, 0 }, integer: bool = true) {
	using style := gi_text_style_get()
	font := font_group_select(font_group, style)
	scale_factor := font_size_to_font_scale(font_size, font)
	command: Draw_Text_Command = {
		group_params_size = size_of(Draw_Text_Group_Params),
		font = font,
		symbol_size = rect.size,
		res = engine.graphics_manager.active_resolution,
		scale_factor = scale_factor,
		color = color,
		clip = gx_clip_get() }
	command.symbol = symbol
	command.position = { rect.position.x - scale_factor * rect.size.x / 2, rect.position.y - scale_factor * rect.size.y / 2, gx_depth_get() }
	command.scale_factor = f32(scale_factor)
	command.color = color
	command.italic = italic ? (font_group.italic == font_group.normal) ? true : false : false
	command.bold = bold
	command.angle = angle
	command.uv_offset = uv_offset
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

dr_text_symbol :: proc(symbol: u8, position: [2]f32, angle: f32 = 0.0, integer: bool = true) {
	using style := gi_text_style_get()
	font := font_group_select(font_group, style)
	scale_factor := font_size_to_font_scale(font_size, font)
	command: Draw_Text_Command = {
		group_params_size = size_of(Draw_Text_Group_Params),
		font = font,
		res = engine.graphics_manager.active_resolution,
		scale_factor = scale_factor,
		color = color,
		clip = gx_clip_get() }
	command.symbol = symbol
	command.position = [3]f32{ f32(position.x), f32(position.y), gx_depth_get() }
	command.position.x -= f32(command.font.bearings[symbol]) * scale_factor
	command.scale_factor = f32(scale_factor)
	command.color = color
	command.position.x = integer ? math.round_f32(command.position.x + 0.3) : command.position.x
	command.position.y = integer ? math.round_f32(command.position.y + 0.3) : command.position.y
	command.italic = italic ? (font_group.italic == font_group.normal) ? true : false : false
	command.bold = bold
	command.angle = angle
	command.uv_offset = { 0, 0 }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

// (TODO): "integer" should also be a stack parameter. //
dr_text_line :: proc(text: string, position: [2]f32, pivot: bit_set[Compass] = { .South }, desired_width: Maybe(f32) = nil, integer: bool = true) -> f32 {
	gi_text_style_checkpoint()
	return dr_text_line_compound(text, position, pivot, desired_width, integer) }

dr_text_line_compound :: proc(text: string, position: [2]f32, pivot: bit_set[Compass] = { .South }, desired_width: Maybe(f32) = nil, integer: bool = true) -> f32 {
	using style := gi_text_style_get()
	// dr_rect({ position = position, size = { 4, 4 } }, BLUE)
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	position := position
	width, space_count := gi_measure_text(text, scale_factor)
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
	// dr_line(graphics_manager, { position, position + { width, 0 } }, RED)
	// dr_rect(graphics_manager, { position + { width / 2, height / 2 }, { width, height } }, GREEN, depth = 0.1)
	// position.y -= cast(f32)font_group.normal.origin * scale_factor
	symbol_position: [2]f32 = position
	for symbol, i in text {
		style = gi_text_style_get()
		// (TODO): Add an option for these to be escaped, so that they can be printed. //
		if symbol == '_' {
			if style.italic {
				gi_text_style_pop()
			}
			else {
				new_style := style
				new_style.italic = true
				gi_text_style_push(new_style)
			}
			continue }
		if symbol == '*' {
			if style.bold {
				gi_text_style_pop()
			}
			else {
				new_style := style
				new_style.bold = true
				gi_text_style_push(new_style)
			}
			continue }
		font := font_group_select(font_group, style)
		dr_text_symbol(cast(u8)symbol, symbol_position, integer = integer)
		symbol_delta: f32 = 0.0
		symbol_delta = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
		if desired_width == nil && symbol == ' ' do symbol_delta *= spacing
		if symbol == ' ' do symbol_delta += space_delta
		symbol_position.x += symbol_delta }
	return width }

// (TODO): Maybe some of these params should be on a stack. //
dr_text_box :: proc(text: string, rect: Rect, background_color: Color=0, h_align: GUI_H_Align = .CENTER, v_align: GUI_V_Align = .CENTER, integer: bool = true) -> (max_width: f32) {
	if rect_is_empty(rect) do return
	using style := gi_text_style_get()
	gi_text_style_checkpoint()
	// dr_rect_outline(graphics_manager, rect, BLUE, 0.1)
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	if h_align == .JUSTIFY do spacing = 1.0
	// (TODO): This looks wrong v
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	line_distance: f32 = height * style.leading
	line_height: f32 = height * (1.0 + style.leading)
	position: [2]f32 = rect.position
	lines := gi_text_box_lines(rect, text, scale_factor)
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
	origin := position
	for line, i in lines {
		if h_align == .JUSTIFY && i == len(lines) - 1 {
			desired_width = nil
			pivot = { .West }
			position.x -= rect.size.x / 2 }
		width := dr_text_line_compound(line, position, pivot = pivot + { .South }, desired_width = desired_width, integer = integer)
		if width > max_width do max_width = width
		position.y -= line_height }
	gx_depth_scope_inc(0.01) // (TODO): Make this a DEPTH_DELTA constant. //
	if background_color != 0 {
		background_rect: Rect
		background_rect.size = { max_width, total_height }
		background_rect.position = origin + background_rect.size / 2
		// (TODO): Add "margins" and "padding" stacks to "gi_manager". //
		dr_rect(gi_rect_extend(background_rect, Interval(4)), background_color) }
	return max_width }
