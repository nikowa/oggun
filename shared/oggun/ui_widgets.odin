#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

ui_metrics_widget :: proc() {
	metrics_rect := ui_rect_embed(ui_rect_margins(ui_rect_screen(), Interval(8)), { 320, 24 }, { .West, .South })

	bg_color := ui_get_background_color()[0]

	dr_text_box(fmt.aprintf("FPS: %d", cast(int)get_frame_rate()), metrics_rect, bg_color, h_align=.LEFT, v_align=.BOTTOM)
	metrics_rect = ui_rect_translate(metrics_rect, { 0, 14 })

	if engine.track_backing_allocations {
		dr_text_box(fmt.aprintf("Backing Allocator: %s", aprint_size_symbolic(engine.tracking_allocator.current_memory_allocated)), metrics_rect, bg_color, h_align=.LEFT, v_align=.BOTTOM)
		metrics_rect = ui_rect_translate(metrics_rect, { 0, 14 }) }

	if engine.track_temp_allocations {
		dr_text_box(fmt.aprintf("Temp Allocator: %s", aprint_size_symbolic(engine.tracking_temp_allocator.current_memory_allocated)), metrics_rect, bg_color, h_align=.LEFT, v_align=.BOTTOM)
		metrics_rect = ui_rect_translate(metrics_rect, { 0, 14 }) } }
