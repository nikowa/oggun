#+feature dynamic-literals
#+feature using-stmt
package willow
import "core:log"
import "base:runtime"
import "vendor:glfw"
import "core:container/bit_array"

Input_Config :: struct #all_or_none {
	raw_input: bool }

Input_Manager :: struct {
	using input_config: Input_Config,
	mouse_position: [2]f32,
	mouse_delta: [2]f32,
	scroll_delta: f32,
	focused: bool,
	using _private: Input_Manager_Private }

@(private="file")
Input_Manager_Private :: struct {
	inputs_pressed: bit_array.Bit_Array,
	old_inputs_pressed: bit_array.Bit_Array,
	inputs_switched: bit_array.Bit_Array,
	raw_input_manager: ^Raw_Input_Manager }

Input :: enum uint {
	None = 0,
	Space = 32,
	Apostrophe = 39,
	Comma = 44,
	Minus = 45,
	Period = 46,
	Slash = 47,
	Num_0 = 48,
	Num_1 = 49,
	Num_2 = 50,
	Num_3 = 51,
	Num_4 = 52,
	Num_5 = 53,
	Num_6 = 54,
	Num_7 = 55,
	Num_8 = 56,
	Num_9 = 57,
	Semicolon = 59,
	Equal = 61,
	A = 65,
	B = 66,
	C = 67,
	D = 68,
	E = 69,
	F = 70,
	G = 71,
	H = 72,
	I = 73,
	J = 74,
	K = 75,
	L = 76,
	M = 77,
	N = 78,
	O = 79,
	P = 80,
	Q = 81,
	R = 82,
	S = 83,
	T = 84,
	U = 85,
	V = 86,
	W = 87,
	X = 88,
	Y = 89,
	Z = 90,
	Left_Bracket = 91,
	Backslash = 92,
	Right_Bracket = 93,
	Backtick = 96,
	Escape = 256,
	Enter = 257,
	Tab = 258,
	Backspace = 259,
	Insert = 260,
	Delete = 261,
	Right = 262,
	Left = 263,
	Down = 264,
	Up = 265,
	Page_Up = 266,
	Page_Down = 267,
	Home = 268,
	End = 269,
	Caps_Lock = 280,
	Scroll_Lock = 281,
	Num_Lock = 282,
	Print_Screen = 283,
	Pause = 284,
	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,
	F13 = 302,
	F14 = 303,
	F15 = 304,
	F16 = 305,
	F17 = 306,
	F18 = 307,
	F19 = 308,
	F20 = 309,
	F21 = 310,
	F22 = 311,
	F23 = 312,
	F24 = 313,
	F25 = 314,
	Numpad_0 = 320,
	Numpad_1 = 321,
	Numpad_2 = 322,
	Numpad_3 = 323,
	Numpad_4 = 324,
	Numpad_5 = 325,
	Numpad_6 = 326,
	Numpad_7 = 327,
	Numpad_8 = 328,
	Numpad_9 = 329,
	Numpad_Decimal = 330,
	Numpad_Divide = 331,
	Numpad_Multiply = 332,
	Numpad_Subtract = 333,
	Numpad_Add = 334,
	Numpad_Enter = 335,
	Numpad_Equal = 336,
	Left_Shift = 340,
	Left_Control = 341,
	Left_Alt = 342,
	Left_Super = 343,
	Mouse_Left = INDEX_MOUSE_LEFT,
	Mouse_Right = INDEX_MOUSE_RIGHT }

Action :: enum {
	Press,
	Release }

Query_Variant :: enum {
	Up,
	Down,
	Pressed,
	Released }

INDEX_KEY_MIN :: 32
INDEX_KEY_MAX :: 348
INDEX_MOUSE_LEFT :: INDEX_KEY_MAX + 1
INDEX_MOUSE_RIGHT :: INDEX_MOUSE_LEFT + 1
INDEX_MOUSE_MAX :: INDEX_MOUSE_RIGHT

