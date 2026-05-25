#+feature using-stmt
package willow

Neon_Color_Column :: enum {
	Normal = 0,
	Hover,
	Pressed,
	Selected,
	Variant_1 = 0,
	Variant_2,
	Variant_3,
	Variant_4 }

Neon_Color_Row :: enum {
	Neutral_Foreground_1 = 0,
	Neutral_Foreground_2,
	Neutral_Foreground_2_Brand,
	Neutral_Foreground_3,
	Neutral_Foreground_3_Brand,
	Neutral_Foreground_4,
	Neutral_Foreground_5,
	Neutral_Foreground_Disabled,
	Brand_Foreground_Link,
	Neutral_Foreground_2_Link,
	Brand_Foreground_1,
	Brand_Foreground_Inverted,
	Neutral_Background_1,
	Neutral_Background_2,
	Neutral_Background_3,
	Neutral_Background_4,
	Neutral_Background_5,
	Neutral_Background_Inverted,
	Subtle_Background,
	Brand_Background,
	Brand_Background_2,
	Brand_Background_Inverted,
	Neutral_Card_Background,
	Neutral_Stroke_Accessible,
	Neutral_Stroke_1,
	Neutral_Stroke_2,
	Neutral_Stroke_3,
	Neutral_Stroke_4,
	Brand_Stroke_1,
	Brand_Stroke_2,
	Compound_Brand_Stroke,
	Red_Background,
	Red_Foreground,
	Red_Border,
	Green_Background,
	Green_Foreground,
	Green_Border,
	Dark_Orange_Background,
	Dark_Orange_Foreground,
	Dark_Orange_Border,
	Yellow_Background,
	Yellow_Foreground,
	Yellow_Border,
	Berry_Background,
	Berry_Foreground,
	Berry_Border,
	Light_Green_Background,
	Light_Green_Foreground,
	Light_Green_Border,
	Marigold_Background,
	Marigold_Foreground,
	Marigold_Border,
	Success_Background,
	Success_Foreground,
	Success_Border,
	Warning_Background,
	Warning_Foreground,
	Warning_Border,
	Danger_Background,
	Danger_Foreground,
	Danger_Border }

Neon_Color :: [4]Color

Neon_Color_Table :: [len(Neon_Color_Row)]Neon_Color

neon_color_table_ms_light: ^Neon_Color_Table

// (TODO): The installer CLI procedure also runs a generator procedure, which creates a "generated.odin" file.
// (TODO): Arrange these in a 4xN table, where the empty trailing rows are filled with the value of the last filled row.
// Then GUI functions take a slice, so you can just give it a slice off this table.

NEON_FONT_SIZE_CAPTION_2 :: 10
NEON_FONT_SIZE_CAPTION_1 :: 12
NEON_FONT_SIZE_BODY_1 :: 14
NEON_FONT_SIZE_BODY_2 :: 16
NEON_FONT_SIZE_SUBTITLE_2 :: 16
NEON_FONT_SIZE_SUBTITLE_1 :: 20
NEON_FONT_SIZE_TITLE_3 :: 24
NEON_FONT_SIZE_TITLE_2 :: 28
NEON_FONT_SIZE_TITLE_1 :: 32
NEON_FONT_SIZE_LARGE_TITLE :: 40
NEON_FONT_SIZE_DISPLAY :: 68

