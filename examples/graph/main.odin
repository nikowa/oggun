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
	fg_color := willow.neon_color_table_ms_light[/*Warning_Foreground*/Neutral_Foreground_1][0]
	bg_color := willow.neon_color_table_ms_light[Neutral_Background_1][0]
	bg2_color := willow.neon_color_table_ms_light[Neutral_Background_2][0]
	bg3_color := willow.neon_color_table_ms_light[Neutral_Background_3][0]
	stroke_color := willow.neon_color_table_ms_light[Neutral_Stroke_1][0]

	asset_manager = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP, watch = true }, context.allocator)
	window_config: willow.Window_Config = willow.WINDOW_CONFIG_DEFAULT
	window_config.size = { 1664, 936 }
	window_config.position = [2]f32{ 0, 0 }
	window_config.title = "Graph"
	willow.window_init(&window_man, window_config)
	willow.graphics_init(
		graphics_manager = &graphics_manager,
		as_mngr = &asset_manager,
		graphics_config = { window_manager = &window_man, clear_color = bg_color })
	willow.init_tick_manager(&tick_man, { tickrate_setting = .LIMITED_60_FPS })

	font: willow.Bitmap_Font
	willow.bitmap_font_init(&asset_manager, &font, { name = "font", default_bearing = 0, default_advance = 0 })
	text_style: willow.Bitmap_Text_Style = willow.DEFAULT_BITMAP_TEXT_STYLE
	text_style.font = &font
	text_style.color = fg_color
	text_style.spacing = 1.0
	text_style.scale_factor = 0.2
	for i in 0 ..< 8 do fmt.printfln("vec2(%f, %f),", rand.float32(), rand.float32())
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	willow.zero_stopwatch(&stopwatch)
	for ! graphics_manager.window_closed {
		time := willow.read_stopwatch(&stopwatch)
		willow.tick_asset_manager(&asset_manager)

		if willow.tick_manager_tick(&tick_man) {
			defer willow.tick_manager_reset(&tick_man)
			willow.tick_graphics_manager(&graphics_manager)
			gui_screen := willow.gui_screen(&graphics_manager)
			rect := willow.make_rect(0, 0, 400/* + 350 * math.sin(time)*/, 320)
			rect.size.y = willow.text_box_measure(text_style, rect.size.x, text)
			willow.render_rect(&graphics_manager, rect, fill_color = bg3_color, depth = 0.2)
			willow.render_rect_outline(&graphics_manager, rect, color = stroke_color, depth = 0.3)
			willow.gui_text_box(&graphics_manager, text_style, rect, text, h_align = .Left, v_align = .Top) }
		free_all(context.temp_allocator) }
	return }
