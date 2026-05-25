#+feature using-stmt
package willow
import gl "vendor:OpenGL"
import "core:os"
import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"

// Derived from staffmaster/font.odin

Font_Config :: struct #all_or_none {
	name: string,
	default_bearing: u8,
	default_advance: u8 }
	// height: u8,
	// center_height: u8 }

DEFAULT_FONT_CONFIG: Font_Config : {
	name = "font",
	default_bearing = 0,
	default_advance = 0 }

Font :: struct {
	using font_config: Font_Config,
	bitmap_image: ^Image_Asset,
	bitmap_image_bold: ^Image_Asset,
	positions_string: String_Asset,
	symbol_size: [2]f32,
	bearings: [256]u8,
	advances: [256]u8,
	height: u8,  // height of an uppercase symbol in pixels.
	origin: u8 } // distance in pixels from bottom edge to horizon line.

Font_Group :: struct {
	normal: ^Font,
	bold, italic: ^Font }

Font_Size :: distinct u8

font_size_to_font_scale :: proc(font_size: Font_Size, font: ^Font) -> (font_scale: f32) {
	return cast(f32)font_size / cast(f32)font.height }

// (TODO): Make a "Font_Size" u8 type and make it absolute rather than relative to the size of the

font_group_init :: proc(asset_man: ^Asset_Manager, font_group: ^Font_Group, normal: Font_Config, bold: Maybe(Font_Config) = nil, italic: Maybe(Font_Config) = nil) {
	font_group.normal = new(Font)
	font_init(asset_man, font_group.normal, normal)
	if bold == nil do font_group.bold = font_group.normal
	else {
		font_group.bold = new(Font)
		font_init(asset_man, font_group.bold, bold.(Font_Config)) }
	if italic == nil do font_group.italic = font_group.normal
	else {
		font_group.italic = new(Font)
		font_init(asset_man, font_group.italic, italic.(Font_Config)) } }

font_init :: proc(asset_man: ^Asset_Manager, font: ^Font, config: Font_Config) {
	font.font_config = config
	font.bitmap_image = new(Image_Asset)
	init_image(asset_man, font.bitmap_image, { url = auto_cast fmt.aprintf("image:%s.png", font.name) })
	bold_url: URL = cast(URL)fmt.aprintf("image:%s-bold.png", font.name)
	bold_path: string = path_from_url(asset_man, bold_url, context.allocator)
	// fmt.println(bold_path)
	if os.exists(bold_path) {
		font.bitmap_image_bold = new(Image_Asset)
		init_image(asset_man, font.bitmap_image_bold, { url = bold_url })
	} else {
		font.bitmap_image_bold = font.bitmap_image }
	assert(asset_commands(asset_man, Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))
	// assert(asset_commands(asset_man, Image_Asset, &font.bitmap_image_bold.asset, { .Import, .Load, .Upload }))
	if font.default_advance == 0 do font.default_advance = u8(font.bitmap_image.height / 16)
	font.symbol_size = { f32(font.bitmap_image.width / 16), f32(font.bitmap_image.height / 16) }
	font.bearings = font.default_bearing
	font.advances = font.default_advance
	baf_path: string = fmt.aprintf("string:%s.baf", font.name)
	if os.exists(path_from_url(asset_man, cast(URL)baf_path, context.temp_allocator)) {
	init_string_asset(asset_man, &font.positions_string, { auto_cast baf_path, String_Asset })
	assert(asset_commands(asset_man, String_Asset, &font.positions_string.asset, { .Import, .Load }))
	lines: []string = strings.split_lines(font.positions_string.str)
	for line in lines {
		// (TODO): This can be simplified a little. Why is "line" split twice? //
		parts := strings.split(line, " ")
		if parts[0] == "height" {
			value, _ := strconv.parse_int(parts[1])
			font.height = cast(u8)value }
		if parts[0] == "origin" {
			value, _ := strconv.parse_int(parts[1])
			font.origin = cast(u8)value }
		symbol: u8 = line[0]
		numbers: []string = strings.split(line[2:], " ")
		if len(numbers) != 2 do continue
		bearing, ok := strconv.parse_int(numbers[0])
		if ok do font.bearings[cast(rune)symbol] = u8(bearing)
		advance: int; advance, ok = strconv.parse_int(numbers[1])
		if ok do font.advances[cast(rune)symbol] = u8(advance) } }
	if font.height == 0 do font.height = cast(u8)font.symbol_size.y }

Render_Text_Command :: struct {
	using base: Generic_Command,
	using group_params: Render_Text_Group_Params,
	using params: Render_Text_Params }

Render_Text_Group_Params :: struct {
	font: ^Font,
	res: [2]f32,
	symbol_size: [2]f32 }

Render_Text_Params :: struct {
	symbol: u8,
	color: Color,
	scale_factor: f32,
	position: [3]f32,
	italic: bool,
	bold: bool }

Text_Style :: struct {
	color: Color,
	italic: bool,
	bold: bool,
	font_group: Font_Group,
	font_size: Font_Size,
	tracking: f32,
	spacing: f32,
	leading: f32 } // (TODO): This is measured in pixels, so it must be an integer. //

