#+feature using-stmt
package example_gui
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

stopwatch: time.Stopwatch

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="GUI Example", temp_allocator_cap=1000 * mem.Megabyte),
		asset_config=default_asset_manager_config(watch=false),
		graphics_config=default_graphics_config(clear_color=BLACK),
		tick_config=default_tick_manager_config(tickrate_setting=.LIMITED_144_FPS),
		input_config=default_input_config(raw_input=false))
	set_clear_color(WHITE)

	zero_stopwatch(&stopwatch)

	context = engine_end_init()

	screen_rect := rect_screen()
	for engine_running() do if engine_tick() {
		time := read_stopwatch(&stopwatch)
		rect := ui_rect_margins(screen_rect, Ratio(0.05))
		FILL_1 :: COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT
		FILL_2 :: COLOR_NEUTRAL_BACKGROUND_1_PRESSED_LIGHT
		STROKE :: COLOR_NEUTRAL_FOREGROUND_1_LIGHT
		gx_depth_push_inc(0.01)
		dr_rect(screen_rect, FILL_1, STROKE, stroke = 1)
		gx_depth_push_inc(0.01)
		dr_rect(rect, FILL_2, STROKE, stroke = 1)
		rect_0 := ui_rect_embed(rect, { 1000, 800 }, { .West, .South })
		gx_depth_push_inc(0.01)
		dr_rect(rect_0, FILL_1, STROKE, stroke = 1)
		rect_1, rect_2 := rect_split_h(ui_rect_margins(rect_0, Interval(16)), Interval(120), Interval(16))
		gx_depth_push_inc(0.01)
		dr_rect(rect_1, FILL_2, STROKE, stroke = 1)
		gx_depth_push_inc(0.01)
		dr_rect(rect_2, FILL_2, STROKE, stroke = 1)
		rect_3 := ui_rect_margins_variate(rect_2, north = Ratio(0.1), east = Ratio(0.05))
		gx_depth_push_inc(0.01)
		dr_rect(rect_3, FILL_1, STROKE, stroke = 1)
		rect_3 = ui_rect_margins(rect_3, Interval(8))
		rects := rect_slice_v(rect_3, Ratio(0.1), 4)
		gx_depth_push_inc(0.01)
		for rect in rects do dr_rect(ui_rect_margins(rect, Interval(8)), FILL_2, STROKE, stroke = 1)
		rect_4 := ui_rect_margins(rects[len(rects) - 1], Interval(8))
		gx_depth_push_inc(0.01)
		dr_rect(rect_4, FILL_2, STROKE, stroke = 1)
		rects_0 := rect_grid_make(ui_rect_margins(rect_4, Interval(8)), { 4, 3 })
		gx_depth_push_inc(0.01)
		for rect in rects_0 do dr_rect(ui_rect_margins(rect, Interval(8)), FILL_1, STROKE, stroke = 1)
		rect_5 := ui_rect_margins(rects_0[rect_grid_index({ 4, 3 }, 1, 0)], Interval(24))
		gx_depth_push_inc(0.01)
		dr_rect(rect_5, FILL_2, STROKE, stroke = 1)
		rect_6 := rect_rotate(rect_5)
		gx_depth_push_inc(0.01)
		dr_rect(rect_6, FILL_1, STROKE, stroke = 1)
		gx_depth_push_inc(0.01)
		dr_rect(rect_mirror_x(rect_6), FILL_1, STROKE, stroke = 1)
		gx_depth_push_inc(0.01)
		dr_rect(rect_mirror_y(rect_6), FILL_1, STROKE, stroke = 1)
		rect_7 := rect_merge(rect_6, rect_mirror_y(rect_6))
		gx_depth_push_inc(0.01)
		dr_rect(rect_7, FILL_1, STROKE, stroke = 1)
		rect_8 := ui_rect_margins_variate(rect, Ratio(0.4), Ratio(0.4), Ratio(0.2), Ratio(0.2))
		gx_depth_push_inc(0.01)
		dr_rect(rect_8, FILL_1, STROKE, stroke = 1)
		rect_9 := ui_rect_fit({ size = [2]f32{ 80, 40 } * (4.0 + 4 * math.sin(time)) }, rect_8, .SCALE_DOWN)
		gx_depth_push_inc(0.01)
		dr_rect(rect_9, FILL_2, STROKE, stroke = 1) }
	return }
