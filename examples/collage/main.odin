#+feature using-stmt
package example_collage
import og "shared:oggun"
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
	context = og.engine_begin_init(
		engine_config=og.default_engine_config(
			game_name="Sprites Example",
			track_backing_allocations=true,
			track_temp_allocations=true,
			temp_allocator_cap=1000 * mem.Megabyte))

	mountain_image: og.Image_Asset
	og.init_image(&mountain_image, { url = "image:mountain.png" })
	assert(og.am_commands(og.Image_Asset, &mountain_image.asset, { .Import, .Load, .Upload }))

	font: og.Font
	og.font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	og.zero_stopwatch(&stopwatch)

	context = og.engine_end_init()

	for og.engine_running() {
		time := og.read_stopwatch(&stopwatch)
		if og.engine_tick() {

			// Calculate rects //
			rect_screen := og.ui_rect_screen()
			card_rect := og.ui_rect_margins_variate(rect_screen,
				west=og.Ratio(0.3), east=og.Ratio(0.3),
				north=og.Ratio(0.1), south=og.Ratio(0.1))

			// Create images //
			// 1. Create image of size "card_rect.size"
			// 2. Fill with black.
			// 3. Draw white circle.
			// 4. Blend shader.

			og.dr_rect(rect_screen, 0xE0A887FF)

			{ og.gx_depth_scope(0.5); og.dr_image(&mountain_image, card_rect, integer=false) }

			{ og.gx_depth_scope(0.0); og.ui_metrics_widget() } } }
	return }
