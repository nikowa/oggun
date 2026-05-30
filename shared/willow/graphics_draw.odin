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
	rounding: f32,
	depth: f32,
	stroke: f32,
	stroke_color: Color,
	clip: Rect }

Draw_Rect_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

// (TODO): Rename "rounding" to "radius" and make it "f32". //
// (TODO): Change "stroke" to u8
draw_rect :: proc(rect: Rect, fill_color: Color = BLACK, stroke_color: Color = GRAY, rounding: f32 = 0.0, depth: f32 = 0.0, stroke: f32 = 0.0, render_buffer: Maybe(^Render_Buffer) = nil, integer: bool = true) {
	command: Draw_Rect_Command = {
		render_buffer = render_buffer,
		rect = integer ? rect_round(rect) : rect,
		// rect = integer ? rect_round_offset(rect, { 0.5, 0.5 }) : rect,
		fill_color = fill_color,
		stroke_color = stroke_color,
		rounding = rounding,
		stroke = stroke,
		depth = depth,
		clip = gx_get_clip() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

submit_draw_rect :: proc(_command: Command, index: int) {
	using Rect_Shader_Uniforms

	command := _command.base.(Draw_Rect_Command)

	use_shader(&engine.graphics_manager.rect_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Rect_Command, _command_0, _command_1) })

	buffers := make_buffers(7)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	fill_color := make([][4]f32, n)
	rounding := make([]f32, n)
	stroke := make([]f32, n)
	stroke_color := make([][4]f32, n)
	clip := make([][4]f32, n)

	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.base.(Draw_Rect_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth
		fill_color[k] = color_to_4f32(command.fill_color)
		rounding[k] = command.rounding
		stroke[k] = command.stroke
		stroke_color[k] = color_to_4f32(command.stroke_color)
		clip[k] = rect_to_4f32(command.clip) }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(2, buffers[2], 4, gl.FLOAT, fill_color)
	upload_vertex_buffer_data(3, buffers[3], 1, gl.FLOAT, rounding)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.FLOAT, stroke)
	upload_vertex_buffer_data(5, buffers[5], 4, gl.FLOAT, stroke_color)
	upload_vertex_buffer_data(6, buffers[6], 4, gl.FLOAT, clip)

	polygon_mode(.Fill)
	render_triangles(cast(i32)n) }

draw_rect_outline :: proc(rect: Rect, color: Color = BLACK, depth: f32 = 0.0, integer: bool = true) {
	a: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y - rect.size.y / 2 }
	b: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y - rect.size.y / 2 }
	c: [2]f32 = { rect.position.x - rect.size.x / 2, rect.position.y + rect.size.y / 2 + 1 }
	d: [2]f32 = { rect.position.x + rect.size.x / 2 + 1, rect.position.y + rect.size.y / 2 + 1 }
	draw_line({ a, b }, color, depth, integer)
	draw_line({ b, d }, color, depth, integer)
	draw_line({ d, c }, color, depth, integer)
	draw_line({ c, a }, color, depth, integer) }

Draw_Line_Command :: struct {
	using params: Draw_Line_Params,
	using group_params: Draw_Line_Group_Params }

Draw_Line_Params :: struct {
	point_a: [2]f32,
	point_b: [2]f32,
	color: Color,
	depth: f32,
	clip: Rect }

Draw_Line_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

draw_line :: proc(points: [2][2]f32, color: Color, depth: f32 = 0.0, integer: bool = true) {
	command: Draw_Line_Command = {
		point_a = integer ? { math.round_f32(points[0].x), math.round_f32(points[0].y) } : points[0],
		point_b = integer ? { math.round_f32(points[1].x), math.round_f32(points[1].y) } : points[1],
		color = color,
		depth = depth,
		clip = gx_get_clip() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

submit_draw_line :: proc(_command: Command, index: int) {
	using Line_Shader_Uniforms

	command := _command.base.(Draw_Line_Command)

	use_shader(&engine.graphics_manager.line_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Line_Command, _command_0, _command_1) })

	buffers := make_buffers(5)
	defer delete_buffers(buffers)

	n: int = POINT_VERTS_LEN * len(commands)
	point_a := make([][2]f32, n)
	point_b := make([][2]f32, n)
	color := make([][4]f32, n)
	depth := make([]f32, n)
	clip := make([][4]f32, n)

	for _command, i in commands do for j in 0 ..< POINT_VERTS_LEN {
		command := _command.base.(Draw_Line_Command)
		k := POINT_VERTS_LEN * i + j
		point_a[k] = command.point_a
		point_b[k] = command.point_b
		color[k] = color_to_4f32(command.color)
		depth[k] = command.depth
		clip[k] = rect_to_4f32(command.clip) }
	upload_vertex_buffer_data(0, buffers[0], 2, gl.FLOAT, point_a)
	upload_vertex_buffer_data(1, buffers[1], 2, gl.FLOAT, point_b)
	upload_vertex_buffer_data(2, buffers[2], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(3, buffers[3], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(4, buffers[4], 4, gl.FLOAT, clip)

	// (TODO): Make sure "polygon_mode" before every draw call. //
	polygon_mode(.Line)
	render_lines(cast(i32)n) }

Draw_Image_Command :: struct {
	using base: Generic_Command,
	using params: draw_image_Params,
	using group_params: draw_image_Group_Params }

draw_image_Params :: struct {
	rect: Rect,
	depth: f32,
	clip: Rect }

draw_image_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer),
	image: ^Image_Asset }

