#+feature using-stmt
package example_gui
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
		"GUI Example",
		asset_config = default_asset_manager_config(watch = false),
		graphics_config = default_graphics_config(clear_color = BLACK),
		tick_config = default_tick_manager_config(tickrate_setting = .LIMITED_144_FPS),
		input_config = default_input_config(raw_input = false))
	set_clear_color(WHITE)

	zero_stopwatch(&stopwatch)

	context = engine_loop_context()

	screen_rect := gi_rect_screen()
	for engine_running() do if engine_tick() {
		time := read_stopwatch(&stopwatch)
		rect := gi_rect_margins(screen_rect, Ratio(0.05))
		FILL_1 :: COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT
		FILL_2 :: COLOR_NEUTRAL_BACKGROUND_1_PRESSED_LIGHT
		STROKE :: COLOR_NEUTRAL_FOREGROUND_1_LIGHT
		dr_rect(screen_rect, FILL_1, STROKE, stroke = 1, depth = 0.99)
		dr_rect(rect, FILL_2, STROKE, stroke = 1, depth = 0.98)
		rect_0 := gi_rect_embed(rect, { 1000, 800 }, { .West, .South })
		dr_rect(rect_0, FILL_1, STROKE, stroke = 1, depth = 0.97)
		rect_1, rect_2 := gi_rect_split_h(gi_rect_margins(rect_0, Interval(16)), Interval(120), Interval(16))
		dr_rect(rect_1, FILL_2, STROKE, stroke = 1, depth = 0.96)
		dr_rect(rect_2, FILL_2, STROKE, stroke = 1, depth = 0.96)
		rect_3 := gi_rect_margins_variate(rect_2, north = Ratio(0.1), east = Ratio(0.05))
		dr_rect(rect_3, FILL_1, STROKE, stroke = 1, depth = 0.95)
		rect_3 = gi_rect_margins(rect_3, Interval(8))
		rects := gi_rect_slice_v(rect_3, Ratio(0.1), 4)
		for rect in rects do dr_rect(gi_rect_margins(rect, Interval(8)), FILL_2, STROKE, stroke = 1, depth = 0.94)
		rect_4 := gi_rect_margins(rects[len(rects) - 1], Interval(8))
		dr_rect(rect_4, FILL_2, STROKE, stroke = 1, depth = 0.93)
		rects_0 := gi_rect_grid_make(gi_rect_margins(rect_4, Interval(8)), { 4, 3 })
		for rect in rects_0 do dr_rect(gi_rect_margins(rect, Interval(8)), FILL_1, STROKE, stroke = 1, depth = 0.92)
		rect_5 := gi_rect_margins(rects_0[gi_rect_grid_index({ 4, 3 }, 1, 0)], Interval(24))
		dr_rect(rect_5, FILL_2, STROKE, stroke = 1, depth = 0.91)
		rect_6 := gi_rect_rotate(rect_5)
		dr_rect(rect_6, FILL_1, STROKE, stroke = 1, depth = 0.90)
		dr_rect(gi_rect_mirror_x(rect_6), FILL_1, STROKE, stroke = 1, depth = 0.89)
		dr_rect(gi_rect_mirror_y(rect_6), FILL_1, STROKE, stroke = 1, depth = 0.89)
		rect_7 := gi_rect_merge(rect_6, gi_rect_mirror_y(rect_6))
		dr_rect(rect_7, FILL_1, STROKE, stroke = 1, depth = 0.88)
		rect_8 := gi_rect_margins_variate(rect, Ratio(0.4), Ratio(0.4), Ratio(0.2), Ratio(0.2))
		dr_rect(rect_8, FILL_1, STROKE, stroke = 1, depth = 0.87)
		rect_9 := gi_rect_fit({ size = [2]f32{ 80, 40 } * (4.0 + 4 * math.sin(time)) }, rect_8, .SCALE_DOWN)
		dr_rect(rect_9, FILL_2, STROKE, stroke = 1, depth = 0.86) }
	return }
