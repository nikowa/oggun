package graphics
import "../asset_manager"
import "core:fmt"
import "core:strings"
import "core:strconv"

// Derived from staffmaster/font.odin

Bitmap_Font_Config :: struct #all_or_none {
	name: string,
	default_bearing: u8,
	default_advance: u8 }

DEFAULT_BITMAP_FONT_CONFIG: Bitmap_Font_Config : {
	name = "font",
	default_bearing = 0,
	default_advance = 0 }

Bitmap_Font :: struct {
	using bitmap_font_config: Bitmap_Font_Config,
	bitmap_image: Image_Asset,
	positions_string: asset_manager.String_Asset,
	symbol_size: [2]f32,
	bearings: [256]u8,
	advances: [256]u8 }

bitmap_font_init :: proc(asset_man: ^asset_manager.Asset_Manager, font: ^Bitmap_Font, config: Bitmap_Font_Config) {
	font.bitmap_font_config = config
	init_image(asset_man, &font.bitmap_image, { url = auto_cast fmt.aprintf("image:%s.png", font.name) })
	assert(asset_manager.asset_commands(asset_man, Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))
	if font.default_advance == 0 do font.default_advance = u8(font.bitmap_image.height / 16)
	font.symbol_size = { f32(font.bitmap_image.width / 16), f32(font.bitmap_image.height / 16) }
	font.bearings = config.default_bearing
	font.advances = config.default_advance
	asset_manager.init_string_asset(asset_man, &font.positions_string, { auto_cast fmt.aprintf("string:%s.baf", font.name), asset_manager.String_Asset })
	assert(asset_manager.asset_commands(asset_man, asset_manager.String_Asset, &font.positions_string.asset, { .Import, .Load }))
	lines: []string = strings.split_lines(font.positions_string.str)
	for line in lines {
		tokens: []string = strings.split(line, " ")
		if len(tokens) != 3 do continue
		bearing, ok := strconv.parse_int(tokens[1])
		if ok do font.bearings[rune(tokens[0][0])] = u8(bearing)
		advance: int; advance, ok = strconv.parse_int(tokens[2])
		if ok do font.advances[rune(tokens[0][0])] = u8(advance) } }

Render_Bitmap_Text_Command :: struct {
	using render_bitmap_text_params: Render_Bitmap_Text_Params,
	using render_bitmap_text_group_params: Render_Bitmap_Text_Group_Params }

Render_Bitmap_Text_Group_Params :: struct {
	font: ^Bitmap_Font,
	res: [2]f32,
	symbol_size: [2]f32 }

Render_Bitmap_Text_Params :: struct {
	scale_factor: f32,
	color: [4]f32,
	symbol: i32,
	position: [3]f32 }

render_bitmap_text :: proc(graphics_man: ^Graphics_Manager, args: ..any, sep: string = "", pos: [2]f32 = { 0, 0 }, color: [4]f32 = BLACK, scale_factor: f32 = 1.0, pivot: bit_set[Compass] = {}, font: ^Bitmap_Font = nil, shadow: bool = true, spacing: f32 = 1.0, waviness: f32 = 0.0, cursor_pos: int = -1) {
	text := fmt.aprint(..args, sep = sep)
	pos := pos
	width: f32 = 0.0
	for c, i in text {
		width += f32(font.advances[c] - font.bearings[c]) * scale_factor + spacing }
	height: f32 = f32(font.symbol_size.y)
	pos = pos - 0.5 * { width, height }
	if .East in pivot  do pos.x -= 0.5 * width
	if .West in pivot  do pos.x += 0.5 * width
	if .North in pivot do pos.y -= 0.5 * height
	if .South in pivot do pos.y += 0.5 * height
	group_command: Render_Bitmap_Text_Command = {
		font = font,
		res = graphics_man.active_resolution,
		scale_factor = scale_factor,
		color = color }
	sym_pos:[2]f32=pos
	for c,i in text {
		command := group_command
		command.symbol = cast(i32)c
		wavy_offset: f32 = 0.0
		// wavy_offset: f32 = waviness * f32(math.sin(3.12 * state.net_time + f32(i)) + math.cos(7.31 * state.net_time + f32(i)))
		command.position = [3]f32{ f32(sym_pos.x), f32(sym_pos.y + wavy_offset), 0 }
		command.position.x -= f32(font.bearings[c]) * scale_factor
		command.scale_factor = f32(scale_factor)
		command.color = color
		sym_pos.x += f32(font.advances[c] - font.bearings[c]) * scale_factor + spacing
		command_buffer_record(&graphics_man.command_buffer, { variant = .RENDER_BITMAP_TEXT, render_bitmap_text = command }) } }

submit_render_bitmap_text :: proc(graphics_man: ^Graphics_Manager, command: ^Command) {
}
