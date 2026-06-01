#+feature using-stmt
package example_neon
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

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow

	context.logger = log.create_console_logger()
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 1000 * mem.Megabyte))
	context.temp_allocator = mem.arena_allocator(&arena)

	engine_init(
		"Willow",
		asset_config = default_asset_manager_config(watch = false),
		graphics_config = default_graphics_config(clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK),
		tick_config = default_tick_manager_config(tickrate_setting = .LIMITED_144_FPS),
		input_config = default_input_config(raw_input = false))
	tgui_set_theme(tgui_theme_ms_dark)

	image: Image_Asset
	init_image(&image, { url = "image:kitten-1.png" })
	assert(asset_commands(Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."

	zero_stopwatch(&stopwatch)

	context = engine_loop_context()

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			// draw_rect(rect_screen(), BLACK, depth = 0.9)
			// clip_rect: Rect = { engine.input_manager.mouse_position, { 400, 400 } }
			// draw_rect_outline(clip_rect, RED)
			{
				// gx_clip_scope(clip_rect)

				// Buttons //
				position: [2]f32 = { -500, 400 }
				ys: [3]f32 = { 24, -24, -48 - 24 }
				ds: [3]bool = { false, true, false }
				icons: [3]bool = { false, false, true }
				for y, i in ys {
					disabled := ds[i]
					icon := icons[i]
					DELTA :: 120
					rect: Rect = { position + { - 2 * DELTA, y }, TGUI_BUTTON_SIZE_SMALL * { 1, 1 } }
					tgui_button(rect, "*Fish*", appearance = .DEFAULT, shape = .ROUNDED, disabled = disabled, icon=icon ? .Notes : .None)
					rect.position.x += DELTA
					tgui_button(rect, "*Soup*", appearance=.PRIMARY, shape=.ROUNDED, disabled=disabled, icon=icon ? .Image : .None)
					rect.position.x += DELTA
					tgui_button(rect, "*Tea*", appearance=.OUTLINE, shape=.ROUNDED, disabled=disabled, icon=icon ? .Person : .None)
					rect.position.x += DELTA
					tgui_button(rect, "*Cup*", appearance=.SUBTLE, shape=.ROUNDED, disabled=disabled, icon=icon ? .Delete : .None)
					rect.position.x += DELTA
					tgui_button(rect, "*Fork*", appearance=.TRANSPARENT, shape=.ROUNDED, disabled=disabled, icon=icon ? .Sticker : .None) }

				// Transition Animation //
				position = { -740, 280 }
				rect: Rect = { position, TGUI_BUTTON_SIZE_SMALL }
				x0: f32 = position.x + 120
				x1: f32 = position.x + 120 * 4
				x := x0 + (x1 - x0) * ease_sin_3(tgui_anim_transition([2]f32{ 0, 1 }, 0, 1, true, .PRESS in tgui_button(rect, "*Anim*", appearance = .DEFAULT, shape = .ROUNDED)))
				tgui_button({ { x, position.y }, TGUI_BUTTON_SIZE_SMALL }, "", appearance = .PRIMARY, shape = .ROUNDED)

				{
					panel_rect := tgui_chevron({}, "*Header*", { 400, 100 })
					// draw_image(&image, make_rect(0, 0, 120, 120), depth = 0.0)
					draw_text_box(engine.tgui_manager.text_style, panel_rect, text, h_align=.JUSTIFY, v_align=.TOP)
				}
			}
			// Accordion //
			// tgui_accordion({ 0, 0 })
		} }
	return }
