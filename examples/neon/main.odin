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
import "core:strings"

stopwatch: time.Stopwatch

main :: proc() {
	context.logger = log.create_console_logger()
	willow.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow

	context = engine_begin_init(
		engine_config=default_engine_config(
			game_name="Neon Example",
			track_backing_allocations=true,
			track_temp_allocations=true,
			log_backing_allocations=false,
			log_temp_allocations=false),
		asset_config=default_asset_manager_config(watch=true),
		graphics_config=default_graphics_config(clear_color=COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK),
		tick_config=default_tick_manager_config(tickrate_setting=.LIMITED_144_FPS),
		input_config=default_input_config(raw_input=false))
	gi_set_theme(gi_theme_ms_dark)

	image: Image_Asset
	init_image(&image, { url = "image:kitten-1.png" })
	assert(am_commands(Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."

	zero_stopwatch(&stopwatch)

	string_asset := new(String_Asset)
	am_init_string_asset(string_asset, { url="string:test_string.txt" })
	assert(am_commands(String_Asset, &string_asset.asset, { .Import, .Load }))
	assert(! ptr_is_temp(raw_data(string_asset.str)))

	context = engine_end_init()

	// a := make([]u8, 10, context.allocator)
	// b := make([]u8, 10, engine.backing_allocator)
	// assert(ptr_is_temp(raw_data(a)))
	// assert(! ptr_is_temp(raw_data(b)))

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {

			// clip_rect: Rect = { engine.input_manager.mouse_position, { 400, 400 } }
			// dr_rect_outline(clip_rect, RED)
			// gx_clip_scope({ rect = clip_rect, radius = 200 })

			// Buttons //
			position: [2]f32 = { -500, 400 }
			// position: [2]f32 = { 0, 0 }
			ys: [3]f32 = { 24, -24, -48 - 24 }
			ds: [3]bool = { false, true, false }
			icons: [3]bool = { false, false, true }
			for y, i in ys {
				gi_disabled_scope(ds[i])
				icon := icons[i]
				DELTA :: 120
				rect: Rect = { position + { - 2 * DELTA, y }, GI_BUTTON_SIZE_SMALL * { 1, 1 } }
				{ gi_appearance_scope(.DEFAULT); gi_button(rect, "*Fish*", icon=icon ? .Notes : .None) }
				rect.position.x += DELTA
				{ gi_appearance_scope(.PRIMARY); gi_button(rect, "*Soup*", icon=icon ? .Image : .None) }
				rect.position.x += DELTA
				{ gi_appearance_scope(.OUTLINE); gi_button(rect, "*Tea*", icon=icon ? .Person : .None) }
				rect.position.x += DELTA
				{ gi_appearance_scope(.SUBTLE); gi_button(rect, "*Cup*", icon=icon ? .Delete : .None) }
				rect.position.x += DELTA
				{ gi_appearance_scope(.TRANSPARENT); gi_button(rect, "*Fork*", icon=icon ? .Sticker : .None) } }

			// Transition Animation //
			position = { -740, 280 }
			rect: Rect = { position, GI_BUTTON_SIZE_SMALL }
			x0: f32 = position.x + 120
			x1: f32 = position.x + 120 * 4
			gi_appearance_push(.DEFAULT)
			x := x0 + (x1 - x0) * ease_sin_3(gi_anim_transition([2]f32{ 0, 1 }, 0, 1, true, .PRESS in gi_button(rect, "*Anim*")))
			gi_appearance_pop()
			{ gi_appearance_scope(.PRIMARY); gi_button({ { x, position.y }, GI_BUTTON_SIZE_SMALL }, "") }

			// Accordion //
			accordion := gi_accordion({ -780, 240 }, multiple=false)
			{ dr_text_box(text, gi_accordion_add(accordion, "*Header* _A_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, gi_accordion_add(accordion, "*Header* _B_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, gi_accordion_add(accordion, "*Header* _C_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, gi_accordion_add(accordion, "*Header* _D_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }

			// Image //
			// dr_image(&image, { { 0, 0 }, { 400, 400 } })

			// Avatar //
			// dr_rect({ engine.window_manager.size/2, { 4, 4 } }, RED)
			dr_avatar({ 0, 0 }, name=""/*"Nikola Petrov Stefanov"*/, image=nil/*&image*/)

			// Test string //
			// assert(am_command(String_Asset, &string_asset.asset, .Import, watch=true))
			// assert(! ptr_is_temp(raw_data(string_asset.str)))
			// assert(am_command(String_Asset, &string_asset.asset, .Load, watch=true))
			// // log.warn(string_asset.str)
			// assert(! ptr_is_temp(raw_data(string_asset.str)))
			// dr_text_box(string_asset.str, { { 0, 0 }, { 120, 20 } }, h_align=.CENTER, v_align=.CENTER)

			// Metrics //
			gi_metrics_widget()
			// metrics_rect := gi_rect_embed(gi_rect_margins(gi_rect_screen(), Interval(8)), { 160, 12 }, { .East, .North })
			// dr_text_box(fmt.aprintf("Backing Allocator: %s", aprint_size_symbolic(engine.tracking_allocator.current_memory_allocated)), metrics_rect, h_align=.LEFT, v_align=.TOP)
			// dr_text_box(fmt.aprintf("Temp Allocator: %s", aprint_size_symbolic(engine.tracking_temp_allocator.current_memory_allocated)), gi_rect_translate(metrics_rect, { 0, -14 }), h_align=.RIGHT, v_align=.TOP)

		}
	}
	return }
