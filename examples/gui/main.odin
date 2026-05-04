package example_input
import "shared:willow/base"
import "shared:willow/graphics"
import "shared:willow/input"
import "shared:willow/window"
import "shared:willow/gui"
import "shared:willow/container/rect"
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
	graphics.init(
		graphics_manager = &graphics_manager,
		graphics_config = { window_manager = &window_manager },
		title = "Willow")
	for ! graphics_manager.window_closed {
		graphics.tick(&graphics_manager)
		graphics.render_rect(&graphics_manager, rect.Rect{ { 0, 0 }, { 400, 20 } }, graphics.RED, 0.0) }
	k: f32 = query().scalar
	return }
