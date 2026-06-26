#+feature using-stmt
package oggun
import "base:runtime"
import "core:math/linalg"
import "core:fmt"
import "core:strings"
import "core:math"

// (TODO): Add TGUI versions of all of these, using the default TGUI styles.

// (TODO): Pack most of these params in a "Neon_Button_Config" struct. //
dr_button :: proc(rect: Rect, text: string, icon: UI_Icon = .None) {
	rect := rect
	radius: f32 = 0.0
	shape := ui_button_shape_get()
	disabled := ui_disabled_get()
	switch shape {
	case .ROUNDED: radius = UI_RADIUS_MEDIUM
	case .CIRCULAR: radius = rect.size.y / 2
	case .SQUARE: radius = 0.0 }
	hover: bool = rect_hovered(rect)
	press: bool = hover && input_query(.Mouse_Left, .DOWN)

	theme := engine.ui_manager.theme
	ui_fill_color: UI_Color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_2]
	stroke_neon_color: UI_Color = theme[UI_Theme_Key.NEUTRAL_STROKE_1]
	text_style: Text_Style = engine.ui_manager.text_style
	appearance := ui_appearance_get()
	#partial switch appearance {
	case .PRIMARY:
		ui_fill_color = theme[UI_Theme_Key.BRAND_BACKGROUND_1]
		stroke_neon_color = ui_fill_color
		text_style.color = WHITE
	case .OUTLINE:
		ui_fill_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_1]
		// stroke_neon_color = theme[UI_Theme_Key.BRAND_STROKE_2]
	case .SUBTLE:
		ui_fill_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_1]
	case .TRANSPARENT:
		ui_fill_color = theme[UI_Theme_Key.NEUTRAL_FOREGROUND_2_BRAND]
	}

	state := disabled ? UI_Variant.NORMAL : press ? UI_Variant.PRESSED : hover ? UI_Variant.HOVER : UI_Variant.NORMAL
	fill_color: Color = ui_fill_color[state]
	stroke_color: Color = stroke_neon_color[state]
	stroke: f32 = 1
	#partial switch appearance {
	case .OUTLINE:
		fill_color = ui_fill_color[0]
	case .SUBTLE:
		stroke = 0
	case .TRANSPARENT:
		stroke = 0
		text_style.color = fill_color
		fill_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_1][0] }

	if disabled {
		stroke_color = theme[UI_Theme_Key.NEUTRAL_STROKE_1][0]
		text_style.color = theme[UI_Theme_Key.NEUTRAL_FOREGROUND_DISABLED][0]
		#partial switch appearance {
		case .DEFAULT, .OUTLINE:
			fill_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
		case .PRIMARY:
			fill_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
			stroke_color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_4][0] }
		// if hover do set_cursor(.Disabled)
		hover = false
		press = false }

// case .PRIMARY
	dr_rect(rect, fill_color = fill_color, stroke_color = stroke_color, stroke = stroke, radius = radius)
	// if hover do set_cursor(.Hand)
	// dr_icon :: proc(icon: UI_Icon, position: [2]f32, angle: f32 = 0.0) {
	if icon != .None {
		icon_position := rect.position + { - rect.size.x / 2 + rect.size.y / 2, 0 }
		dr_icon(icon, icon_position)
		// dr_rect_outline(rect, RED)
		// DICK
		rect = rect_margins_variate(rect, west=Interval(UI_ICON_SIZE.y))
	}
	{ ui_text_style_scope(text_style); dr_text_box(text, rect, h_align = .CENTER, v_align = .CENTER) }
	// dr_rect_outline(rect, RED)
}

dr_icon :: proc { dr_icon_basic, dr_icon_extended }

dr_icon_basic :: proc(icon: UI_Icon, position: [2]f32, angle: f32=0.0, color: Color, size: UI_Size) {
	bold, bolder: bool
	scale: f32
	switch size {
	case .L, .XL, .XXL, .XXXL:
		scale = 1
	case .M:
		bold = true
		scale = 0.5
	case .XXS, .XS, .S:
		bolder = true
		scale = 0.333333 }
	dr_icon_extended(icon, position, angle, color, bold, bolder, scale) }

dr_icon_extended :: proc(icon: UI_Icon, position: [2]f32, angle: f32=0.0, color: Color=WHITE, bold: bool=false, bolder: bool=false, scale: f32=1.0) {
	// dr_rect_outline({ position, UI_ICON_SIZE }, RED)
	icons_text_style := engine.ui_manager.icons_text_style
	icons_text_style.color = color
	icons_text_style.bold = bold
	icons_text_style.italic = bolder
	icons_text_style.font_size = Font_Size(scale * cast(f32)icons_text_style.font_size)
	ui_text_style_scope(icons_text_style)
	dr_text_symbol_rect(cast(u8)icon, { position, UI_ICON_SIZE }, angle = angle) }