DEFAULT_TEXT_STYLE: Text_Style : {
	color = BLACK,
	italic = false,
	bold = false,
	font_size = 8,
	font_group = {},
	tracking = 1.0,
	spacing = 1.0,
	leading = 0.5 }

font_group_select :: proc(font_group: Font_Group, style: Text_Style) -> (font: ^Font) {
	switch {
	case style.bold: return font_group.bold
	case style.italic: return font_group.italic
	case: return font_group.normal }
	return nil }

render_bitmap_symbol :: proc(graphics_man: ^Graphics_Manager, symbol: u8, position: [2]f32 = { 0, 0 }, depth: f32, style: Text_Style = DEFAULT_TEXT_STYLE, integer: bool = true) {
	using style
	font := font_group_select(font_group, style)
	scale_factor := font_size_to_font_scale(font_size, font)
	command: Render_Text_Command = {
		group_params_size = size_of(Render_Text_Group_Params),
		font = font,
		res = graphics_man.active_resolution,
		scale_factor = scale_factor,
		color = color }
	command.symbol = symbol
	command.position = [3]f32{ f32(position.x), f32(position.y), depth }
	command.position.x -= f32(command.font.bearings[symbol]) * scale_factor
	command.scale_factor = f32(scale_factor)
	command.color = color
	command.position.x = integer ? math.round_f32(command.position.x + 0.3) : command.position.x
	command.position.y = integer ? math.round_f32(command.position.y + 0.3) : command.position.y
	command.italic = italic ? (font_group.italic == font_group.normal) ? true : false : false
	command.bold = bold
	command_buffer_record(&graphics_man.command_buffer, { base = command }) }

submit_render_text :: proc(graphics_man: ^Graphics_Manager, _command: Command, index: int) {
	using Text_Uniforms

	command := _command.base.(Render_Text_Command)

	use_shader(&graphics_man.text_shader)
	set_shader_param(RES, graphics_man.active_resolution)
	set_shader_param(SYMBOL_SIZE, command.font.symbol_size)

	commands := command_buffer_get_group(&graphics_man.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Render_Text_Command, _command_0, _command_1) })
	// for command in commands do fmt.printfln("%c -- %v", command.base.(Render_Text_Command).symbol, command.base.(Render_Text_Command).position)

	buffers := make_buffers(6)
	defer delete_buffers(buffers)

	n: int = 6 * len(commands)
	scale_factor := make([]f32, n)
	color := make([][4]f32, n)
	symbol := make([]u32, n)
	position := make([][3]f32, n)
	italic := make([]u32, n)
	bold := make([]u32, n)
	for _command, i in commands do for j in 0 ..< 6 {
		command := _command.base.(Render_Text_Command)
		k := 6 * i + j
		scale_factor[k] = command.scale_factor
		color[k] = color_to_4f32(command.color)
		symbol[k] = cast(u32)command.symbol
		position[k] = command.position
		italic[k] = cast(u32)command.italic
		bold[k] = cast(u32)command.bold }

	upload_vertex_buffer_data(0, buffers[0], 1, gl.UNSIGNED_INT, symbol)
	upload_vertex_buffer_data(1, buffers[1], 4, gl.FLOAT, color)
	upload_vertex_buffer_data(2, buffers[2], 1, gl.FLOAT, scale_factor)
	upload_vertex_buffer_data(3, buffers[3], 3, gl.FLOAT, position)
	upload_vertex_buffer_data(4, buffers[4], 1, gl.UNSIGNED_INT, italic)
	upload_vertex_buffer_data(5, buffers[5], 1, gl.UNSIGNED_INT, bold)

	bind_texture(0, command.font.bitmap_image.handle)
	bind_texture(1, command.font.bitmap_image_bold.handle)
	texture_filtering(gl.NEAREST)
	polygon_mode(.Fill)
	draw_triangles(cast(i32)n) }

// render_text_group::proc(name:Font_Name) {
// 	when TRACY_ENABLE { tracy.ZoneNC("render text group",0xFF0000) }
// 	use_shader(state.font_shader)
// 	commands:=&state.text_draw_commands[name]
// 	font:=&state.fonts[name]
// 	n:=len(commands); if n==0 do return
// 	set_shader_param(state.font_shader.this_buffer_res,cast_array(state.resolution,f32))
// 	set_shader_param(state.font_shader.symbol_size,[2]f32{f32(font.symbol_size.x),f32(font.symbol_size.y)})
// 	bind_vertex_array(0)
// 	i:int=0
// 	upload_vertex_buffer_data(Attribute_Index(i),VBO_Index(i),gl.FLOAT,&commands.symbols[0],n); i+=1
// 	upload_vertex_buffer_data(Attribute_Index(i),VBO_Index(i),gl.FLOAT,&commands.positions[0],n); i+=1
// 	upload_vertex_buffer_data(Attribute_Index(i),VBO_Index(i),gl.FLOAT,&commands.scale_factors[0],n); i+=1
// 	upload_vertex_buffer_data(Attribute_Index(i),VBO_Index(i),gl.FLOAT,&commands.colors[0],n)
// 	bind_texture(gl.TEXTURE0,state.textures[font.name].handle)
// 	texture_filtering(gl.LINEAR)
// 	draw_triangles(i32(6*n)) }
