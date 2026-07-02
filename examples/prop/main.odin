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

	ba: Bit_Array = make_bit_array(32)
	log.info(len(ba.buffer), math.ceil_f32(f32(10_000) / 8))
	bit_array_set(&ba, 13)
	bit_array_set(&ba, 14)
	bit_array_set(&ba, 17)
	bit_array_set(&ba, 18)
	bit_array_clear(&ba, 14)
	bit_array_clear(&ba, 18)
	assert(bit_array_read(&ba, 13) == 1)
	assert(bit_array_read(&ba, 14) == 0)
	assert(bit_array_read(&ba, 17) == 1)
	assert(bit_array_read(&ba, 18) == 0)
	// log.infof(">> %b", ba.buffer[2])

	// l :: 4
	// n :: 300
	// month_days: Bit_Array(int, l, n)
	// log.info(len(month_days.buffer), math.ceil_f32(f32(l * n) / 8), n)

	// context = engine_begin_init(
	// 	engine_config=default_engine_config(
	// 		game_name="Sprites Example",
	// 		track_backing_allocations=true,
	// 		track_temp_allocations=true,
	// 		temp_allocator_cap=1000 * mem.Megabyte))

	// font: Font
	// font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	// zero_stopwatch(&stopwatch)

	// context = engine_end_init()

	// for engine_running() {
	// 	time := read_stopwatch(&stopwatch)
	// 	if engine_tick() {
	// 		rect_screen := ui_rect_screen()

	// 		// tick_scene(&scene)
	// 		// render_scene(&scene, camera_node)

	// 		{ gx_depth_scope(0.0); ui_metrics_widget() } } }

	return }
