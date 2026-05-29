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
import "core:mem"

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

	engine_init(
		"Graph Example",
	graphics_config = { clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT })

	font_group: Font_Group
	font_group_init(&font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	bg_color := tgui_theme_ms_dark[TGUI_Theme_Key.NEUTRAL_BACKGROUND_3][0]
	fg_color := tgui_theme_ms_dark[TGUI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	stroke_color := tgui_theme_ms_dark[TGUI_Theme_Key.NEUTRAL_STROKE_1][0]
	text_style: Text_Style = default_text_style(font_group = font_group, color = fg_color, font_size = 8)
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			rect := make_rect(0, 0, 400 + 300 * math.sin(0.05 * time), 320)
			rect.size.y = _measure_text_box(text_style, rect.size.x, text)
			// points: [2][2]f32 = {
			// 	{  }
			// }

			tail: [2]f32 = { -400, 100 }
			head: [2]f32 = { 0, 200 }
			head = engine.input_manager.mouse_position
			vector := head - tail
			angle: f32 = linalg.angle_between([2]f32{ 0, -1 }, vector) * (vector.x >= 0 ? 1 : -1)
			draw_line({ tail, head }, text_style.color, integer = false)
			arrow := head
			char: u8 = '\x1F'
			arrow -= 0.5 * symbol_size_from_text_style(text_style, char)
			// arrow.y -= f32(text_style.font_size) / 2
			arrow_rect: Rect = { { 0, 200 }, { 12, 12 } }
			draw_text_symbol_rect(char, arrow_rect, 0.5, style = text_style, uv_offset = { -0.5 / 12, 0 }, angle = time)
			// draw_rect_outline(arrow_rect, RED, depth = 0.4)
			// draw_text_symbol(char, arrow, depth = 0.1, style = text_style, angle = angle, integer = false)
			draw_rect(rect_margins(rect, Interval(-8)), fill_color = bg_color, depth = 0.2, rounding = 4, stroke_color = stroke_color/*BLACK*/, stroke = 1)
			draw_text_box(text_style, rect, text, h_align = .JUSTIFY, v_align = .CENTER, integer = false) }
		free_all(context.temp_allocator) }
	return }
