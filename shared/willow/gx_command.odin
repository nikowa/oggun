#+feature using-stmt
package willow
import "core:mem"
import "core:slice"
import "core:math/linalg"
import gl "vendor:OpenGL"
import "core:container/intrusive/list"

// Phases of command processing:
// (1) all commands are stored in a dynamic array
// (2) pointers to the commands are stored in nodes
// (3) nodes are grouped

// Execution_Node :: struct {
// 	commands: list.List }

// Execution_Graph :: struct {
// 	commands: [dynamic]Command,
//	dag: DAG()
// }

// (NOTE): Initially all commands are appended to "commands", then when it's time to submit, they are grouped. //
// (NOTE): Every node on the command tree will be assigned a command buffer. //
Command_Buffer :: struct {
	commands: [dynamic]Command,
	order: list.List }

Command_Group :: [dynamic]^Command

Command_Config :: struct {
	base: union {
		Generic_Command,
		Draw_Image_Command,
		Draw_Text_Command,
		Draw_Rect_Command,
		Draw_Line_Command,
		Draw_Arc_Command } }

Generic_Command :: struct {
	group_params_size: u16 }

Command :: struct {
	using config: Command_Config,
	using node: list.Node,
	submitted: bool }

// command_buffer_search_group :: proc(command_buffer: ^Command_Buffer, search_command: ^Command) -> (group: ^Command_Group) {
// 	for &command_group in command_buffer.command_groups {
// 		if len(command_group) == 0 do continue
// 		if commands_belong_to_same_group({ command_group[0], search_command }) do return &command_group }
// 	return nil }

generic_command_params :: proc(generic_command: ^Generic_Command) -> (params: []u8) {
	ptr: [^]u8 = auto_cast (cast(uintptr)generic_command + size_of(Generic_Command))
	return slice.from_ptr(ptr, cast(int)generic_command.group_params_size) }

@(deprecated="Unimplemented.") command_variant_verify :: proc(Command_Variant: $T) -> bool {
	// (1) The first field must be "using base: Generic_Command"
	// (2) The second field must be named "using *_params: *"
	return true }

command_buffer_init :: proc(command_buffer: ^Command_Buffer) {
	command_buffer.commands = make([dynamic]Command, context.allocator)
	// command_buffer.command_groups = make([dynamic]Command_Group, context.allocator)
}

// last_command
command_buffer_record :: proc(command_buffer: ^Command_Buffer, config: Command_Config) {
	append(&command_buffer.commands, Command{ config = config, submitted = false })
	command := &command_buffer.commands[len(command_buffer.commands) - 1]
}

command_submit :: proc(command: Command, index: int) {
	if command.submitted do return
	switch variant in command.base {
	case Generic_Command: return
	case Draw_Image_Command: gx_submit_image(command, index)
	case Draw_Text_Command:  gx_submit_text(command, index)
	case Draw_Rect_Command:  gx_submit_rect(command, index)
	case Draw_Line_Command:  gx_submit_line(command, index)
	case Draw_Arc_Command:   gx_submit_arc(command, index) }
	engine.graphics_manager.command_buffer.commands[index].submitted = true }

command_buffer_submit :: proc(command_buffer: ^Command_Buffer) {
	// log.infof("Submitting %v commands.", len(command_buffer.commands))
	for command, index in command_buffer.commands do command_submit(command, index)
	clear(&command_buffer.commands) }

commands_belong_to_same_group :: proc(commands: [2]^Command) -> bool {
	generic_0, _ := (commands[0].base).(Generic_Command)
	generic_1, _ := (commands[1].base).(Generic_Command)
	return slice.equal(generic_command_params(&generic_0), generic_command_params(&generic_1)) }

command_buffer_get_group :: proc(command_buffer: ^Command_Buffer, index: int, cond: proc(command_0, command_1: Command) -> bool) -> ([]Command) {
	index_max: int = index + 1
	command := command_buffer.commands[index]
	for ; index_max < len(command_buffer.commands); index_max += 1 {
		command_max := &command_buffer.commands[index_max]
		if ! (cond(command, command_max^)) do break
		command_max.submitted = true }
	return command_buffer.commands[index:index_max] }

commands_compare_params :: proc($Command_Type: typeid, _command_0, _command_1: Command) -> (ok: bool) {
	ok = false
	command_0 := _command_0.base.(Command_Type)
	command_1 := _command_1.base.(Command_Type) or_return
	return command_0.group_params == command_1.group_params }

gx_submit_rect :: proc(_command: Command, index: int) {
	using Rect_Shader_Uniforms

	command := _command.base.(Draw_Rect_Command)

	use_shader(&engine.graphics_manager.rect_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Rect_Command, _command_0, _command_1) })

	buffers := make_buffers(8)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	fill_color := make([][4]f32, n)
	radius := make([]f32, n)
	stroke := make([]f32, n)
	stroke_color := make([][4]f32, n)
	clip := make([][4]f32, n)
	clip_radius := make([]f32, n)

	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.base.(Draw_Rect_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth
		fill_color[k] = gx_color_to_4f32(command.fill_color)
		radius[k] = command.radius
		stroke[k] = command.stroke
		stroke_color[k] = gx_color_to_4f32(command.stroke_color)
		clip[k] = rect_to_4f32(command.clip.rect)
		clip_radius[k] = command.clip.radius }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(2, buffers[2], 4, gl.FLOAT, fill_color)
	upload_vertex_buffer_data(3, buffers[3], 1, gl.FLOAT, radius)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.FLOAT, stroke)
	upload_vertex_buffer_data(5, buffers[5], 4, gl.FLOAT, stroke_color)
	upload_vertex_buffer_data(6, buffers[6], 4, gl.FLOAT, clip)
	upload_vertex_buffer_data(7, buffers[7], 1, gl.FLOAT, clip_radius)

	polygon_mode(.Fill)
	render_triangles(cast(i32)n) }

gx_submit_line :: proc(_command: Command, index: int) {
	using Line_Shader_Uniforms

	command := _command.base.(Draw_Line_Command)

	use_shader(&engine.graphics_manager.line_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Line_Command, _command_0, _command_1) })

	buffers := make_buffers(6)
	defer delete_buffers(buffers)

	n: int = POINT_VERTS_LEN * len(commands)
	point_a := make([][2]f32, n)
	point_b := make([][2]f32, n)
	color := make([][4]f32, n)
	depth := make([]f32, n)
	clip := make([][4]f32, n)
	clip_radius := make([]f32, n)

	for _command, i in commands do for j in 0 ..< POINT_VERTS_LEN {
		command := _command.base.(Draw_Line_Command)
		k := POINT_VERTS_LEN * i + j
		point_a[k] = command.point_a
		point_b[k] = command.point_b
		color[k] = gx_color_to_4f32(command.color)
		depth[k] = command.depth
		clip[k] = rect_to_4f32(command.clip.rect)
		clip_radius[k] = command.clip.radius }
	upload_vertex_buffer_data(0, buffers[0], 2, gl.FLOAT, point_a)
	upload_vertex_buffer_data(1, buffers[1], 2, gl.FLOAT, point_b)
	upload_vertex_buffer_data(2, buffers[2], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(3, buffers[3], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(4, buffers[4], 4, gl.FLOAT, clip)
	upload_vertex_buffer_data(5, buffers[5], 1, gl.FLOAT, clip_radius)

	// (TODO): Make sure "polygon_mode" before every draw call. //
	// TEMP
	gx_set_line_thickness(8)
	polygon_mode(.Line)
	render_lines(cast(i32)n) }

gx_submit_arc :: proc(_command: Command, index: int) {
	using Arc_Shader_Uniforms

	command := _command.base.(Draw_Arc_Command)

	use_shader(&engine.graphics_manager.arc_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Arc_Command, _command_0, _command_1) })

	buffers := make_buffers(7)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	center := make([][2]f32, n)
	radius := make([]f32, n)
	angle_range := make([][2]f32, n)
	color := make([][4]f32, n)
	depth := make([]f32, n)
	clip := make([][4]f32, n)
	clip_radius := make([]f32, n)

	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.base.(Draw_Arc_Command)
		k := QUAD_VERTS_LEN * i + j
		center[k] = command.center
		radius[k] = command.radius
		angle_range[k] = command.angle_range
		color[k] = gx_color_to_4f32(command.color)
		depth[k] = command.depth
		clip[k] = rect_to_4f32(command.clip.rect)
		clip_radius[k] = command.clip.radius }
	upload_vertex_buffer_data(0, buffers[0], 2, gl.FLOAT, center)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, radius)
	upload_vertex_buffer_data(2, buffers[2], 2, gl.FLOAT, angle_range)
	upload_vertex_buffer_data(3, buffers[3], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(5, buffers[5], 4, gl.FLOAT, clip)
	upload_vertex_buffer_data(6, buffers[6], 1, gl.FLOAT, clip_radius)

	polygon_mode(.Fill)
	render_triangles(cast(i32)n) }

gx_submit_image :: proc(_command: Command, index: int) {
	using Image_Shader_Uniforms

	command := _command.base.(Draw_Image_Command)

	assert(image_loaded(command.image))
	use_shader(&engine.graphics_manager.image_shader)
	set_shader_param(RES, linalg.array_cast(engine.graphics_manager.active_resolution, f32))

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Image_Command, _command_0, _command_1) })

	buffers := make_buffers(4)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	clip := make([][4]f32, n)
	clip_radius := make([]f32, n)
	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.base.(Draw_Image_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth
		clip[k] = rect_to_4f32(command.clip.rect)
		clip_radius[k] = command.clip.radius }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(6, buffers[2], 4, gl.FLOAT, clip)
	upload_vertex_buffer_data(7, buffers[3], 1, gl.FLOAT, clip_radius)

	bind_texture(0, command.image.handle)
	polygon_mode(.Fill)
	texture_filtering(gl.NEAREST)
	render_triangles(cast(i32)n) }

gx_submit_text :: proc(_command: Command, index: int) {
	using Text_Uniforms

	command := _command.base.(Draw_Text_Command)

	use_shader(&engine.graphics_manager.text_shader)
	set_shader_param(RES, engine.graphics_manager.active_resolution)
	set_shader_param(SYMBOL_SIZE, command.symbol_size == {} ? command.font.symbol_size : command.symbol_size)
	set_shader_param(TIME, engine.graphics_manager.time)

	commands := command_buffer_get_group(&engine.graphics_manager.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Draw_Text_Command, _command_0, _command_1) })

	buffers := make_buffers(10)
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
	clip_radius := make([]f32, n)
	for _command, i in commands do for j in 0 ..< 6 {
		command := _command.base.(Draw_Text_Command)
		k := 6 * i + j
		scale_factor[k] = command.scale_factor
		color[k] = gx_color_to_4f32(command.color)
		symbol[k] = cast(u32)command.symbol
		position[k] = command.position
		italic[k] = cast(u32)command.italic
		bold[k] = cast(u32)command.bold
		angle[k] = command.angle
		uv_offset[k] = command.uv_offset
		clip[k] = rect_to_4f32(command.clip.rect)
		clip_radius[k] = command.clip.radius }

	upload_vertex_buffer_data(0, buffers[0], 1, gl.UNSIGNED_INT, symbol)
	upload_vertex_buffer_data(1, buffers[1], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(2, buffers[2], 1, gl.FLOAT, scale_factor)
	upload_vertex_buffer_data(3, buffers[3], 3, gl.FLOAT, position)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.UNSIGNED_INT, italic)
	upload_vertex_buffer_data(5, buffers[5], 1, gl.UNSIGNED_INT, bold)
	upload_vertex_buffer_data(6, buffers[6], 1, gl.FLOAT, angle)
	upload_vertex_buffer_data(7, buffers[7], 2, gl.FLOAT, uv_offset)
	upload_vertex_buffer_data(8, buffers[8], 4, gl.FLOAT, clip)
	upload_vertex_buffer_data(9, buffers[9], 1, gl.FLOAT, clip_radius)

	bind_texture(0, command.font.bitmap_image.handle)
	bind_texture(1, command.font.bitmap_image_bold.handle)
	texture_filtering(gl.NEAREST)
	polygon_mode(.Fill)
	render_triangles(cast(i32)n) }
