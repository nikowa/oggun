#+feature using-stmt
package example_input
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

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

stopwatch: time.Stopwatch

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

	context = engine_begin_init(
		engine_config=default_engine_config(
			game_name="Sprites Example",
			track_backing_allocations=true,
			track_temp_allocations=true,
			temp_allocator_cap=1000 * mem.Megabyte))

	font: Font
	font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	zero_stopwatch(&stopwatch)

	context = engine_end_init()

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			rect_screen := rect_screen()

			tick_scene(&scene)
			render_scene(&scene, camera_node)

			{ gx_depth_scope(0.0); ui_metrics_widget() } } }
	return }
