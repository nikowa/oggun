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

	// Calculate rects //
	rect_screen := og.ui_rect_screen()
	card_rect := og.ui_rect_margins_variate(rect_screen,
		west=og.Ratio(0.3), east=og.Ratio(0.3),
		north=og.Ratio(0.1), south=og.Ratio(0.1))

	// Create images //
	mountain_texture: og.Texture
	og.texture_init(&mountain_texture, { url = "image:mountain.png" })
	assert(og.am_commands(og.Texture, &mountain_texture.asset, { .Import, .Deserialize, .Upload }))

	card_texture: og.Texture = { width = cast(int)card_rect.size.x, height = cast(int)card_rect.size.y }
	og.texture_init(&card_texture, {}, { .Allocate_Empty, .Allocate_Render_Buffer })

	font: og.Font
	og.font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	og.zero_stopwatch(&stopwatch)

	context = og.engine_end_init()

	for og.engine_running() {
		time := og.read_stopwatch(&stopwatch)
		if og.engine_tick() {

			// Create images //
			// 1. Create image of size "card_rect.size"
			// 2. Fill with black.
			// 3. Draw white circle.
			// 4. Blend shader.

			og.dr_rect(rect_screen, 0xE0A887FF)
			// og.dr_rect(card_rect, 0xFF0000FF, target_texture=&card_texture)
			// og.dr_image(&card_texture, card_rect)

			{ og.gx_depth_scope(0.5); og.dr_image(&mountain_texture, card_rect, integer=false) }

			{ og.gx_depth_scope(0.0); og.ui_metrics_widget() } } }
	return }
