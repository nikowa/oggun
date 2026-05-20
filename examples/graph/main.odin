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
	context.logger = log.create_console_logger()

	willow.neon_init()
	using willow.Neon_Color_Row
	fg_color := willow.neon_color_table_ms_light[Neutral_Foreground_1][0]
	bg_color := willow.neon_color_table_ms_light[Neutral_Background_1][0]
	bg2_color := willow.neon_color_table_ms_light[Neutral_Background_2][0]
	bg3_color := willow.neon_color_table_ms_light[Neutral_Background_3][0]
	stroke_color := willow.neon_color_table_ms_light[Neutral_Stroke_1][0]

	asset_manager = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	willow.window_init(&window_man, willow.WINDOW_CONFIG_DEFAULT)
	willow.graphics_init(
		graphics_manager = &graphics_manager,
		as_mngr = &asset_manager,
		graphics_config = { window_manager = &window_man, clear_color = bg_color })
	willow.init_tick_manager(&tick_man, { tickrate_setting = .LIMITED_60_FPS })

	font: willow.Bitmap_Font
	willow.bitmap_font_init(&asset_manager, &font, { name = "terminus", default_bearing = 0, default_advance = 0 })
	text_style: willow.Bitmap_Text_Style = willow.DEFAULT_BITMAP_TEXT_STYLE
	text_style.font = &font
	text_style.color = fg_color

	willow.zero_stopwatch(&stopwatch)
	for ! graphics_manager.window_closed {
		time := willow.read_stopwatch(&stopwatch)
		willow.tick_asset_manager(&asset_manager)

		if willow.tick_manager_tick(&tick_man) {
			defer willow.tick_manager_reset(&tick_man)
			willow.tick_graphics_manager(&graphics_manager)
			gui_screen := willow.gui_screen(&graphics_manager)
			rect := willow.make_rect(0, 0, 200 + 150 * math.sin(time), 24)
			// willow.render_rect(&graphics_manager, rect, fill_color = bg3_color, depth = 0.2)
			// willow.render_rect_outline(&graphics_manager, rect, color = stroke_color, depth = 0.3)
			// willow.gui_text_line(&graphics_manager, text_style, rect.pos, "Hello, my dear friend!", desired_width = rect.size.x)
			rect = willow.make_rect(0, 0, 200/* + 150 * math.sin(time)*/, 320)
			willow.render_rect(&graphics_manager, rect, fill_color = bg3_color, depth = 0.2)
			willow.render_rect_outline(&graphics_manager, rect, color = stroke_color, depth = 0.3)
			text: string = "Also because of the new contract I have to send our accountant all these things and one of them is my older contracts from jobs because it's a government job and my salary is calculated based on years of experience among other things, so I had to get all my contracts from the magazine and you know how long I've been working for them????"
			willow.gui_text_box(&graphics_manager, text_style, rect, text, h_align = .Center, v_align = .Top)
		}
		free_all(context.temp_allocator) }
	return }
