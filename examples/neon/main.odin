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
		"Neon Example",
		asset_config = default_asset_manager_config(watch = false),
		graphics_config = default_graphics_config(clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK),
		tick_config = default_tick_manager_config(tickrate_setting = .LIMITED_144_FPS),
		input_config = default_input_config(raw_input = false))
	tgui_set_theme(tgui_theme_ms_light)

	zero_stopwatch(&stopwatch)

	context = engine_loop_context()

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			ys: [2]f32 = { -24, 24 }
			ds: [2]bool = { true, false }
			for y, i in ys {
				disabled := ds[i]
				DELTA :: 120
				rect: Rect = { { - 2 * DELTA, y }, TGUI_BUTTON_SIZE_SMALL }
				if .PRESS in tgui_button(rect, "*Default*", appearance = .DEFAULT, shape = .ROUNDED, disabled = disabled) do log.warn("Press")
				rect.position.x += DELTA
				tgui_draw_button(rect, "*Primary*", appearance = .PRIMARY, shape = .ROUNDED, disabled = disabled)
				rect.position.x += DELTA
				tgui_draw_button(rect, "*Outline*", appearance = .OUTLINE, shape = .ROUNDED, disabled = disabled)
				rect.position.x += DELTA
				tgui_draw_button(rect, "*Subtle*", appearance = .SUBTLE, shape = .ROUNDED, disabled = disabled)
				rect.position.x += DELTA
				tgui_draw_button(rect, "*Transp*", appearance = .TRANSPARENT, shape = .ROUNDED, disabled = disabled) } } }
	return }