dr_avatar :: proc(position: [2]f32, name: string="", image: ^Image_Asset=nil, icon: UI_Icon=.Person) {
	avatar_rect: Rect = { position, UI_AVATAR_SIZE }
	theme := engine.ui_manager.theme
	fill_color: Color = theme[UI_Theme_Key.NEUTRAL_BACKGROUND_2][UI_Variant.SELECTED]
	if image != nil {
		// gx_clip_scope({ rect = avatar_rect, radius = 16 })
		dr_image(image, avatar_rect) }
	else {
		dr_rect(avatar_rect, fill_color, radius = 16)
		avatar_text_style := ui_text_style_get()
		avatar_text_style.color = theme[UI_Theme_Key.NEUTRAL_FOREGROUND_4][0]
		if name != "" {
			subnames: []string = strings.split(name, " ")
			avatar_initials: string = strings.to_upper(strings.concatenate({ subnames[0][0:1], subnames[len(subnames) - 1][0:1] }))
			avatar_text_style.font_size = 10
			avatar_text_style.bold = true
			ui_text_style_scope(avatar_text_style)
			dr_text_box(avatar_initials, avatar_rect, h_align = .CENTER, v_align = .CENTER) }
		else {
			ui_text_style_scope(avatar_text_style)
			dr_icon(icon, position) } }
	gx_depth_scope_dec(0.01)
	dr_badge(avatar_rect.position + { 10, -10 }, color=.BLUE_BACKGROUND, size=.S, icon=.Accept)

	// badge_color := theme[UI_Theme_Key.GREEN_BACKGROUND][2]
	// barge_rect: Rect = { avatar_rect.position + { 10, -10 }, { 10, 10 } }
	// dr_rect(barge_rect, badge_color, radius = 6, integer=false)
	// dr_icon(.Accept, barge_rect.position, bold=true, scale=0.5)
}

dr_badge :: proc(position: [2]f32, size: UI_Size=.S, color: UI_Theme_Key, text: string="", icon: UI_Icon=.None, h_align: UI_H_Align=.CENTER) {
	theme := engine.ui_manager.theme
	appearance := ui_appearance_get()
	text_style := ui_text_style_get()
	gx_depth_scope_dec(0.01)
	rect: Rect = { position=position }
	font_size: Font_Size
	switch size {
	case .XXS, .XS, .S:
		rect.size = UI_BADGE_SIZE_S
		text_style.font_size = 5
	case .M:
		rect.size = UI_BADGE_SIZE_M
		text_style.font_size = 7
	case .L, .XL, .XXL, .XXXL:
		rect.size = UI_BADGE_SIZE_L
		text_style.font_size = 9 }
	if text != "" {
		scale_factor := font_size_to_font_scale(text_style.font_size, text_style.font_group.normal)
		width, _ := ui_measure_text(text, scale_factor)
		rect.size.x += max(0, width - rect.size.x / 2) }
	radius: f32 = rect.size.y / 2
	#partial switch appearance {
	case .DEFAULT, .PRIMARY:
		dr_rect(rect, theme[color][2], radius=radius + 1, integer=true)
		text_style.color = ui_get_background_color()[0]
	case .SUBTLE:
		dr_rect(rect, ui_get_background_color()[0], radius=radius + 1, integer=true)
		text_style.color = theme[color][2]
	case .OUTLINE:
		dr_rect(rect, theme[color][2], radius=radius + 1, integer=true)
		gx_depth_scope_dec(0.01)
		text_style.color = theme[color][2]
		dr_rect({ position, rect.size - { 2, 2 } }, ui_get_background_color()[0], radius=radius, integer=true)
	case .TRANSPARENT:
		dr_rect(rect, theme[color][1], radius=radius + 1, integer=true)
		gx_depth_scope_dec(0.01)
		text_style.color = theme[auto_cast (int(color) + 1)][0]
		dr_rect({ rect.position, rect.size - { 2, 2 } }, theme[color][0], radius=radius, integer=true)
	}
// theme[color][2]

	gx_depth_scope_dec(0.01)
	// dr_rect_outline(rect, RED)
	if text != "" {
		ui_text_style_scope(text_style)
		dr_text_box(text, rect) }
	else if icon != .None {
		ui_text_style_scope(text_style)
		dr_icon(icon, position, bold=true, scale=0.04 * f32(rect.size.y)) }

	// gx_depth_scope_dec(0.01)
	// dr_rect({ position, { 2, 2 } }, RED, integer=false)
}

// (TODO): Add "dr_arrow" proc with arbitrary angle.
// (TODO): Add arrow procs for .Play icon, and .Send icon.

dr_arrow_rectilinear :: proc(position: [2]f32, direction: Compass, color: Color, size: UI_Size=.M) {
	// dr_rect({ position, { 1, 1 } }, RED)
	offset: f32
	switch size {
	case .XXS, .XS, .S:
		offset = 1
	case .M:
		offset = 2
	case .L, .XL, .XXL, .XXXL:
		offset = 4 }
	dr_icon_basic(.Chevron, position - offset * compass_normal(direction), math.to_radians_f32(90) + compass_angle(direction), color, size) }
