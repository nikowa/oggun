#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

ui_camera_2d_control :: proc(camera: ^Camera_2D, dest_rect: Rect, scale_range: [2]f32={ 0, 1 }, zoom_speed: f32=1.0, location := #caller_location) {
	sn_camera_2d_tick(camera)
	camera.rect_normalized.position = ui_pan_control(loc_id(location), dest_rect=dest_rect, src_rect=camera.rect, reset=input_query(.R, .PRESSED))
	camera.scale = math.lerp(scale_range[0], scale_range[1], ui_zoom_control(loc_id(location), dest_rect, initial_value=1, speed=1, reset=input_query(.R, .PRESSED))) }

UI_Pan_Control :: struct {
	position: [2]f32,
	panning: bool }

ui_pan_control :: proc(id: ID, dest_rect: Rect, src_rect: Rect, initial_position: [2]f32={ 0, 0 }, reset: bool=false) -> [2]f32 {
	state, ok := engine.ui_manager.pan_controls[id]
	hovered := rect_hovered(dest_rect)
	if hovered && input_query(.Mouse_Left, .PRESSED) do state.panning = true
	if input_query(.Mouse_Left, .RELEASED) do state.panning = false
	if state.panning {
		state.position -= (src_rect.size / dest_rect.size) * engine.input_manager.mouse_delta
		set_cursor(.Move) }
	if !ok || reset do state.position = initial_position
	engine.ui_manager.pan_controls[id] = state
	return state.position }

ui_scroll_control :: ui_zoom_control

UI_Zoom_Control :: f32
UI_DEFAULT_ZOOM_CONTROL: UI_Zoom_Control : math.F32_MAX

ui_zoom_control :: proc(id: ID, rect: Rect, initial_value: f32=1, range: [2]f32={ 0, 1 }, speed: f32=1.0, reset: bool=false) -> f32 {
	state, ok := engine.ui_manager.zoom_controls[id]
	hovered := rect_hovered(rect)
	if hovered do state -= speed * 0.05 * engine.input_manager.scroll_delta
	state = clamp(state, range[0], range[1])
	if !ok || reset do state = initial_value
	engine.ui_manager.zoom_controls[id] = state
	return state }

ui_button_control :: proc { ui_basic_button_control, ui_extended_button_control }

ui_extended_button_control :: proc(id: ID, rect: Rect) -> (actions: bit_set[UI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	disabled := ui_disabled_get()
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }

ui_basic_button_control :: proc(rect: Rect) -> (actions: bit_set[UI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	disabled := ui_disabled_get()
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }
