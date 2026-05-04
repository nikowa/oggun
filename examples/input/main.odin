package example_input
import "shared:willow/base"
import "shared:willow/graphics_sys"
import "shared:willow/input_sys"
import "core:fmt"
import "core:log"

gx_mngr: graphics_sys.Graphics_Context
in_mngr: input_sys.Input_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	base.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1.0 } }

@(export)
entry_point :: proc(thread_data: ^base.Thread_Data) {
	context.logger = log.create_console_logger()
	input_sys.init(&in_mngr, gx_mngr.window)
	input_sys.raw_input_init()
	graphics_sys.init(gx_mngr = &gx_mngr, in_mngr = &in_mngr, config = graphics_sys.DEFAULT_GRAPHICS_CONFIG, title = "Willow")
	for ! gx_mngr.window_closed {
		input_sys.process(&in_mngr)
		graphics_sys.tick(&gx_mngr)
		if input_sys.query(&in_mngr, .W, .Pressed) do fmt.println("W")
		}
	k: f32 = query().scalar
	return }
