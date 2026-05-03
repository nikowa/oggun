#+feature dynamic-literals
#+feature using-stmt
package input
import rt "base:runtime"
import glfw "vendor:glfw"
import fmt "core:fmt"
import la "core:math/linalg"
import str "core:strings"


Input_Context :: struct {
// 	mouse_pos:         [2]f32,
// 	cursor:            [2]f32,
	mouse_delta: [2]f32,
	cursor_delta: [2]f32,
	scroll_delta: f32,
	keyboard_buttons_pressed: bit_set[Key],
	old_keyboard_buttons_pressed: bit_set[Key],
	keyboard_buttons_switched: bit_set[Key],
	mouse_buttons_pressed: bit_set[Mouse_Button],
	old_mouse_buttons_pressed: bit_set[Mouse_Button],
	mouse_buttons_switched: bit_set[Mouse_Button],
// 	keymap:            map[i32]Key,
// 	focused:           bool
}

Mouse_Button :: enum { MOUSE_LEFT, MOUSE_RIGHT }

Key :: enum { A, D, W, S, E, Q, J, LEFT, RIGHT, UP, DOWN, ENTER, ESCAPE, Z }

// Input_Tick_Data :: struct {
// 	input: ^Locked_Struct(Input) }
// input_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag="job")
input_tick :: proc(input: ^Input_Context) {
	input.mouse_delta = { 0, 0 }
	input.cursor_delta = { 0, 0 }
	input.scroll_delta = 0
// 	// TODO: I think we should use WaitEvents instead. //
// 	// glfw.WaitEvents()
	glfw.PollEvents()
	input.keyboard_buttons_switched = input.keyboard_buttons_pressed ~ input.old_keyboard_buttons_pressed
	input.old_keyboard_buttons_pressed = input.keyboard_buttons_pressed
	input.mouse_buttons_switched = input.mouse_buttons_pressed ~ input.old_mouse_buttons_pressed
	input.old_mouse_buttons_pressed = input.mouse_buttons_pressed }

// key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
// 	input: ^Locked_Struct(Input) = cast(^Locked_Struct(Input))glfw.GetWindowUserPointer(window)
// 	// TODO: Is this necessary?
// 	// lock_guard(&input.lock)
// 	// TODO: How do we do input handling? Does the input system just write to the input buffers and then the other systems read from them? I think so. //
// 	// switch key {
// 	// case '1': if action==glfw.PRESS {
// 	// 	if .MODELS in draw_mask { draw_mask-={.MODELS} } else { draw_mask+={.MODELS} } }
// 	// case '2': if action==glfw.PRESS {
// 	// 	if .EFFECTS in draw_mask { draw_mask-={.EFFECTS} } else { draw_mask+={.EFFECTS} } } }
// 	// if (key==glfw.KEY_ESCAPE)&&(action==glfw.PRESS) {
// 	// 	running=false }
// 	// if (key==glfw.KEY_ENTER)&&(action==glfw.PRESS) {
// 	// 	screen=.GAME
// 	// 	prompts-={.START,.EXIT,}
// 	// 	prompts+={.RESPAWN,.SWIM_FORWARD} }
// 	// if (key=='R')&&(action==glfw.PRESS) {
// 	// 	init_physics() }
// 	// if key==glfw.KEY_LEFT_SHIFT {
// 	// 	if action==glfw.PRESS do camera.speed=4.0
// 	// 	else if action==glfw.RELEASE do camera.speed=1.0 }
// 	// if (key=='E')&&(action==glfw.PRESS)&&(surfer_is_near_surf()) {
// 	// 	if surfer_state==.SWIMMING {
// 	// 		surfer_state=.PADDLING
// 	// 		prompts-={.GET_ON_THE_SURF}
// 	// 		} }
// 	// if (key=='J')&&(action==glfw.PRESS)&&(mods&glfw.MOD_CONTROL==glfw.MOD_CONTROL)&&(mods&glfw.MOD_SHIFT==glfw.MOD_SHIFT) {
// 	// 	recompile_shaders() }
// 	if key in input.keymap {
// 		switch(action) {
// 		case glfw.PRESS:   input.keyboard_buttons_pressed += { input.keymap[key] }
// 		case glfw.RELEASE: input.keyboard_buttons_pressed -= { input.keymap[key] } } } }


// scroll_callback :: proc "c" (window: glfw.WindowHandle, dx, dy: f64) {
// 	input: ^Locked_Struct(Input) = cast(^Locked_Struct(Input))glfw.GetWindowUserPointer(window)
// 	// lock_guard(&input.lock)
// 	input.scroll_delta += cast(f32)dy }