@(private="file")
init_bits_array :: proc(array: ^bit_array.Bit_Array) {
	bit_array.init(array, INDEX_KEY_MIN, INDEX_MOUSE_MAX + 1) }

@(private="file")
bits_array_xor :: proc(array_result, array_a, array_b: ^bit_array.Bit_Array) {
	for index in 0 ..= INDEX_MOUSE_MAX {
		a := bit_array.get(array_a, index)
		b := bit_array.get(array_b, index)
		bit_array.set(array_result, index, a ~ b) } }

@(private="file")
bits_array_copy :: proc(array_dst, array_src: ^bit_array.Bit_Array) {
	for index in 0 ..= INDEX_MOUSE_MAX {
		bit_array.set(array_dst, index, bit_array.get(array_src, index)) } }
	// array_dst.bias = array_src.bias
	// array_dst.length = array_src.length
	// array_dst.free_pointer = array_src.free_pointer
	// copy_slice(array_dst.bits[:], array_src.bits[:])
	// for index in 0 ..= INDEX_MOUSE_MAX {
	// 	assert(bit_array.get(array_dst, index) == bit_array.get(array_src, index)) } }

process :: proc(input_manager: ^Input_Manager) {
	input_manager.mouse_delta = { 0, 0 }
	input_manager.scroll_delta = 0
	bits_array_xor(&input_manager.inputs_switched, &input_manager.inputs_pressed, &input_manager.old_inputs_pressed)
	bits_array_copy(&input_manager.old_inputs_pressed, &input_manager.inputs_pressed) }

trigger :: proc(input_manager: ^Input_Manager, input: Input, action: Action) {
	switch action {
	case .Press:
		bit_array.set(&input_manager.inputs_pressed, cast(uint)input, true)
	case .Release:
		bit_array.set(&input_manager.inputs_pressed, cast(uint)input, false) } }

@(private="file")
glfw_key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()
	im: ^Input_Manager = cast(^Input_Manager)glfw.GetWindowUserPointer(window)
	assert(im != nil)
	trigger(im, cast(Input)key, action == glfw.RELEASE ? .Release : .Press) }

// @(private="file")
// scroll_callback :: proc "c" (window: glfw.WindowHandle, dx, dy: f64) {
// 	input_manager: ^Input_Manager = cast(^Input_Manager)glfw.GetWindowUserPointer(window)
// 	input_manager.scroll_delta += cast(f32)dy }

// @(private="file")
// focus_callback :: proc "c" (window: glfw.WindowHandle, focused: i32) {
// 	input_manager: ^Input_Manager = cast(^Input_Manager)glfw.GetWindowUserPointer(window)
// 	input_manager.focused = true }

event_mouse_position :: proc(input_manager: ^Input_Manager, position: [2]f32) {
}

// @(private="file")
// cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
// 	context = runtime.default_context()
// 	input_manager: ^Input_Manager = cast(^Input_Manager)glfw.GetWindowUserPointer(window)
// 	@(static) called: bool = false
// 	_, height: i32 = glfw.GetWindowSize(window)
// 	mouse_position := [2]f32{ cast(f32)x, cast(f32)height - cast(f32)y }
// 	if called do input_manager.mouse_delta += mouse_position - input_manager.mouse_position
// 	// if (abs(input_manager.mouse_delta.x) > 100) && (abs(input_manager.mouse_delta.y) > 100) { input_manager.mouse_delta = { 0, 0 } }
// 	input_manager.mouse_position = mouse_position
// 	called = true }

// @(private="file")
// mouse_button_callback :: proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
// 	context = runtime.default_context()
// 	input_manager: ^Input_Manager = cast(^Input_Manager)glfw.GetWindowUserPointer(window)
// 	index: uint = 0
// 	switch button {
// 	case glfw.MOUSE_BUTTON_LEFT:  index = INDEX_MOUSE_LEFT
// 	case glfw.MOUSE_BUTTON_RIGHT: index = INDEX_MOUSE_RIGHT }
// 	switch action {
// 	case glfw.PRESS:   bit_array.set(&input_manager.inputs_pressed, index, true)
// 	case glfw.RELEASE: bit_array.set(&input_manager.inputs_pressed, index, false) } }

