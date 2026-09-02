#+feature using-stmt
package example_input
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
	context = og.engine_begin_init(
		engine_config=og.default_engine_config(
			game_name="Sprites Example",
			track_backing_allocations=true,
			track_temp_allocations=true,
			temp_allocator_cap=1000 * mem.Megabyte))

	texture: og.Texture
	og.texture_init(&texture, { url = "image:kitten-2.png" })
	og.asset_translate(&texture, .RAM, .Source)
	og.asset_make(&texture, .VRAM)
	og.asset_translate(&texture, .VRAM, .RAM)

	font: og.Font
	og.font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	og.zero_stopwatch(&stopwatch)

	context = og.engine_end_init()

	for og.engine_running() {
		time := og.read_stopwatch(&stopwatch)
		if og.engine_tick() {
			og.gx_depth_scope(0.5)
			rect_screen := og.ui_rect_screen()

			texture_rect: og.Rect = { og.ui_rect_lerp(rect_screen, { 0.25, 0.75 }), { 200, 200 } }
			og.dr_image(&texture, texture_rect, integer=false)

			rects_rect: og.Rect = { og.ui_rect_lerp(rect_screen, { 0.25, 0.25 }), { 200, 200 } }
			rects_rects := og.ui_rect_grid(rects_rect, { 2, 2 })
			og.dr_rect(rects_rects[0], og.RED)
			og.dr_rect(rects_rects[1], og.GREEN)
			og.dr_rect(rects_rects[2], og.BLUE)
			og.dr_rect(rects_rects[3], og.WHITE)

			text_rect: og.Rect = { og.ui_rect_lerp(rect_screen, { 0.75, 0.25 }), { 200, 200 } }
			og.dr_text_box(og.LUMBAR, text_rect, h_align=.JUSTIFY, v_align=.TOP, overflow=.CLIP)

			line_rect: og.Rect = { og.ui_rect_lerp(rect_screen, { 0.75, 0.75 }), { 200, 200 } }
			line_rect_corners := og.rect_corners(line_rect)
			og.dr_line({ line_rect_corners[0], line_rect_corners[2] }, og.WHITE)
			og.dr_arc(line_rect_corners[3], line_rect.size.x, { math.to_radians(f32(90)), math.to_radians(f32(180)) }, og.WHITE) } }

	return }