neon_init :: proc() {
	using Neon_Color_Row
	using Neon_Color_Column

	neon_color_table_ms_light = new(Neon_Color_Table)
	neon_color_table_ms_light^ = {
		Neutral_Foreground_1 = {
			Normal   = 0x242424ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Neutral_Foreground_2 = {
			Normal   = 0x424242ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Neutral_Foreground_2_Brand = {
			Normal   = 0x424242ff,
			Hover    = 0x0f6cbdff,
			Pressed  = 0x115ea3ff,
			Selected = 0x0f6cbdff },
		Neutral_Foreground_3 = {
			Normal   = 0x616161ff,
			Hover    = 0x424242ff,
			Pressed  = 0x424242ff,
			Selected = 0x424242ff },
		Neutral_Foreground_3_Brand = {
			Normal   = 0x616161ff,
			Hover    = 0x0f6cbdff,
			Pressed  = 0x115ea3ff,
			Selected = 0x0f6cbdff },
		Neutral_Foreground_4 = {
			Normal   = 0x707070ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Neutral_Foreground_5 = {
			Normal   = 0x616161ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Neutral_Foreground_Disabled = {
			0xbdbdbdff,
			0xbdbdbdff,
			0xbdbdbdff,
			0xbdbdbdff },
		Brand_Foreground_Link = {
			Normal   = 0x115ea3ff,
			Hover    = 0x0f548cff,
			Pressed  = 0x0c3b5eff,
			Selected = 0x115ea3ff },
		Neutral_Foreground_2_Link = {
			Normal   = 0x424242ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Brand_Foreground_1 = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x115ea3ff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x0f548cff },
		Brand_Foreground_Inverted = {
			Normal   = 0x479ef5ff,
			Hover    = 0x62abf5ff,
			Pressed  = 0x479ef5ff,
			Selected = 0x0f6cbdff },
		Neutral_Background_1 = {
			Normal   = 0xffffffff,
			Hover    = 0xf5f5f5ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xebebebff },
		Neutral_Background_2 = {
			Normal   = 0xfafafaff,
			Hover    = 0xf0f0f0ff,
			Pressed  = 0xdbdbdbff,
			Selected = 0xe6e6e6ff },
		Neutral_Background_3 = {
			Normal   = 0xf5f5f5ff,
			Hover    = 0xebebebff,
			Pressed  = 0xd6d6d6ff,
			Selected = 0xe0e0e0ff },
		Neutral_Background_4 = {
			Normal   = 0xf0f0f0ff,
			Hover    = 0xfafafaff,
			Pressed  = 0xf5f5f5ff,
			Selected = 0xffffffff },
		Neutral_Background_5 = {
			Normal   = 0xebebebff,
			Hover    = 0xf5f5f5ff,
			Pressed  = 0xf0f0f0ff,
			Selected = 0xfafafaff },
		Neutral_Background_Inverted = {
			Normal   = 0x292929ff,
			Hover    = 0x3d3d3dff,
			Pressed  = 0x1f1f1fff,
			Selected = 0x383838ff },
		Subtle_Background = {
			Normal   = 0xffffffff,
			Hover    = 0xf5f5f5ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xebebebff },
		Brand_Background = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x115ea3ff,
			Pressed  = 0x0c3b5eff,
			Selected = 0x0f548cff },
		Brand_Background_2 = {
			Normal   = 0xebf3fcff,
			Hover    = 0xcfe4faff,
			Pressed  = 0x96c6faff,
			Selected = 0xcfe4faff },
		Brand_Background_Inverted = {
			Normal   = 0xffffffff,
			Hover    = 0xebf3fcff,
			Pressed  = 0xb4d6faff,
			Selected = 0xcfe4faff },
		Neutral_Card_Background = {
			Normal   = 0xfafafaff,
			Hover    = 0xffffffff,
			Pressed  = 0xf5f5f5ff,
			Selected = 0xebebebff },
		Neutral_Stroke_Accessible = {
			Normal   = 0x616161ff,
			Hover    = 0x575757ff,
			Pressed  = 0x4d4d4dff,
			Selected = 0x0f6cbdff },
		Neutral_Stroke_1 = {
			Normal   = 0xd1d1d1ff,
			Hover    = 0xc7c7c7ff,
			Pressed  = 0xb3b3b3ff,
			Selected = 0xbdbdbdff },
		Neutral_Stroke_2 = {
			Normal   = 0xe0e0e0ff,
			Hover    = 0xe0e0e0ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xe0e0e0ff },
		Neutral_Stroke_3 = {
			Normal   = 0xf0f0f0ff,
			Hover    = 0xf0f0f0ff,
			Pressed  = 0xf0f0f0ff,
			Selected = 0xf0f0f0ff },
		Neutral_Stroke_4 = {
			Normal   = 0xebebebff,
			Hover    = 0xe0e0e0ff,
			Pressed  = 0xd6d6d6ff,
			Selected = 0xebebebff },
		Brand_Stroke_1 = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x0f6cbdff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x0f6cbdff },
		Brand_Stroke_2 = {
			Normal   = 0xb4d6faff,
			Hover    = 0x77b7f7ff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x77b7f7ff },
		Compound_Brand_Stroke = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x115ea3ff,
			Pressed  = 0x0f548cff,
			Selected = 0x115ea3ff },
		Red_Background = {
			Variant_1 = 0xfdf6f6ff,
			Variant_2 = 0xf1bbbcff,
			Variant_3 = 0xd13438ff,
			Variant_4 = 0xd13438ff },
		Red_Foreground = {
			Variant_1 = 0xbc2f32ff,
			Variant_2 = 0x751d1fff,
			Variant_3 = 0xd13438ff,
			Variant_4 = 0xd13438ff },
		Red_Border = {
			Variant_1 = 0xf1bbbcff,
			Variant_2 = 0xd13438ff,
			Variant_3 = 0xd13438ff,
			Variant_4 = 0xd13438ff },
		Green_Background = {
			Variant_1 = 0xf1faf1ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Green_Foreground = {
			Variant_1 = 0x0e700eff,
			Variant_2 = 0x094509ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Green_Border = {
			Variant_1 = 0x9fd89fff,
			Variant_2 = 0x107c10ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Dark_Orange_Background = {
			Variant_1 = 0xfdf6f3ff,
			Variant_2 = 0xf4bfabff,
			Variant_3 = 0xda3b01ff,
			Variant_4 = 0xda3b01ff },
		Dark_Orange_Foreground = {
			Variant_1 = 0xc43501ff,
			Variant_2 = 0x7a2101ff,
			Variant_3 = 0xda3b01ff,
			Variant_4 = 0xda3b01ff },
		Dark_Orange_Border = {
			Variant_1 = 0xf4bfabff,
			Variant_2 = 0xda3b01ff,
			Variant_3 = 0xda3b01ff,
			Variant_4 = 0xda3b01ff },
		Yellow_Background = {
			Variant_1 = 0xfffef5ff,
			Variant_2 = 0xfef7b2ff,
			Variant_3 = 0xfde300ff,
			Variant_4 = 0xfde300ff },
		Yellow_Foreground = {
			Variant_1 = 0x817400ff,
			Variant_2 = 0x817400ff,
			Variant_3 = 0xfde300ff,
			Variant_4 = 0xfde300ff },
		Yellow_Border = {
			Variant_1 = 0xfef7b2ff,
			Variant_2 = 0xfde300ff,
			Variant_3 = 0xfde300ff,
			Variant_4 = 0xfde300ff },
		Berry_Background = {
			Variant_1 = 0xfdf5fcff,
			Variant_2 = 0xedbbe7ff,
			Variant_3 = 0xc239b3ff,
			Variant_4 = 0xc239b3ff },
		Berry_Foreground = {
			Variant_1 = 0xaf33a1ff,
			Variant_2 = 0x6d2064ff,
			Variant_3 = 0xc239b3ff,
			Variant_4 = 0xc239b3ff },
		Berry_Border = {
			Variant_1 = 0xedbbe7ff,
			Variant_2 = 0xc239b3ff,
			Variant_3 = 0xc239b3ff,
			Variant_4 = 0xc239b3ff },
		Light_Green_Background = {
			Variant_1 = 0xf2fbf2ff,
			Variant_2 = 0xa7e3a5ff,
			Variant_3 = 0x13a10eff,
			Variant_4 = 0x13a10eff },
		Light_Green_Foreground = {
			Variant_1 = 0x11910dff,
			Variant_2 = 0x0b5a08ff,
			Variant_3 = 0x13a10eff,
			Variant_4 = 0x13a10eff },
		Light_Green_Border = {
			Variant_1 = 0xa7e3a5ff,
			Variant_2 = 0x13a10eff,
			Variant_3 = 0x13a10eff,
			Variant_4 = 0x13a10eff },
		Marigold_Background = {
			Variant_1 = 0xfefbf4ff,
			Variant_2 = 0xf9e2aeff,
			Variant_3 = 0xeaa300ff,
			Variant_4 = 0xeaa300ff },
		Marigold_Foreground = {
			Variant_1 = 0xd39300ff,
			Variant_2 = 0x835b00ff,
			Variant_3 = 0xeaa300ff,
			Variant_4 = 0xeaa300ff },
		Marigold_Border = {
			Variant_1 = 0xf9e2aeff,
			Variant_2 = 0xeaa300ff,
			Variant_3 = 0xeaa300ff,
			Variant_4 = 0xeaa300ff },
		Success_Background = {
			Variant_1 = 0xf1faf1ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Success_Foreground = {
			Variant_1 = 0x0e700eff,
			Variant_2 = 0x094509ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Success_Border = {
			Variant_1 = 0x9fd89fff,
			Variant_2 = 0x107c10ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Warning_Background = {
			Variant_1 = 0xfff9f5ff,
			Variant_2 = 0xfdcfb4ff,
			Variant_3 = 0xf7630cff,
			Variant_4 = 0xf7630cff },
		Warning_Foreground = {
			Variant_1 = 0xbc4b09ff,
			Variant_2 = 0x8a3707ff,
			Variant_3 = 0xbc4b09ff,
			Variant_4 = 0xbc4b09ff },
		Warning_Border = {
			Variant_1 = 0xfdcfb4ff,
			Variant_2 = 0xbc4b09ff,
			Variant_3 = 0xbc4b09ff,
			Variant_4 = 0xbc4b09ff },
		Danger_Background = {
			Variant_1 = 0xfdf3f4ff,
			Variant_2 = 0xeeacb2ff,
			Variant_3 = 0xc50f1fff,
			Variant_4 = 0xc50f1fff },
		Danger_Foreground = {
			Variant_1 = 0xb10e1cff,
			Variant_2 = 0x6e0811ff,
			Variant_3 = 0xc50f1fff,
			Variant_4 = 0xc50f1fff },
		Danger_Border = {
			Variant_1 = 0xeeacb2ff,
			Variant_2 = 0xc50f1fff,
			Variant_3 = 0xc50f1fff,
			Variant_4 = 0xc50f1fff } } }

Neon_Radius :: enum {
	None    = 0,
	Small   = 2,
	Medium  = 4,
	Large   = 6,
	XLarge  = 8,
	XLarge2 = 12,
	XLarge3 = 16,
	XLarge4 = 24,
	XLarge5 = 32,
	XLarge6 = 40 }

Neon_Stroke_Width :: enum {
	Thin     = 1,
	Thick    = 2,
	Thicker  = 3,
	Thickest = 4 }