// focus_callback :: proc "c" (window: glfw.WindowHandle, focused: i32) {
// 	input: ^Locked_Struct(Input) = cast(^Locked_Struct(Input))glfw.GetWindowUserPointer(window)
// 	// lock_guard(&input.lock)
// 	input.focused = true }


// cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
// 	input: ^Locked_Struct(Input) = cast(^Locked_Struct(Input))glfw.GetWindowUserPointer(window)
// 	// lock_guard(&input.lock)
// 	@(static) called: bool = false
// 	_, height: i32 = glfw.GetWindowSize(window)
// 	mouse_pos := [2]f32{ cast(f32)x, cast(f32)height - cast(f32)y }
// 	if called { input.mouse_delta += mouse_pos - input.mouse_pos }
// 	if (abs(input.mouse_delta.x) > 100) && (abs(input.mouse_delta.y) > 100) { input.mouse_delta = { 0, 0 } }
// 	input.mouse_pos = mouse_pos
// 	if input.focused || true {
// 		input.cursor += input.mouse_delta * 0.3
// 		input.cursor_delta = input.mouse_delta }
// 	called = true }


// mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
// 	input: ^Locked_Struct(Input) = cast(^Locked_Struct(Input))glfw.GetWindowUserPointer(window)
// 	// lock_guard(&input.lock)
// 	switch button {
// 	case glfw.MOUSE_BUTTON_LEFT:
// 		if action == glfw.PRESS {
// 			input.mouse_buttons_pressed += { Mouse_Button.MOUSE_LEFT } }
// 		if action == glfw.RELEASE {
// 			input.mouse_buttons_pressed -= { Mouse_Button.MOUSE_LEFT } }
// 	case glfw.MOUSE_BUTTON_RIGHT:
// 		if action == glfw.PRESS {
// 			input.mouse_buttons_pressed += { Mouse_Button.MOUSE_RIGHT } }
// 		if action == glfw.RELEASE {
// 			input.mouse_buttons_pressed -= { Mouse_Button.MOUSE_RIGHT } } }
// 	if action == glfw.PRESS || action == glfw.RELEASE {
// 		input.mouse_buttons_switched = input.mouse_buttons_pressed ~ input.old_mouse_buttons_pressed
// 		input.old_mouse_buttons_pressed = input.mouse_buttons_pressed } }


// window_refresh_callback :: proc "c" (window: glfw.WindowHandle) { }


// drop_callback :: proc "c" (window: glfw.WindowHandle, count: i32, paths: [^]cstring) { }


// mouse_was_pressed :: proc(input: ^Input, button: Mouse_Button) -> bool {
// 	return (button in input.mouse_buttons_pressed) && (button in input.mouse_buttons_switched) }


// mouse_was_released :: proc(input: ^Input, button: Mouse_Button) -> bool {
// 	return (button in input.mouse_buttons_pressed == false) && (button in input.mouse_buttons_switched) }


// key_was_pressed :: proc(input: ^Input, key: Key) -> bool {
// 	return (key in input.keyboard_buttons_pressed) && (key in input.keyboard_buttons_switched) }


// key_was_released :: proc(input: ^Input, key: Key) -> bool {
// 	return (key in input.keyboard_buttons_pressed == false) && (key in input.keyboard_buttons_switched) }


input_init :: proc(input: ^Input_Context) {
// 	input.keymap = make(map[i32]Key)
// 	input.keymap['A']             = Key.A
// 	input.keymap['D']             = Key.D
// 	input.keymap['W']             = Key.W
// 	input.keymap['S']             = Key.S
// 	input.keymap['E']             = Key.E
// 	input.keymap['Q']             = Key.Q
// 	input.keymap['J']             = Key.J
// 	input.keymap[glfw.KEY_LEFT]   = Key.LEFT
// 	input.keymap[glfw.KEY_RIGHT]  = Key.RIGHT
// 	input.keymap[glfw.KEY_UP]     = Key.UP
// 	input.keymap[glfw.KEY_DOWN]   = Key.DOWN
// 	input.keymap[glfw.KEY_ENTER]  = Key.ENTER
// 	input.keymap[glfw.KEY_ESCAPE] = Key.ESCAPE
// 	input.keymap['Z']             = Key.Z
// 	glfw.SetWindowUserPointer(window, input)
// 	if glfw.JoystickPresent(glfw.JOYSTICK_1) && glfw.JoystickIsGamepad(glfw.JOYSTICK_1) {}
}

