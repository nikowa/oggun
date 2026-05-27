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
	mem.arena_init(&arena, make([]u8, 100 * mem.Megabyte))
	context.temp_allocator = mem.arena_allocator(&arena)

	engine_init(
		"GUI Example",
		graphics_config = default_graphics_config(clear_color = NEUTRAL_BACKGROUND_1_NORMAL),
		tick_config = default_tick_manager_config(tickrate_setting = .LIMITED_144_FPS),
		input_config = default_input_config(raw_input = false))

	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			ys: [2]f32 = { -24, 24 }
			ds: [2]bool = { true, false }
			for y, i in ys {
				disabled := ds[i]
				DELTA :: 120
				rect: Rect = { { - 2 * DELTA, y }, NEON_BUTTON_SIZE_SMALL }
				draw_neon_button(rect, "*Default*", appearance = .Default, shape = .Rounded, disabled = disabled)
				rect.position.x += DELTA
				draw_neon_button(rect, "*Primary*", appearance = .Primary, shape = .Rounded, disabled = disabled)
				rect.position.x += DELTA
				draw_neon_button(rect, "*Outline*", appearance = .Outline, shape = .Rounded, disabled = disabled)
				rect.position.x += DELTA
				draw_neon_button(rect, "*Subtle*", appearance = .Subtle, shape = .Rounded, disabled = disabled)
				rect.position.x += DELTA
				draw_neon_button(rect, "*Transp*", appearance = .Transparent, shape = .Rounded, disabled = disabled) } }
		free_all(context.allocator) }
	return }
