#+feature using-stmt
package example_neon
import "shared:oggun"
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
	oggun.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

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
	ui_set_theme(ui_theme_ms_light)

	// BORDER_COLOR :: oggun.COLOR_BRAND_STROKE_1_NORMAL_LIGHT

	// // DICK
	// wnd_customize(BORDER_COLOR, BORDER_COLOR)

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

			// DICK
			dr_rect({ { 0, 0 }, { 400, 120} }, fill_color=WHITE, stroke_color=BLACK, radius=24, stroke=1)

			// Background //
			screen_rect := rect_screen()
			// dr_rect(ui_rect_extend(screen_rect, Interval(4)), BORDER_COLOR)
			// gx_depth_scope_dec(0.01)
			// dr_rect(ui_rect_margins(screen_rect, Interval(UI_SPACING_XS)), ui_get_background_color()[0], radius=UI_RADIUS_LARGE)
			// gx_depth_scope_dec(0.01)

			// clip_rect: Rect = { engine.input_manager.mouse_position, { 400, 400 } }
			// dr_rect_outline(clip_rect, RED)
			// gx_clip_scope({ rect = clip_rect, radius = 200 })

			// Buttons //
			position: [2]f32 = { -640, 430 }
			// position: [2]f32 = { 0, 0 }
			ys: [3]f32 = { 0, -30, -60 }
			ds: [3]bool = { false, true, false }
			icons: [3]bool = { false, false, true }
			DELTA :: 72
			for y, i in ys {
				ui_disabled_scope(ds[i])
				icon := icons[i]
				rect: Rect = { position + { - 2 * DELTA, y }, UI_BUTTON_SIZE_SMALL * { 1, 1 } }
				{ ui_appearance_scope(.DEFAULT); ui_button(rect, "*Fish*", icon=icon ? .Notes : .None) }
				rect.position.x += DELTA
				{ ui_appearance_scope(.PRIMARY); ui_button(rect, "*Soup*", icon=icon ? .Image : .None) }
				rect.position.x += DELTA
				{ ui_appearance_scope(.OUTLINE); ui_button(rect, "*Tea*", icon=icon ? .Person : .None) }
				rect.position.x += DELTA
				{ ui_appearance_scope(.SUBTLE); ui_button(rect, "*Cup*", icon=icon ? .Delete : .None) }
				rect.position.x += DELTA
				{ ui_appearance_scope(.TRANSPARENT); ui_button(rect, "*Fork*", icon=icon ? .Sticker : .None) } }

			// Transition Animation //
			position = { -640 - 2 * DELTA, 340 }
			rect: Rect = { position, UI_BUTTON_SIZE_SMALL }
			x0: f32 = position.x + DELTA
			x1: f32 = position.x + DELTA * 4
			ui_appearance_push(.DEFAULT)
			x := x0 + (x1 - x0) * ease_sin_3(ui_anim_transition([2]f32{ 0, 1 }, 0, 1, true, .PRESS in ui_button(rect, "*Anim*")))
			ui_appearance_pop()
			{ ui_appearance_scope(.PRIMARY); ui_button({ { x, position.y }, UI_BUTTON_SIZE_SMALL }, "") }

			// Accordion //
			accordion := ui_accordion({ -780, 240 }, multiple=false)
			{ dr_text_box(text, ui_accordion_add(accordion, "*Header* _A_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, ui_accordion_add(accordion, "*Header* _B_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, ui_accordion_add(accordion, "*Header* _C_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }
			{ dr_text_box(text, ui_accordion_add(accordion, "*Header* _D_", { 400, 100 }), h_align=.JUSTIFY, v_align=.TOP) }

			// Image //
			// dr_image(&image, { { 0, 0 }, { 400, 400 } })

			// Badge //
			sizes: [3]UI_Size = { .S, .M, .L }
			for size, i in sizes {
				position = { -400, 360 + 32 * f32(i) }
				{	ui_appearance_scope(.DEFAULT)
					dr_badge(position, size=size, color=.BLUE_BACKGROUND, h_align=.CENTER, icon=.Accept) }
				position.x += 24
				{	ui_appearance_scope(.SUBTLE)
					dr_badge(position, size=size, color=.BLUE_BACKGROUND, h_align=.CENTER, icon=.Save) }
				position.x += 24
				{	ui_appearance_scope(.OUTLINE)
					dr_badge(position, size=size, color=.BLUE_BACKGROUND, h_align=.CENTER, icon=.File_Error) }
				position.x += 24
				{	ui_appearance_scope(.TRANSPARENT)
					dr_badge(position, size=size, color=.BLUE_BACKGROUND, h_align=.CENTER, icon=.Accept) } }
			position = { -400, 360 - 32 }
			{	ui_appearance_scope(.DEFAULT)
				dr_badge(position, text="*420+*", size=.S, color=.BLUE_BACKGROUND, h_align=.CENTER) }
			{	ui_appearance_scope(.TRANSPARENT)
				dr_badge(position + { 3 * 24, 0 }, text="*420+*", size=.S, color=.BLUE_BACKGROUND, h_align=.CENTER) }
			position.y -= 24
			{	ui_appearance_scope(.DEFAULT)
				dr_badge(position, text="*420+*", size=.M, color=.BLUE_BACKGROUND, h_align=.CENTER) }
			{	ui_appearance_scope(.TRANSPARENT)
				dr_badge(position + { 3 * 24, 0 }, text="*420+*", size=.M, color=.BLUE_BACKGROUND, h_align=.CENTER) }
			position.y -= 24
			{	ui_appearance_scope(.DEFAULT)
				dr_badge(position, text="*420+*", size=.L, color=.BLUE_BACKGROUND, h_align=.CENTER) }
			{	ui_appearance_scope(.TRANSPARENT)
				dr_badge(position + { 3 * 24, 0 }, text="*420+*", size=.L, color=.BLUE_BACKGROUND, h_align=.CENTER) }

			// Colors //
			_, colors_rect := rect_split_h(rect_screen(), Ratio(0.8), Interval(0))
			// dr_rect_outline(colors_rect, RED)
			ROWS :: len(UI_Theme_Key)
			keys_rect, values_rect := rect_split_h(colors_rect, Ratio(0.5), Interval(0))
			keys_grid := rect_grid_make(keys_rect, { 1, ROWS })
			values_grid := rect_grid_make(values_rect, { 4, ROWS })
			for i in 0 ..< len(UI_Theme_Key) {
				key_string, _ := strings.replace_all(strings.to_ada_case(fmt.aprintf("%v", cast(UI_Theme_Key)i)), "_", " ")
				dr_text_box(key_string, keys_grid[rect_grid_index({ 1, ROWS }, 0, ROWS - i - 1)], h_align=.LEFT)
				for j in 0 ..< 4 {
					color := engine.ui_manager.theme[i][j]
					dr_rect(values_grid[rect_grid_index({ 4, ROWS }, j, ROWS - i - 1)], color, integer=false)
				}
			}

			// Avatar //
			position = { -260, 420 }
			{	ui_appearance_scope(.OUTLINE)
				dr_avatar(position, name="", image=nil) }
			position.x += 40
			{	ui_appearance_scope(.DEFAULT)
				dr_avatar(position, name="Nikola Petrov Stefanov", image=nil) }
			position.x += 40
			{	ui_appearance_scope(.DEFAULT)
				dr_avatar(position, name="Nikola Petrov Stefanov", image=&image) }

			// Test string //
			// assert(am_command(String_Asset, &string_asset.asset, .Import, watch=true))
			// assert(! ptr_is_temp(raw_data(string_asset.str)))
			// assert(am_command(String_Asset, &string_asset.asset, .Load, watch=true))
			// // log.warn(string_asset.str)
			// assert(! ptr_is_temp(raw_data(string_asset.str)))
			// dr_text_box(string_asset.str, { { 0, 0 }, { 120, 20 } }, h_align=.CENTER, v_align=.CENTER)

			// Metrics //
			ui_metrics_widget()
			// metrics_rect := ui_rect_embed(ui_rect_margins(rect_screen(), Interval(8)), { 160, 12 }, { .East, .North })
			// dr_text_box(fmt.aprintf("Backing Allocator: %s", aprint_size_symbolic(engine.tracking_allocator.current_memory_allocated)), metrics_rect, h_align=.LEFT, v_align=.TOP)
			// dr_text_box(fmt.aprintf("Temp Allocator: %s", aprint_size_symbolic(engine.tracking_temp_allocator.current_memory_allocated)), rect_translate(metrics_rect, { 0, -14 }), h_align=.RIGHT, v_align=.TOP)

		}
	}
	return }
