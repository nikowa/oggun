#+feature using-stmt
package willow
import "core:fmt"

Neon_Manager :: struct {
	font_group: Font_Group,
	text_style: Text_Style,
	// caption2_font_group: Font_Group,  // 10px
	// caption1_font_group: Font_Group,  // 12px
	// body1_font_group: Font_Group,     // 14px
	// body2_font_group: Font_Group,     // 16px
	// subtitle1_font_group: Font_Group, // 20px
	theme: ^Neon_Theme }

NEUTRAL_BACKGROUND_1_NORMAL_LIGHT :: 0xffffffff
NEUTRAL_FOREGROUND_DISABLED_LIGHT :: 0xbdbdbdff
NEUTRAL_BACKGROUND_4_NORMAL_LIGHT :: 0xf0f0f0ff
NEUTRAL_STROKE_1_NORMAL_LIGHT :: 0xd1d1d1ff

NEUTRAL_BACKGROUND_1_NORMAL_DARK :: 0x292929ff

neon_manager_init :: proc() {
	using Neon_Color_Row
	using Neon_Color_Column

	neon_theme_ms_light = new(Neon_Theme)
	neon_theme_ms_dark = new(Neon_Theme)
	neon_theme_ms_light^ = {
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
			Hover    = 0x707070ff,
			Pressed  = 0x707070ff,
			Selected = 0x707070ff },
		Neutral_Foreground_5 = {
			Normal   = 0x616161ff,
			Hover    = 0x242424ff,
			Pressed  = 0x242424ff,
			Selected = 0x242424ff },
		Neutral_Foreground_Disabled = {
			NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			NEUTRAL_FOREGROUND_DISABLED_LIGHT },
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
			Hover    = 0x0f6cbdff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x0f6cbdff },
		Brand_Foreground_2 = {
			Normal   = 0x115ea3ff,
			Hover    = 0x0f548cff,
			Pressed  = 0x0a2e4aff,
			Selected = 0x0a2e4aff },
		Brand_Foreground_Inverted = {
			Normal   = 0x479ef5ff,
			Hover    = 0x62abf5ff,
			Pressed  = 0x479ef5ff,
			Selected = 0x479ef5ff },
		Neutral_Background_1 = {
			Normal   = NEUTRAL_BACKGROUND_1_NORMAL_LIGHT,
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
			Normal   = NEUTRAL_BACKGROUND_4_NORMAL_LIGHT,
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
			Normal   = 0x00000000,
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
			Selected = 0x96c6faff },
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
			Normal   = NEUTRAL_STROKE_1_NORMAL_LIGHT,
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
		Neutral_Stroke_Subtle = {
			Normal   = 0xe0e0e0ff,
			Hover    = 0xe0e0e0ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xe0e0e0ff },
		Brand_Stroke_1 = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x0f6cbdff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x0f6cbdff },
		Brand_Stroke_2 = {
			Normal   = 0xb4d6faff,
			Hover    = 0x77b7f7ff,
			Pressed  = 0x0f6cbdff,
			Selected = 0x0f6cbdff },
		Compound_Brand_Stroke = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x115ea3ff,
			Pressed  = 0x0f548cff,
			Selected = 0x115ea3ff },
		Neutral_Stroke_Disabled = {
			Normal   = 0xe0e0e0ff,
			Hover    = 0xe0e0e0ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xe0e0e0ff },
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
			Variant_4 = 0xc50f1fff } }

	neon_theme_ms_dark^ = {
		Neutral_Foreground_1 = {
			Normal   = 0xffffffff,
			Hover    = 0xffffffff,
			Pressed  = 0xffffffff,
			Selected = 0xffffffff },
		Neutral_Foreground_2 = {
			Normal   = 0xd6d6d6ff,
			Hover    = 0xffffffff,
			Pressed  = 0xffffffff,
			Selected = 0xffffffff },
		Neutral_Foreground_2_Brand = {
			Normal   = 0xd6d6d6ff,
			Hover    = 0x479ef5ff,
			Pressed  = 0x2886deff,
			Selected = 0x479ef5ff },
		Neutral_Foreground_3 = {
			Normal   = 0xadadadff,
			Hover    = 0xd6d6d6ff,
			Pressed  = 0xd6d6d6ff,
			Selected = 0xd6d6d6ff },
		Neutral_Foreground_3_Brand = {
			Normal   = 0xadadadff,
			Hover    = 0x479ef5ff,
			Pressed  = 0x2886deff,
			Selected = 0x479ef5ff },
		Neutral_Foreground_4 = {
			Normal   = 0x999999ff,
			Hover    = 0x999999ff,
			Pressed  = 0x999999ff,
			Selected = 0x999999ff },
		Neutral_Foreground_5 = {
			Normal   = 0xadadadff,
			Hover    = 0xffffffff,
			Pressed  = 0xffffffff,
			Selected = 0xffffffff },
		Neutral_Foreground_Disabled = {
			0x5c5c5cff,
			0x5c5c5cff,
			0x5c5c5cff,
			0x5c5c5cff },
		Brand_Foreground_Link = {
			Normal   = 0x479ef5ff,
			Hover    = 0x62abf5ff,
			Pressed  = 0x2886deff,
			Selected = 0x479ef5ff },
		Neutral_Foreground_2_Link = {
			Normal   = 0xd6d6d6ff,
			Hover    = 0xffffffff,
			Pressed  = 0xffffffff,
			Selected = 0xffffffff },
		Brand_Foreground_1 = {
			Normal   = 0x479ef5ff,
			Hover    = 0x479ef5ff,
			Pressed  = 0x479ef5ff,
			Selected = 0x479ef5ff },
		Brand_Foreground_2 = {
			Normal   = 0x62abf5ff,
			Hover    = 0x96c6faff,
			Pressed  = 0xebf3fcff,
			Selected = 0xebf3fcff },
		Brand_Foreground_Inverted = {
			Normal   = 0x0f6cbdff,
			Hover    = 0x115ea3ff,
			Pressed  = 0x0f548cff,
			Selected = 0x0f548cff },
		Neutral_Background_1 = {
			Normal   = NEUTRAL_BACKGROUND_1_NORMAL_DARK,
			Hover    = 0x3d3d3dff,
			Pressed  = 0x1f1f1fff,
			Selected = 0x383838ff },
		Neutral_Background_2 = {
			Normal   = 0x1f1f1fff,
			Hover    = 0x333333ff,
			Pressed  = 0x141414ff,
			Selected = 0x2e2e2eff },
		Neutral_Background_3 = {
			Normal   = 0x141414ff,
			Hover    = 0x292929ff,
			Pressed  = 0x0a0a0aff,
			Selected = 0x242424ff },
		Neutral_Background_4 = {
			Normal   = 0x0a0a0aff,
			Hover    = 0x1f1f1fff,
			Pressed  = 0x000000ff,
			Selected = 0x1a1a1aff },
		Neutral_Background_5 = {
			Normal   = 0x000000ff,
			Hover    = 0x141414ff,
			Pressed  = 0x050505ff,
			Selected = 0x0f0f0fff },
		Neutral_Background_Inverted = {
			Normal   = 0xffffffff,
			Hover    = 0xf5f5f5ff,
			Pressed  = 0xe0e0e0ff,
			Selected = 0xebebebff },
		Subtle_Background = {
			Normal   = 0x00000000,
			Hover    = 0x383838ff,
			Pressed  = 0x2e2e2eff,
			Selected = 0x333333ff },
		Brand_Background = {
			Normal   = 0x115ea3ff,
			Hover    = 0x0f6cbdff,
			Pressed  = 0x0c3b5eff,
			Selected = 0x0f548cff },
		Brand_Background_2 = {
			Normal   = 0x082338ff,
			Hover    = 0x0c3b5eff,
			Pressed  = 0x061724ff,
			Selected = 0x061724ff },
		Brand_Background_Inverted = {
			Normal   = 0xffffffff,
			Hover    = 0xebf3fcff,
			Pressed  = 0xb4d6faff,
			Selected = 0xcfe4faff },
		Neutral_Card_Background = {
			Normal   = 0x333333ff,
			Hover    = 0x3d3d3dff,
			Pressed  = 0x2e2e2eff,
			Selected = 0x383838ff },
		Neutral_Stroke_Accessible = {
			Normal   = 0xadadadff,
			Hover    = 0xbdbdbdff,
			Pressed  = 0xb3b3b3ff,
			Selected = 0x479ef5ff },
		Neutral_Stroke_1 = {
			Normal   = 0x666666ff,
			Hover    = 0x757575ff,
			Pressed  = 0x6b6b6bff,
			Selected = 0x707070ff },
		Neutral_Stroke_2 = {
			Normal   = 0x525252ff,
			Hover    = 0x525252ff,
			Pressed  = 0x525252ff,
			Selected = 0x525252ff },
		Neutral_Stroke_3 = {
			Normal   = 0x3d3d3dff,
			Hover    = 0x3d3d3dff,
			Pressed  = 0x3d3d3dff,
			Selected = 0x3d3d3dff },
		Neutral_Stroke_4 = {
			Normal   = 0x3d3d3dff,
			Hover    = 0x2e2e2eff,
			Pressed  = 0x242424ff,
			Selected = 0x3d3d3dff },
		Neutral_Stroke_Subtle = {
			Normal   = 0x0a0a0aff,
			Hover    = 0x0a0a0aff,
			Pressed  = 0x0a0a0aff,
			Selected = 0x0a0a0aff },
		Brand_Stroke_1 = {
			Normal   = 0x479ef5ff,
			Hover    = 0x479ef5ff,
			Pressed  = 0x479ef5ff,
			Selected = 0x479ef5ff },
		Brand_Stroke_2 = {
			Normal   = 0x0e4775ff,
			Hover    = 0x0e4775ff,
			Pressed  = 0x0a2e4aff,
			Selected = 0x0a2e4aff },
		Compound_Brand_Stroke = {
			Normal   = 0x479ef5ff,
			Hover    = 0x62abf5ff,
			Pressed  = 0x2886deff,
			Selected = 0x2886deff },
		Neutral_Stroke_Disabled = {
			Normal   = 0x424242ff,
			Hover    = 0x424242ff,
			Pressed  = 0x424242ff,
			Selected = 0x424242ff },
		Red_Background = {
			Variant_1 = 0x3f1011ff,
			Variant_2 = 0x751d1fff,
			Variant_3 = 0xd13438ff,
			Variant_4 = 0xd13438ff },
		Red_Foreground = {
			Variant_1 = 0xe37d80ff,
			Variant_2 = 0xf1bbbcff,
			Variant_3 = 0xe37d80ff,
			Variant_4 = 0xe37d80ff },
		Red_Border = {
			Variant_1 = 0xd13438ff,
			Variant_2 = 0xe37d80ff,
			Variant_3 = 0xe37d80ff,
			Variant_4 = 0xe37d80ff },
		Green_Background = {
			Variant_1 = 0x052505ff,
			Variant_2 = 0x094509ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Green_Foreground = {
			Variant_1 = 0x54b054ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x9fd89fff,
			Variant_4 = 0x9fd89fff },
		Green_Border = {
			Variant_1 = 0x107c10ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x9fd89fff,
			Variant_4 = 0x9fd89fff },
		Dark_Orange_Background = {
			Variant_1 = 0x411200ff,
			Variant_2 = 0x7a2101ff,
			Variant_3 = 0xda3b01ff,
			Variant_4 = 0xda3b01ff },
		Dark_Orange_Foreground = {
			Variant_1 = 0xe9835eff,
			Variant_2 = 0xf4bfabff,
			Variant_3 = 0xe9835eff,
			Variant_4 = 0xe9835eff },
		Dark_Orange_Border = {
			Variant_1 = 0xda3b01ff,
			Variant_2 = 0xe9835eff,
			Variant_3 = 0xe9835eff,
			Variant_4 = 0xe9835eff },
		Yellow_Background = {
			Variant_1 = 0x4c4400ff,
			Variant_2 = 0x817400ff,
			Variant_3 = 0xfde300ff,
			Variant_4 = 0xfde300ff },
		Yellow_Foreground = {
			Variant_1 = 0xfeee66ff,
			Variant_2 = 0xfef7b2ff,
			Variant_3 = 0xfdea3dff,
			Variant_4 = 0xfdea3dff },
		Yellow_Border = {
			Variant_1 = 0xfde300ff,
			Variant_2 = 0xfdea3dff,
			Variant_3 = 0xfdea3dff,
			Variant_4 = 0xfdea3dff },
		Berry_Background = {
			Variant_1 = 0x3a1136ff,
			Variant_2 = 0x6d2064ff,
			Variant_3 = 0xc239b3ff,
			Variant_4 = 0xc239b3ff },
		Berry_Foreground = {
			Variant_1 = 0xda7ed0ff,
			Variant_2 = 0xedbbe7ff,
			Variant_3 = 0xd161c4ff,
			Variant_4 = 0xd161c4ff },
		Berry_Border = {
			Variant_1 = 0xc239b3ff,
			Variant_2 = 0xd161c4ff,
			Variant_3 = 0xd161c4ff,
			Variant_4 = 0xd161c4ff },
		Light_Green_Background = {
			Variant_1 = 0x063004ff,
			Variant_2 = 0x0b5a08ff,
			Variant_3 = 0x13a10eff,
			Variant_4 = 0x13a10eff },
		Light_Green_Foreground = {
			Variant_1 = 0x5ec75aff,
			Variant_2 = 0xa7e3a5ff,
			Variant_3 = 0x3db838ff,
			Variant_4 = 0x3db838ff },
		Light_Green_Border = {
			Variant_1 = 0x13a10eff,
			Variant_2 = 0x3db838ff,
			Variant_3 = 0x3db838ff,
			Variant_4 = 0x3db838ff },
		Marigold_Background = {
			Variant_1 = 0x463100ff,
			Variant_2 = 0x835b00ff,
			Variant_3 = 0xeaa300ff,
			Variant_4 = 0xeaa300ff },
		Marigold_Foreground = {
			Variant_1 = 0xf2c661ff,
			Variant_2 = 0xf9e2aeff,
			Variant_3 = 0xefb839ff,
			Variant_4 = 0xefb839ff },
		Marigold_Border = {
			Variant_1 = 0xeaa300ff,
			Variant_2 = 0xefb839ff,
			Variant_3 = 0xefb839ff,
			Variant_4 = 0xefb839ff },
		Success_Background = {
			Variant_1 = 0x052505ff,
			Variant_2 = 0x094509ff,
			Variant_3 = 0x107c10ff,
			Variant_4 = 0x107c10ff },
		Success_Foreground = {
			Variant_1 = 0x54b054ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x9fd89fff,
			Variant_4 = 0x9fd89fff },
		Success_Border = {
			Variant_1 = 0x107c10ff,
			Variant_2 = 0x9fd89fff,
			Variant_3 = 0x9fd89fff,
			Variant_4 = 0x9fd89fff },
		Warning_Background = {
			Variant_1 = 0x4a1e04ff,
			Variant_2 = 0x8a3707ff,
			Variant_3 = 0xf7630cff,
			Variant_4 = 0xf7630cff },
		Warning_Foreground = {
			Variant_1 = 0xfaa06bff,
			Variant_2 = 0xfdcfb4ff,
			Variant_3 = 0xf98845ff,
			Variant_4 = 0xf98845ff },
		Warning_Border = {
			Variant_1 = 0xf7630cff,
			Variant_2 = 0xf98845ff,
			Variant_3 = 0xf98845ff,
			Variant_4 = 0xf98845ff },
		Danger_Background = {
			Variant_1 = 0x3b0509ff,
			Variant_2 = 0x6e0811ff,
			Variant_3 = 0xc50f1fff,
			Variant_4 = 0xc50f1fff },
		Danger_Foreground = {
			Variant_1 = 0xdc626dff,
			Variant_2 = 0xeeacb2ff,
			Variant_3 = 0xeeacb2ff,
			Variant_4 = 0xeeacb2ff },
		Danger_Border = {
			Variant_1 = 0xc50f1fff,
			Variant_2 = 0xdc626dff,
			Variant_3 = 0xdc626dff,
			Variant_4 = 0xdc626dff } }

	font_group_init(&engine.neon_manager.font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	fg_color := neon_theme_ms_light[Neon_Color_Row.Neutral_Foreground_1][0]
	engine.neon_manager.text_style = default_text_style(font_group = engine.neon_manager.font_group, color = fg_color, font_size = 8)
	neon_set_theme(neon_theme_ms_dark) }

neon_set_theme :: proc(theme: ^Neon_Theme) {
	engine.neon_manager.theme = theme
	engine.neon_manager.text_style.color = theme[Neon_Color_Row.Neutral_Foreground_1][0]
	set_clear_color(theme[Neon_Color_Row.Neutral_Background_1][0]) }

// (TODO): Rename to Neon_Color_State
Neon_Color_Column :: enum {
	Normal = 0,
	Hover,
	Pressed,
	Selected,
	Variant_1 = 0,
	Variant_2,
	Variant_3,
	Variant_4 }

// (TODO): Rename to Neon_Color_Classs
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
	Brand_Foreground_2,
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
	Neutral_Stroke_Subtle,
	Brand_Stroke_1,
	Brand_Stroke_2,
	Compound_Brand_Stroke,
	Neutral_Stroke_Disabled,
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

Neon_Theme :: [len(Neon_Color_Row)]Neon_Color

neon_theme_ms_light: ^Neon_Theme
neon_theme_ms_dark: ^Neon_Theme

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

Neon_Button_Appearance :: enum {
	Default,
	Primary,
	Outline,
	Subtle,
	Transparent }

NEON_BUTTON_SIZE_SMALL:  [2]f32 : { 64, 24 }
NEON_BUTTON_SIZE_MEDIUM: [2]f32 : { 96, 32 }
NEON_BUTTON_SIZE_LARGE:  [2]f32 : { 96, 40 }

// (TODO): Pack most of these params in a "Neon_Button_Config" struct. //
draw_neon_button :: proc(rect: Rect, args: ..any, shape: Neon_Button_Shape = .Rounded, appearance: Neon_Button_Appearance = .Default, disabled: bool = false, sep: string = "") {
	text := fmt.aprint(..args, sep = sep)
	rounding: f32 = 0.0
	switch shape {
	case .Rounded: rounding = cast(f32)Neon_Radius.Medium
	case .Circular: rounding = rect.size.y / 2
	case .Square: rounding = 0.0 }
	hover: bool = rect_hovered(rect)
	press: bool = hover && input_query(.Mouse_Left, .Down)

	theme := engine.neon_manager.theme
	fill_neon_color: Neon_Color = theme[Neon_Color_Row.Neutral_Background_2]
	stroke_neon_color: Neon_Color = theme[Neon_Color_Row.Neutral_Stroke_1]
	text_style: Text_Style = engine.neon_manager.text_style
	#partial switch appearance {
	case .Primary:
		fill_neon_color = theme[Neon_Color_Row.Brand_Background]
		stroke_neon_color = fill_neon_color
		text_style.color = WHITE
	case .Outline:
		fill_neon_color = theme[Neon_Color_Row.Neutral_Background_1]
		// stroke_neon_color = theme[Neon_Color_Row.Brand_Stroke_2]
	case .Subtle:
		fill_neon_color = theme[Neon_Color_Row.Neutral_Background_1]
	case .Transparent:
		fill_neon_color = theme[Neon_Color_Row.Neutral_Foreground_2_Brand]
	}

	state := disabled ? Neon_Color_Column.Normal : press ? Neon_Color_Column.Pressed : hover ? Neon_Color_Column.Hover : Neon_Color_Column.Normal
	fill_color: Color = fill_neon_color[state]
	stroke_color: Color = stroke_neon_color[state]
	stroke: f32 = 1
	#partial switch appearance {
	case .Outline:
		fill_color = fill_neon_color[0]
	case .Subtle:
		stroke = 0
	case .Transparent:
		stroke = 0
		text_style.color = fill_color
		fill_color = theme[Neon_Color_Row.Neutral_Background_1][0] }

	if disabled {
		stroke_color = theme[Neon_Color_Row.Neutral_Stroke_1][0]
		text_style.color = theme[Neon_Color_Row.Neutral_Foreground_Disabled][0]
		#partial switch appearance {
		case .Default, .Outline:
			fill_color = theme[Neon_Color_Row.Neutral_Background_4][0]
		case .Primary:
			fill_color = theme[Neon_Color_Row.Neutral_Background_4][0]
			stroke_color = theme[Neon_Color_Row.Neutral_Background_4][0] }
		if hover do set_cursor(.Disabled)
		hover = false
		press = false }

// case .Primary
	draw_rect(rect, fill_color = fill_color, stroke_color = stroke_color, stroke = stroke, rounding = rounding, depth = 0.9)
	if hover do set_cursor(.Hand)
	draw_text_box(text_style, rect, text, h_align = .Center, v_align = .Center, depth = 0.0) }