// window_refresh_callback :: proc "c" (window: glfw.WindowHandle) { }

// drop_callback :: proc "c" (window: glfw.WindowHandle, count: i32, paths: [^]cstring) { }


input_query :: proc(input_manager: ^Input_Manager, input: Input, $variant: Query_Variant) -> bool {
	input_down :: proc(input_manager: ^Input_Manager, input: Input) -> bool {
		return bit_array.get(&input_manager.inputs_pressed, cast(uint)input) }
	input_up :: proc(input_manager: ^Input_Manager, input: Input) -> bool {
		return !input_down(input_manager, input) }
	input_switched :: proc(input_manager: ^Input_Manager, input: Input) -> bool {
		return bit_array.get(&input_manager.inputs_switched, cast(uint)input) }
	input_pressed :: proc(input_manager: ^Input_Manager, input: Input) -> bool {
		return bit_array.get(&input_manager.inputs_pressed, cast(uint)input) && bit_array.get(&input_manager.inputs_switched, cast(uint)input) }
	input_released :: proc(input_manager: ^Input_Manager, input: Input) -> bool {
		return (! bit_array.get(&input_manager.inputs_pressed, cast(uint)input)) && bit_array.get(&input_manager.inputs_switched, cast(uint)input) }
	switch variant {
	case .Up:       return input_up(input_manager, input)
	case .Down:     return input_down(input_manager, input)
	case .Pressed:  return input_pressed(input_manager, input)
	case .Released: return input_released(input_manager, input) }
	return false }

// input_state :: proc(input_manager: ^Input_Manager, input: Input) -> (state: Input_State, just_switched: bool) #optional_ok {
// 	state = input_down(input_manager, input) ? .Down : .Up
// 	just_switched = input_switched(input_manager, input)
// 	return state, just_switched }

input_init :: proc(input_manager: ^Input_Manager, window_manager: ^Window_Manager, input_config: Input_Config) {
	input_manager.input_config = input_config
	init_bits_array(&input_manager.inputs_pressed)
	init_bits_array(&input_manager.old_inputs_pressed)
	init_bits_array(&input_manager.inputs_switched)
	switch window_manager.backend {
	case .GLFW:
		glfw.SetWindowUserPointer(cast(glfw.WindowHandle)window_manager.handle, input_manager)
		// glfw.SetWindowFocusCallback(draw.window, focus_callback)
		log.info("Setting key callback")
		glfw.SetKeyCallback(cast(glfw.WindowHandle)window_manager.handle, glfw_key_callback)
		// glfw.SetScrollCallback(draw.window, scroll_callback)
		// glfw.SetCursorPosCallback(draw.window, cursor_pos_callback)
		// glfw.SetMouseButtonCallback(draw.window, mouse_button_callback)
		// glfw.SetWindowRefreshCallback(draw.window, window_refresh_callback)
		// glfw.SetWindowSizeCallback(draw.window, resolution_callback)
		// glfw.SetDropCallback(draw.window, drop_callback)
		// glfw.SetInputMode(draw.window, glfw.CURSOR, glfw.CURSOR_DISABLED)
		// glfw.SetInputMode(draw.window, glfw.RAW_MOUSE_MOTION, 0)
	case .Win32: }
	if input_config.raw_input {
		input_manager.raw_input_manager = new(Raw_Input_Manager)
		raw_input_init(input_manager.raw_input_manager, input_manager, window_manager) }
// 	if glfw.JoystickPresent(glfw.JOYSTICK_1) && glfw.JoystickIsGamepad(glfw.JOYSTICK_1) {}
}
