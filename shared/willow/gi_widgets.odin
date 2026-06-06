#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

gi_metrics_widget :: proc() {
	metrics_rect := gi_rect_embed(gi_rect_margins(gi_rect_screen(), Interval(8)), { 160, 12 }, { .East, .North })
	if engine.track_backing_allocations {
		dr_text_box(fmt.aprintf("Backing Allocator: %s", aprint_size_symbolic(engine.tracking_allocator.current_memory_allocated)), metrics_rect, h_align=.LEFT, v_align=.TOP)
		metrics_rect = gi_rect_translate(metrics_rect, { 0, -14 }) }
	if engine.track_temp_allocations {
		dr_text_box(fmt.aprintf("Temp Allocator: %s", aprint_size_symbolic(engine.tracking_temp_allocator.current_memory_allocated)), metrics_rect, h_align=.RIGHT, v_align=.TOP)
		metrics_rect = gi_rect_translate(metrics_rect, { 0, -14 }) } }
