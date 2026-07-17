#+feature using-stmt
package oggun
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
import "core:slice"

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
	// (TODO): Test culling. Add culling to other primitives. //
	clip := gx_clip_get()
	if gx_rect_cull(rect, clip) do return
	command: Draw_Rect_Command = {
		render_buffer = render_buffer,
		rect = integer ? rect_round(rect) : rect,
		// rect = integer ? rect_round_offset(rect, { 0.5, 0.5 }) : rect,
		fill_color = fill_color,
		stroke_color = stroke_color,
		radius = radius,
		stroke = stroke,
		depth = gx_depth_get(),
		clip = clip }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

dr_rect_outline :: proc(rect: Rect, color: Color = BLACK, integer: bool = true) {
	a: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y - rect.size.y / 2 }
	b: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y - rect.size.y / 2 }
	c: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y + rect.size.y / 2 + 1 }
	d: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y + rect.size.y / 2 + 1 }
	dr_path({ a, b, d, c, a }, color, integer)
	// dr_line({ a, b }, color, integer)
	// dr_line({ b, d }, color, integer)
	// dr_line({ d, c }, color, integer)
	// dr_line({ c, a }, color, integer)
}

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

// Draw_Hermite_Command :: struct {
// 	using params: Draw_Hermite_Params,
// 	using group_params: Draw_Hermite_Group_Params }

// Draw_Hermite_Params :: struct {
// 	point_a: [2]f32,
// 	point_b: [2]f32,
// 	color: Color,
// 	depth: f32,
// 	clip: Clip }

// Draw_Hermite_Group_Params :: struct {
// 	render_buffer: Maybe(^Render_Buffer) }

// dr_hermite :: proc(points: [2][2]f32, color: Color, integer: bool = true) {
// 	command: Draw_Line_Command = {
// 		point_a = integer ? { math.round_f32(points[0].x), math.round_f32(points[0].y) } : points[0],
// 		point_b = integer ? { math.round_f32(points[1].x), math.round_f32(points[1].y) } : points[1],
// 		color = color,
// 		depth = gx_depth_get(),
// 		clip = gx_clip_get() }
// 	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

Draw_Arc_Command :: struct {
	using params: Draw_Arc_Params,
	using group_params: Draw_Arc_Group_Params }

Draw_Arc_Params :: struct {
	center: [2]f32,
	radius: f32,
	angle_range: [2]f32,
	color: Color,
	depth: f32,
	clip: Clip }

Draw_Arc_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

