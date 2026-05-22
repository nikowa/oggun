#+feature using-stmt
package example_input
import "shared:willow"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"

settings_man: willow.Settings_Manager
asset_manager: willow.Asset_Manager
graphics_manager: willow.Graphics_Manager
window_man: willow.Window_Manager
stopwatch: time.Stopwatch
tick_man: willow.Tick_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	willow.start(entry_point, n_workers_override = 1) }

Sprite :: struct {
	position: [2]f32,
	direction: [2]f32,
	depth: f32,
	speed: f32 }

sprite_init :: proc(sprite: ^Sprite) {
	sprite.position = { rand.float32(), rand.float32() }
	sprite.depth = rand.float32()
	angle: f32 = 2 * math.PI * rand.float32()
	sprite.direction = { linalg.cos(angle), linalg.sin(angle) }
	sprite.speed = 0.1 * (1 + rand.float32()) }

Settings :: struct {
	player_name: string,
	resolution: [2]f32,
	fullscreen: bool }

Color :: struct {
	name: string,
	hex: u32 }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow

	context.logger = log.create_console_logger()

	neon_init()
	using Neon_Color_Row
	fg_color := neon_color_table_ms_light[/*Warning_Foreground*/Neutral_Foreground_1][0]
	bg_color := neon_color_table_ms_light[Neutral_Background_1][0]
	bg2_color := neon_color_table_ms_light[Neutral_Background_2][0]
	bg3_color := neon_color_table_ms_light[Neutral_Background_3][0]
	stroke_color := neon_color_table_ms_light[Neutral_Stroke_1][0]

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_man, default_window_config(title = "Graph"))
	graphics_init(graphics_manager = &graphics_manager, as_mngr = &asset_manager,
		graphics_config = { window_manager = &window_man, clear_color = bg_color })
	tick_manager_init(&tick_man, { tickrate_setting = .LIMITED_60_FPS })

	font_group: Font_Group
	font_group_init(&asset_manager, &font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	text_style: Text_Style = default_text_style(font_group = font_group, color = fg_color)
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	zero_stopwatch(&stopwatch)
	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		tick_asset_manager(&asset_manager)

		if tick_manager_tick(&tick_man) {
			defer tick_manager_reset(&tick_man)
			tick_graphics_manager(&graphics_manager)
			gui_screen := gui_screen(&graphics_manager)
			rect := make_rect(0, 0, 400/* + 300 * math.sin(0.5 * time)*/, 320)
			rect.size.y = text_box_measure(text_style, rect.size.x, text)
			render_rect(&graphics_manager, rect, fill_color = bg3_color, depth = 0.2)
			render_rect_outline(&graphics_manager, rect, color = stroke_color, depth = 0.3)
			gui_text_box(&graphics_manager, text_style, rect, text, h_align = .Justify, v_align = .Top) }
		free_all(context.temp_allocator) }
	return }
