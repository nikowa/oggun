package example_input
import "shared:willow/base"
import "shared:willow/graphics"
import "shared:willow/input"
import "shared:willow/window"
import "core:fmt"
import "core:log"

graphics_manager: graphics.Graphics_Context
input_manager: input.Input_Manager
window_manager: window.Window_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	base.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1.0 } }

@(export)
entry_point :: proc(thread_data: ^base.Thread_Data) {
	context.logger = log.create_console_logger()
	window.init(&window_manager, window.WINDOW_CONFIG_DEFAULT)
	input.init(&input_manager, &window_manager)
	input.raw_input_init()
	graphics.init(
		graphics_manager = &graphics_manager,
		graphics_config = { window_manager = &window_manager },
		title = "Willow")
	for ! graphics_manager.window_closed {
		input.process(&input_manager)
		graphics.tick(&graphics_manager)
		if input.query(&input_manager, .W, .Pressed) do fmt.println("W")
		}
	k: f32 = query().scalar
	return }