draw_image :: proc(image: ^Image_Asset, rect: Rect, depth: f32 = 0.0, render_buffer: Maybe(^Render_Buffer) = nil, integer: bool = true) {
	command: Draw_Image_Command = {
		render_buffer = render_buffer,
		image = image,
		rect = integer ? rect_round(rect) : rect,
		depth = depth,
		clip = gx_get_clip() }
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

// (NOTE): This will do the batching. //
submit_draw_image :: proc(_command: Command, index: int) {
	// using Image_Uniforms
	// assert(image_loaded(command.image))
	// use_shader(&graphics_manager.image_shader)
	// gl.BindVertexArray(graphics_manager.vertex_array)
	// gl.BindBuffer(gl.ARRAY_BUFFER, graphics_manager.vertex_buffer)
	// set_shader_param(POS, command.rect.position)
	// set_shader_param(SIZE, command.rect.size)
	// bind_texture(0, command.image.handle)
	// texture_filtering(gl.NEAREST)
	// render_triangles(6)

	using Image_Shader_Uniforms

	command := _command.base.(Draw_Image_Command)

	assert(image_loaded(command.image))
	use_shader(&engine.graphics_manager.image_shader)
	set_shader_param(RES, linalg.array_cast(engine.graphics_manager.active_resolution, f32))

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Image_Command, _command_0, _command_1) })

	buffers := make_buffers(3)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	clip := make([][4]f32, n)
	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.base.(Draw_Image_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth
		clip[k] = rect_to_4f32(command.clip) }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(6, buffers[2], 4, gl.FLOAT, clip)

	bind_texture(0, command.image.handle)
	polygon_mode(.Fill)
	texture_filtering(gl.NEAREST)
	render_triangles(cast(i32)n) }

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
	clip: Rect }

// (TODO): implement "integer" param. It does nothng right now.
draw_text_symbol_rect :: proc(symbol: u8, rect: Rect, depth: f32, style: Text_Style = DEFAULT_TEXT_STYLE, angle: f32 = 0.0, uv_offset: [2]f32 = { 0, 0 }, integer: bool = true) {
	using style
	font := font_group_select(font_group, style)
	scale_factor := font_size_to_font_scale(font_size, font)
	command: Draw_Text_Command = {
		group_params_size = size_of(Draw_Text_Group_Params),
		font = font,
		symbol_size = rect.size,
		res = engine.graphics_manager.active_resolution,
		scale_factor = scale_factor,
		color = color,
		clip = gx_get_clip() }
	command.symbol = symbol
	command.position = { rect.position.x - rect.size.x / 2, rect.position.y - rect.size.y / 2, depth }
	command.scale_factor = f32(scale_factor)
	command.color = color
	command.italic = italic ? (font_group.italic == font_group.normal) ? true : false : false
	command.bold = bold
	command.angle = angle
	command.uv_offset = uv_offset
	command_buffer_record(&engine.graphics_manager.command_buffer, { base = command }) }

draw_text_symbol :: proc(symbol: u8, position: [2]f32, depth: f32, style: Text_Style = DEFAULT_TEXT_STYLE, angle: f32 = 0.0, integer: bool = true) {
	using style
	font := font_group_select(font_group, style)
	scale_factor := font_size_to_font_scale(font_size, font)
	command: Draw_Text_Command = {
		group_params_size = size_of(Draw_Text_Group_Params),
		font = font,
		res = engine.graphics_manager.active_resolution,
		scale_factor = scale_factor,
		color = color,
		clip = gx_get_clip() }
	command.symbol = symbol
	command.position = [3]f32{ f32(position.x), f32(position.y), depth }
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

submit_draw_text :: proc(_command: Command, index: int) {
	using Text_Uniforms

	command := _command.base.(Draw_Text_Command)

	use_shader(&engine.graphics_manager.text_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)
	set_shader_param(SYMBOL_SIZE, command.symbol_size == {} ? command.font.symbol_size : command.symbol_size)
	set_shader_param(TIME, engine.graphics_manager.time)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Text_Command, _command_0, _command_1) })

	buffers := make_buffers(9)
	defer delete_buffers(buffers)

	n: int = 6 * len(commands)
	scale_factor := make([]f32, n)
	color := make([][4]f32, n)
	symbol := make([]u32, n)
	position := make([][3]f32, n)
	italic := make([]u32, n)
	bold := make([]u32, n)
	angle := make([]f32, n)
	uv_offset := make([][2]f32, n)
	clip := make([][4]f32, n)
	for _command, i in commands do for j in 0 ..< 6 {
		command := _command.base.(Draw_Text_Command)
		k := 6 * i + j
		scale_factor[k] = command.scale_factor
		color[k] = color_to_4f32(command.color)
		symbol[k] = cast(u32)command.symbol
		position[k] = command.position
		italic[k] = cast(u32)command.italic
		bold[k] = cast(u32)command.bold
		angle[k] = command.angle
		uv_offset[k] = command.uv_offset
		clip[k] = rect_to_4f32(command.clip) }

	upload_vertex_buffer_data(0, buffers[0], 1, gl.UNSIGNED_INT, symbol)
	upload_vertex_buffer_data(1, buffers[1], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(2, buffers[2], 1, gl.FLOAT, scale_factor)
	upload_vertex_buffer_data(3, buffers[3], 3, gl.FLOAT, position)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.UNSIGNED_INT, italic)
	upload_vertex_buffer_data(5, buffers[5], 1, gl.UNSIGNED_INT, bold)
	upload_vertex_buffer_data(6, buffers[6], 1, gl.FLOAT, angle)
	upload_vertex_buffer_data(7, buffers[7], 2, gl.FLOAT, uv_offset)
	upload_vertex_buffer_data(8, buffers[8], 4, gl.FLOAT, clip)

	bind_texture(0, command.font.bitmap_image.handle)
	bind_texture(1, command.font.bitmap_image_bold.handle)
	texture_filtering(gl.NEAREST)
	polygon_mode(.Fill)
	render_triangles(cast(i32)n) }
