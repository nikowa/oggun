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

asset_manager: willow.Asset_Manager
graphics_manager: willow.Graphics_Manager
window_manager: willow.Window_Manager
tick_manager: willow.Tick_Manager
stopwatch: time.Stopwatch

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
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 1000 * mem.Megabyte))
	context.temp_allocator = mem.arena_allocator(&arena)

	neon_init()
	using Neon_Color_Row
	fg_color := neon_color_table_ms_light[/*Warning_Foreground*/Neutral_Foreground_1][0]
	bg_color := neon_color_table_ms_light[Neutral_Background_1][0]
	bg2_color := neon_color_table_ms_light[Neutral_Background_2][0]
	bg3_color := neon_color_table_ms_light[Neutral_Background_3][0]
	stroke_color := neon_color_table_ms_light[Neutral_Stroke_1][0]

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_manager, default_window_config(title = "Graph"))
	graphics_init(graphics_manager = &graphics_manager, asset_manager = &asset_manager,
		graphics_config = { window_manager = &window_manager, clear_color = bg_color })
	tick_manager_init(&tick_manager, { tickrate_setting = .LIMITED_60_FPS })

	font_group: Font_Group
	font_group_init(&asset_manager, &font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	text_style: Text_Style = default_text_style(font_group = font_group, color = fg_color, font_size = 8)
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		tick_asset_manager(&asset_manager)

		if tick_manager_tick(&tick_manager) {
			defer tick_manager_reset(&tick_manager)
			tick_graphics_manager(&graphics_manager)
			rect := make_rect(0, 0, 400 + 300 * math.sin(0.05 * time), 320)
			rect.size.y = _measure_text_box(text_style, rect.size.x, text)
			draw_rect(&graphics_manager, make_rect(400, 200, 100, 40), fill_color = RED, stroke_color = BLUE, depth = 0.2, rounding = 20, stroke = 2)
			draw_rect(&graphics_manager, gui_margins(rect, -8), fill_color = bg3_color, depth = 0.2, rounding = 4, stroke_color = stroke_color/*BLACK*/, stroke = 1)
			draw_text_box(&graphics_manager, text_style, rect, text, h_align = .Justify, v_align = .Center, integer = true) }
		free_all(context.temp_allocator) }
	return }
