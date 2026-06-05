#+feature using-stmt
package willow
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"

// (TODO): Add TGUI versions of all of these, using the default TGUI styles.

// (TODO): Pack most of these params in a "Neon_Button_Config" struct. //
dr_button :: proc(rect: Rect, text: string, icon: GI_Icon = .None) {
	rect := rect
	radius: f32 = 0.0
	shape := gi_get_button_shape()
	disabled := gi_get_disabled()
	switch shape {
	case .ROUNDED: radius = GI_RADIUS_MEDIUM
	case .CIRCULAR: radius = rect.size.y / 2
	case .SQUARE: radius = 0.0 }
	hover: bool = rect_hovered(rect)
	press: bool = hover && input_query(.Mouse_Left, .DOWN)

	theme := engine.gi_manager.theme
	gi_fill_color: GI_Color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_2]
	stroke_neon_color: GI_Color = theme[GI_Theme_Key.NEUTRAL_STROKE_1]
	text_style: Text_Style = engine.gi_manager.text_style
	appearance := gi_get_appearance()
	#partial switch appearance {
	case .PRIMARY:
		gi_fill_color = theme[GI_Theme_Key.BRAND_BACKGROUND]
		stroke_neon_color = gi_fill_color
		text_style.color = WHITE
	case .OUTLINE:
		gi_fill_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_1]
		// stroke_neon_color = theme[GI_Theme_Key.BRAND_STROKE_2]
	case .SUBTLE:
		gi_fill_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_1]
	case .TRANSPARENT:
		gi_fill_color = theme[GI_Theme_Key.NEUTRAL_FOREGROUND_2_BRAND]
	}

	state := disabled ? GI_Variant.NORMAL : press ? GI_Variant.PRESSED : hover ? GI_Variant.HOVER : GI_Variant.NORMAL
	fill_color: Color = gi_fill_color[state]
	stroke_color: Color = stroke_neon_color[state]
	stroke: f32 = 1
	#partial switch appearance {
	case .OUTLINE:
		fill_color = gi_fill_color[0]
	case .SUBTLE:
		stroke = 0
	case .TRANSPARENT:
		stroke = 0
		text_style.color = fill_color
		fill_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_1][0] }

	if disabled {
		stroke_color = theme[GI_Theme_Key.NEUTRAL_STROKE_1][0]
		text_style.color = theme[GI_Theme_Key.NEUTRAL_FOREGROUND_DISABLED][0]
		#partial switch appearance {
		case .DEFAULT, .OUTLINE:
			fill_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
		case .PRIMARY:
			fill_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
			stroke_color = theme[GI_Theme_Key.NEUTRAL_BACKGROUND_4][0] }
		// if hover do set_cursor(.Disabled)
		hover = false
		press = false }

// case .PRIMARY
	dr_rect(rect, fill_color = fill_color, stroke_color = stroke_color, stroke = stroke, radius = radius)
	// if hover do set_cursor(.Hand)
	// dr_icon :: proc(icon: GI_Icon, position: [2]f32, angle: f32 = 0.0) {
	if icon != .None {
		icon_position := rect.position + { - rect.size.x / 2 + rect.size.y / 2, 0 }
		dr_icon(icon, icon_position)
		// dr_rect_outline(rect, RED)
		// DICK
		rect = gi_rect_margins_variate(rect, west=Interval(GI_ICON_SIZE.y))
	}
	{ gi_text_style_scope(text_style); dr_text_box(text, rect, h_align = .CENTER, v_align = .CENTER) }
	// dr_rect_outline(rect, RED)
}

dr_icon :: proc(icon: GI_Icon, position: [2]f32, angle: f32 = 0.0) {
	// dr_rect_outline({ position, GI_ICON_SIZE }, RED)
	gi_text_style_scope(engine.gi_manager.icons_text_style)
	dr_text_symbol_rect(cast(u8)icon, { position, GI_ICON_SIZE }, angle = angle) }
