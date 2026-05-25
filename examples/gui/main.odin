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

asset_manager: willow.Asset_Manager
input_manager: willow.Input_Manager
graphics_manager: willow.Graphics_Manager
window_manager: willow.Window_Manager
tick_manager: willow.Tick_Manager
stopwatch: time.Stopwatch
neon_manager: willow.Neon_Manager

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

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_manager, default_window_config(title = "GUI"))
	graphics_init(graphics_manager = &graphics_manager, asset_manager = &asset_manager, graphics_config = { window_manager = &window_manager, clear_color = NEUTRAL_BACKGROUND_1_NORMAL })
	neon_manager_init(&neon_manager, &asset_manager)
	tick_manager_init(&tick_manager, { tickrate_setting = .LIMITED_60_FPS })
	input_init(&input_manager, &window_manager, { raw_input = false })

	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		tick_asset_manager(&asset_manager)

		if tick_manager_tick(&tick_manager) {
			defer tick_manager_reset(&tick_manager)
			tick_graphics_manager(&graphics_manager)
			input_manager_tick(&input_manager)
			window_tick(&window_manager)
			DELTA :: 120
			rect: Rect = { { - 2 * DELTA, 0 }, NEON_BUTTON_SIZE }
			draw_neon_button(rect, "*Default*", appearance = .Default, shape = .Rounded, neon_manager = &neon_manager, input_manager = &input_manager, graphics_manager = &graphics_manager, window_manager = &window_manager)
			rect.position.x += DELTA
			draw_neon_button(rect, "*Primary*", appearance = .Primary, shape = .Rounded, neon_manager = &neon_manager, input_manager = &input_manager, graphics_manager = &graphics_manager, window_manager = &window_manager)
			rect.position.x += DELTA
			draw_neon_button(rect, "*Outline*", appearance = .Outline, shape = .Rounded, neon_manager = &neon_manager, input_manager = &input_manager, graphics_manager = &graphics_manager, window_manager = &window_manager)
			rect.position.x += DELTA
			draw_neon_button(rect, "*Subtle*", appearance = .Subtle, shape = .Rounded, neon_manager = &neon_manager, input_manager = &input_manager, graphics_manager = &graphics_manager, window_manager = &window_manager)
			rect.position.x += DELTA
			draw_neon_button(rect, "*Transparent*", appearance = .Transparent, shape = .Rounded, neon_manager = &neon_manager, input_manager = &input_manager, graphics_manager = &graphics_manager, window_manager = &window_manager)
		}

		free_all(context.allocator)
	}
	return }
