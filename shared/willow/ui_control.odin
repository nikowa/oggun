#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

ui_camera_2d_control :: proc() {
}

UI_Pan_Control :: struct {
	position: [2]f32,
	panning: bool }

ui_pan_control :: proc(rect: Rect, initial_position: [2]f32 = { 0, 0 }, reset: bool=false, location := #caller_location) -> [2]f32 {
	state, ok := engine.ui_manager.pan_controls[location]
	hovered := rect_hovered(rect)
	if hovered && input_query(.Mouse_Left, .PRESSED) do state.panning = true
	if input_query(.Mouse_Left, .RELEASED) do state.panning = false
	if state.panning {
		state.position -= (rect_screen().size / rect.size) * engine.input_manager.mouse_delta
		set_cursor(.Move) }
	if reset do state.position = initial_position
	engine.ui_manager.pan_controls[location] = state
	return state.position }

// (TODO): Rename to "ui_button_control". //
ui_control_button :: proc(rect: Rect) -> (actions: bit_set[UI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	disabled := ui_disabled_get()
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }
