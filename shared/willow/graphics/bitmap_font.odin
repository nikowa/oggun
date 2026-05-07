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

// render_text::proc(args:..any,sep:string="",pos:[2]f32={0,0},color:[4]f32=BLACK,scale_multiplier:f32=1.0,pivot:bit_set[Compass]={},font_name:Font_Name=.MAIN_FONT_4,shadow:bool=true,spacing:f32=1.0,waviness:f32=0.0,cursor_pos:int=-1) {
// 	using state
// 	when TRACY_ENABLE { tracy.ZoneNC("draw text",0xFF0000) }
// 	font:=&fonts[font_name]
// 	commands:=&state.text_draw_commands[font_name]
// 	if cap(commands)==0 do commands^=make_soa_dynamic_array_len_cap(#soa[dynamic]Text_Draw_Command,length=0,capacity=TEXT_COMMANDS_CAP)
// 	text:=fmt.aprint(..args,sep=sep)
// 	pos:=pos
// 	width:f32=0.0
// 	for c,i in text {
// 		width+=f32(font.advances[c]-font.bearings[c])*scale_multiplier+spacing }
// 	height:f32=f32(font.symbol_size.y)
// 	// render_rect_hollow(position=pos,size={width,height},color=RED)
// 	// render_rect(position={0,rect_size/2.5},size={8,8},fill_color=RED)
// 	pos=pos-0.5*{width,height}
// 	if .EAST in pivot { pos.x-=0.5*width }
// 	if .WEST in pivot { pos.x+=0.5*width }
// 	if .NORTH in pivot { pos.y-=0.5*height }
// 	if .SOUTH in pivot { pos.y+=0.5*height }
// 	use_shader(state.font_shader)
// 	set_shader_param(state.font_shader.this_buffer_res,cast_array(state.resolution,f32))
// 	set_shader_param(state.font_shader.symbol_size,[2]f32{f32(font.symbol_size.x),f32(font.symbol_size.y)})
// 	sym_pos:[2]f32=pos
// 	for c,i in text {
// 		command:Text_Draw_Command
// 		command.symbols=f32(c)
// 		wavy_offset:f32=waviness*f32(math.sin(3.12*state.net_time+f32(i))+math.cos(7.31*state.net_time+f32(i)))
// 		command.positions=[3]f32{f32(sym_pos.x),f32(sym_pos.y+wavy_offset),0}
// 		if i==cursor_pos do if (cast(int)(state.net_time*2))%2==0 {
// 			render_rect(position=command.positions.xy+{0,0.5*height},size={4,height},fill_color=WHITE) }
// 		command.positions[0]-=f32(font.bearings[c])*scale_multiplier
// 		command.scale_factors=f32(scale_multiplier)
// 		command.colors=cast_array(color,f32)
// 		sym_pos.x+=f32(font.advances[c]-font.bearings[c])*scale_multiplier+spacing
// 		for _ in 0..<QUAD_VERTS do append_soa_elem(commands,command) }}