dr_arc :: proc(center: [2]f32, radius: f32, angle_range: [2]f32, color: Color, integer: bool = true) {
	command: Draw_Arc_Command = {
		center = integer ? { math.round_f32(center.x), math.round_f32(center.y) } : center,
		radius = radius,
		angle_range = angle_range,
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
	using style := ui_text_style_get()
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
	using style := ui_text_style_get()
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
	ui_text_style_checkpoint()
	return dr_text_line_compound(text, position, pivot, desired_width, integer) }

dr_text_line_compound :: proc(text: string, position: [2]f32, pivot: bit_set[Compass] = { .South }, desired_width: Maybe(f32) = nil, integer: bool = true) -> f32 {
	using style := ui_text_style_get()
	// dr_rect({ position = position, size = { 4, 4 } }, BLUE)
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	position := position
	width, space_count := ui_measure_text(text, scale_factor)
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
		style = ui_text_style_get()
		// (TODO): Add an option for these to be escaped, so that they can be printed. //
		if symbol == '_' {
			if style.italic {
				ui_text_style_pop()
			}
			else {
				new_style := style
				new_style.italic = true
				ui_text_style_push(new_style)
			}
			continue }
		if symbol == '*' {
			if style.bold {
				ui_text_style_pop()
			}
			else {
				new_style := style
				new_style.bold = true
				ui_text_style_push(new_style)
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

AUTO_SIZE: [2]f32 : {}

// (TODO): Maybe some of these params should be on a stack. //
dr_text_box :: proc(text: string, rect: Rect, background_color: Color=0, h_align: UI_H_Align = .CENTER, v_align: UI_V_Align = .CENTER, ratio: f32 = 3.0, origin: bit_set[Compass] = {}, margins: f32 = 4, overflow: UI_Overflow = .EXTEND, integer: bool = true, debug: bool = false) -> Rect {
	rect := rect
	if debug do dr_rect_outline(rect, CYAN - 0x88)
	if text == "" do return {}
	using style := ui_text_style_get()
	ui_text_style_checkpoint()
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	if h_align == .JUSTIFY do spacing = 1.0
	text_width, _ := ui_measure_text(text, scale_factor)
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	line_distance: f32 = height * style.leading
	line_height: f32 = height * (1.0 + style.leading)
	if rect.size == {} {
		n_lines := math.sqrt_f32(text_width / (line_height * ratio))
		rect.size.x = text_width / math.floor_f32(n_lines)
		rect.size.y = math.ceil_f32(n_lines) * line_height }
	if debug do dr_rect({ rect.position, { 4, 4 } }, GREEN)
	if overflow == .CLIP do gx_clip_push({ rect=ui_rect_extend(rect, Interval(margins)) })
	defer if overflow == .CLIP do gx_clip_pop()
	position: [2]f32 = rect.position
	lines := ui_text_box_lines(rect, text, scale_factor)
	n: int = len(lines)
	total_height := height * f32(n) + cast(f32)max(0, n - 1) * line_distance
	desired_width: Maybe(f32)
	max_width: f32
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
		position.x += rect.size.x / 2 }
	bounds: [2]f32 = { position.y + line_height, position.y - line_height * f32(n) + line_height - line_distance }
	offset: [2]f32
	if .South in origin do offset.y += rect.position.y - bounds[1] + margins
	if .North in origin do offset.y += rect.position.y - bounds[0] - margins
	bounds[0] += offset.y
	bounds[1] += offset.y
	position.y += offset.y
	if debug do dr_rect({ { position.x, bounds[0] }, { 4, 4 } }, RED)
	if debug do dr_rect({ { position.x, bounds[1] }, { 4, 4 } }, RED)
	for line, i in lines {
		if h_align == .JUSTIFY && i == len(lines) - 1 {
			desired_width = nil
			pivot = { .West }
			position.x -= rect.size.x / 2 }
		width := dr_text_line_compound(line, position, pivot = pivot + { .South }, desired_width = desired_width, integer = integer)
		if width > max_width do max_width = width
		position.y -= line_height }
	content_rect := rect
	if overflow == .EXTEND {
		content_rect = ui_rect_position_top(content_rect, bounds[0])
		content_rect = ui_rect_position_bottom(content_rect, bounds[1]) }
	if debug do dr_rect_outline(content_rect, CYAN)
	gx_depth_scope_inc(0.01) // (TODO): Make this a DEPTH_DELTA constant. //
	if background_color != 0 do dr_rect(ui_rect_extend(content_rect, Interval(margins)), background_color)
	return content_rect }

dr_path :: proc(points: [][2]f32, color: Color, integer: bool = true) {
	for _, i in 0 ..< len(points) - 1 do dr_line({ points[i], points[i + 1] }, color, integer) }

dr_path_corner :: proc(points: [3][2]f32, radius: f32, color: Color, integer: bool=true) {
	diagonal: [2]f32 = (points[2] - points[1]) + (points[0] - points[1])
	if (diagonal.x == 0) || (diagonal.y == 0) do return
	signs: [2]f32 = { math.sign(diagonal.x), math.sign(diagonal.y) }
	switch signs {
	case { +1, +1 }:
		dr_arc(center=points[1] + { radius, radius }, radius=radius, angle_range={
			math.to_radians_f32(180), math.to_radians_f32(270) }, color=color, integer=integer)
	case { +1, -1 }:
		dr_arc(center=points[1] + { radius, -radius }, radius=radius, angle_range={
			math.to_radians_f32(90), math.to_radians_f32(180) }, color=color, integer=integer)
	case { -1, +1 }:
		dr_arc(center=points[1] + { -radius, radius }, radius=radius, angle_range={
			math.to_radians_f32(270), math.to_radians_f32(360) }, color=color, integer=integer)
	case { -1, -1 }:
		dr_arc(center=points[1] + { -radius, -radius }, radius=radius, angle_range={
			math.to_radians_f32(0), math.to_radians_f32(90) }, color=color, integer=integer) } }

dr_point_labeled :: proc(point: [2]f32, label: string, label_offset: [2]f32, color: Color) {
	dr_rect({ point, { 3, 3 } }, fill_color=color)
	dr_text_line(label, point + label_offset, pivot={ .South }, desired_width=nil, integer=true) }

path_is_linear :: proc(path: [][2]f32) -> bool {
	for _, i in 0 ..< len(path) - 1 do if ! points_are_rectilinear({ path[i], path[i + 1] }) do return false
	return true }

rectilinear_length :: proc(vector: [2]f32) -> f32 {
	return abs((vector.x != 0) ? vector.x : vector.y) }

path_cleanup :: proc(path: [][2]f32) -> [][2]f32 {
	result := make([dynamic][2]f32, 0, len(path))
	to_remove := runtime.make_dynamic_array_len_cap([dynamic]int, 0, len(path))
	for i in 0 ..< len(path) - 2 do for j in 0 ..< 2 do if (path[i][j] == path[i + 1][j]) && (path[i + 1][j] == path[i + 2][j]) do append(&to_remove, i + 1)
	for point, i in path do if ! slice.contains(to_remove[:], i) do append(&result, point)
	shrink(&result)
	return result[:] }

dr_path_rounded :: proc(points: [][2]f32, radius: f32, color: Color, integer: bool = true, debug: bool = false) {
	points := path_cleanup(points)
	lengths: []f32 = make([]f32, len(points) - 1)
	radiuses: []f32 = make([]f32, len(points) - 2)
	for i in 0 ..< len(points) - 1 do lengths[i] = rectilinear_length(points[i] - points[i + 1])
	for i in 1 ..< len(points) - 1 {
		radiuses[i - 1] = min(radius, lengths[i - 1] / 2, lengths[i] / 2)
		if debug do dr_point_labeled(points[i], fmt.aprint(radiuses[i - 1]), { 6, 6 }, CYAN)
		dr_path_corner({ points[i - 1], points[i], points[i + 1] }, radiuses[i - 1], color, integer) }
	for i in 0 ..< len(points) - 1 {
		line: [2][2]f32 = { points[i], points[i + 1] }
		if (i > 0) && (i < len(points) - 2) && rectilinear_length(line[1] - line[0]) <= 2 * radius do continue
		if i > 0 do line = line_trim_head(line, radiuses[i - 1])
		if i < len(points) - 2 do line = line_trim_tail(line, radiuses[i])
		if debug do for j in 0 ..< 2 do dr_rect({ line[j], { 3, 3 } }, RED)
		dr_line(line, color, integer)
		if debug do dr_point_labeled((points[i] + points[i + 1]) / 2, fmt.aprint(lengths[i]), { 6, 6 }, WHITE) } }

dr_path_hermite :: proc(points: [][2]f32, radius: f32, color: Color, tangent: f32 = 200, integer: bool = true) {
	points := path_cleanup(points)
	hermite_points := make([][2]f32, len(points) + 1)
	hermite_tangents := make([][2]f32, len(hermite_points))
	last := len(points) - 1
	hlast := len(hermite_points) - 1
	hermite_points[0] = points[0]
	hermite_tangents[0] = points[1] - points[0]
	hermite_points[hlast] = points[last]
	hermite_tangents[hlast] = points[last] - points[last - 1]
	for i in 0 ..< last {
		hermite_points[i + 1] = (points[i] + points[i + 1]) / 2
		hermite_tangents[i + 1] = points[i + 1] - points[i] }
	length := path_length(points)
	dr_hermite_spline(hermite_points, hermite_tangents, u32(length / 16), color, debug=false) }

line_tangent :: proc(line: [2][2]f32) -> [2]f32 {
	return linalg.normalize(line[1] - line[0]) }

line_extend_head :: proc(line: [2][2]f32, delta: f32) -> [2][2]f32 {
	line := line
	line[0] -= line_tangent(line) * delta
	return line }

line_extend_tail :: proc(line: [2][2]f32, delta: f32) -> [2][2]f32 {
	line := line
	line[1] += line_tangent(line) * delta
	return line }

line_trim_head :: proc(line: [2][2]f32, delta: f32) -> [2][2]f32 {
	return line_extend_head(line, -delta) }

line_trim_tail :: proc(line: [2][2]f32, delta: f32) -> [2][2]f32 {
	return line_extend_tail(line, -delta) }

dr_curve :: proc(func: proc(t: f32) -> [2]f32, res: u32, color: Color) {
	points: [][2]f32 = make([][2]f32, res + 1)
	for i in 0 ..= res {
		t: f32 = f32(i) / f32(res)
		points[i] = func(t) }
	for i in 0 ..< res {
		dr_line({ points[i], points[i + 1] }, color, integer=false)
		for j in 0 ..< 2 do dr_rect({ points[i], { 3, 3 } }, fill_color=RED) } }

dr_hermite :: proc(ends: [2][2]f32, tangents: [2][2]f32, res: u32, color: Color, debug: bool=false) {
	points: [][2]f32 = make([][2]f32, res + 1)
	for i in 0 ..= res {
		t: f32 = f32(i) / f32(res)
		points[i] = linalg.hermite(ends[0], tangents[0], ends[1], tangents[1], t) }
	if debug do dr_rect({ points[0], { 3, 3 } }, fill_color=RED)
	for i in 0 ..< res {
		dr_line({ points[i], points[i + 1] }, color, integer=false)
		if debug do dr_rect({ points[i + 1], { 3, 3 } }, fill_color=RED)
	}
	if debug {
		for i in 0 ..< 2 do dr_rect({ ends[i], { 3, 3 } }, fill_color=WHITE)
		dr_rect({ ends[0] + tangents[0], { 3, 3 } }, fill_color=GREEN)
		dr_rect({ ends[1] + tangents[1], { 3, 3 } }, fill_color=GREEN)
		dr_line({ ends[0], ends[0] + tangents[0] }, GREEN)
		dr_line({ ends[1], ends[1] + tangents[1] }, GREEN) } }

dr_hermite_spline :: proc(points: [][2]f32, tangents: [][2]f32, res: u32, color: Color, debug: bool=false) {
	assert(len(points) == len(tangents))
	for i in 0 ..< len(points) - 1 {
		dr_hermite({ points[i], points[i + 1] }, { tangents[i], tangents[i + 1] }, res, color, debug) } }
