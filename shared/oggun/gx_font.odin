#+feature using-stmt
package oggun
import gl "vendor:OpenGL"
import "core:os"
import "core:fmt"
import "core:math"
import "core:strings"
import "core:strconv"

// https://escape.utils.com //

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

// (TODO): Why is this "distinct"? //
Font_Size :: distinct u8

font_size_to_font_scale :: proc(font_size: Font_Size, font: ^Font) -> (font_scale: f32) {
	return cast(f32)font_size / cast(f32)font.height }

// (TODO): Make a "Font_Size" u8 type and make it absolute rather than relative to the size of the

font_group_init :: proc(font_group: ^Font_Group, normal: Font_Config, bold: Maybe(Font_Config) = nil, italic: Maybe(Font_Config) = nil) {
	font_group.normal = new(Font)
	font_init(font_group.normal, normal)
	if bold == nil do font_group.bold = font_group.normal
	else {
		font_group.bold = new(Font)
		font_init(font_group.bold, bold.(Font_Config)) }
	if italic == nil do font_group.italic = font_group.normal
	else {
		font_group.italic = new(Font)
		font_init(font_group.italic, italic.(Font_Config)) } }

symbol_size_from_text_style :: proc(text_style: Text_Style, symbol: u8) -> [2]f32 {
	using text_style
	width: f32 = cast(f32)font_group.normal.advances[symbol] - cast(f32)font_group.normal.bearings[symbol]
	height: f32 = auto_cast font_size
	return { width, height } }

font_init :: proc(font: ^Font, config: Font_Config) {
	font.font_config = config
	font.bitmap_image = new(Image_Asset)
	init_image(font.bitmap_image, { url = auto_cast fmt.aprintf("image:%s.png", font.name) })
	bold_url: URL = cast(URL)fmt.aprintf("image:%s-bold.png", font.name)
	bold_path: string = am_path_from_url(bold_url, context.allocator)
	// fmt.println(bold_path)
	if os.exists(bold_path) {
		font.bitmap_image_bold = new(Image_Asset)
		init_image(font.bitmap_image_bold, { url = bold_url })
	} else {
		font.bitmap_image_bold = font.bitmap_image }
	assert(am_commands(Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))
	// assert(am_commands(Image_Asset, &font.bitmap_image_bold.asset, { .Import, .Load, .Upload }))
	if font.default_advance == 0 do font.default_advance = u8(font.bitmap_image.height / 16)
	font.symbol_size = { f32(font.bitmap_image.width / 16), f32(font.bitmap_image.height / 16) }
	font.bearings = font.default_bearing
	font.advances = font.default_advance
	baf_path: string = fmt.aprintf("string:%s.baf", font.name)
	if os.exists(am_path_from_url(cast(URL)baf_path, context.temp_allocator)) {
	am_init_string_asset(&font.positions_string, { auto_cast baf_path, String_Asset })
	assert(am_commands(String_Asset, &font.positions_string.asset, { .Import, .Load }))
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
