#+feature using-stmt
package example_input
import "shared:oggun"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:mem"

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1 } }

key_margins :: proc(rect_in: oggun.Rect) -> (rect_out: oggun.Rect) {
	using oggun
	return ui_rect_extend_variate(rect_in, Interval(-7), Interval(-7), Interval(-7), Interval(-2)) }

@(export)
make_rects :: proc(keyboard_rect: oggun.Rect, allocator: runtime.Allocator) -> []oggun.Rect {
	using oggun

	rects := make_dynamic_array([dynamic]Rect, allocator = context.temp_allocator)

	rect_group_0, rect_group := ui_rect_split_v(keyboard_rect, Ratio(0.187), Interval(20))
	DIV_H1 :: 0.672
	DIV_H2 :: 0.434
	rect_group_1, _rect := ui_rect_split_h(rect_group, Ratio(DIV_H1), Interval(10))
	rect_group_2, rect_group_3 := ui_rect_split_h(_rect, Ratio(DIV_H2), Interval(10))

	// Esc
	rect_group_0_0: Rect
	rect_group_0_0, _rect = ui_rect_split_h(rect_group_0, Ratio(0.065), Interval(40))
	append(&rects, rect_group_0_0)

	// F1 - F4
	rect_group_0_1: Rect
	rect_group_0_1, _rect = ui_rect_split_h(_rect, Ratio(0.207), Interval(20))
	ui_rect_grid(rect_group_0_1, { 4, 1 }, &rects)

	// F5 - F8
	rect_group_0_2: Rect
	rect_group_0_2, _rect = ui_rect_split_h(_rect, Ratio(0.266), Interval(20))
	ui_rect_grid(rect_group_0_2, { 4, 1 }, &rects)

	// F9 - F12
	rect_group_0_3: Rect
	rect_group_0_3, _rect = ui_rect_split_h(_rect, Ratio(0.36), Interval(10))
	ui_rect_grid(rect_group_0_3, { 4, 1 }, &rects)

	// PrtScr ScrLk Pause
	rect_group_0_4: Rect
	rect_group_0_4, _rect = ui_rect_split_h(_rect, Ratio(0.43), Interval(10))
	ui_rect_grid(rect_group_0_4, { 3, 1 }, &rects)

	// Del - Home
	rect_group_0_5 := _rect
	ui_rect_grid(rect_group_0_5, { 4, 1 }, &rects)

	lines := ui_rect_grid_make(rect_group_1, { 1, 5 }, allocator)

	KEY_WIDTH :: 39.8

	// ~ - <-
	rect_group_1_0 := lines[4]
	ui_rect_slice_h(rect_group_1_0, Interval(KEY_WIDTH), 14, &rects)

	// Tab - \
	rect_group_1_1 := lines[3]
	_rect, rect_group_1_1 = ui_rect_split_h(rect_group_1_1, Ratio(0.099), Interval(0))
	append(&rects, _rect)
	ui_rect_slice_h(rect_group_1_1, Interval(KEY_WIDTH), 13, &rects)

	// CapsLock - Enter
	rect_group_1_2 := lines[2]
	_rect, rect_group_1_2 = ui_rect_split_h(rect_group_1_2, Ratio(0.116), Interval(0))
	append(&rects, _rect)
	ui_rect_slice_h(rect_group_1_2, Interval(KEY_WIDTH), 12, &rects)

	// LShift - RShift
	rect_group_1_3 := lines[1]
	_rect, rect_group_1_3 = ui_rect_split_h(rect_group_1_3, Ratio(0.150), Interval(0))
	append(&rects, _rect)
	ui_rect_slice_h(rect_group_1_3, Interval(KEY_WIDTH), 11, &rects)

	// LCtrl - RCtrl
	rect_group_1_4 := lines[0]
	ui_rect_grid(rect_group_1_4, { 12, 1 }, &rects)
	ui_rects_merge_range(&rects, { 76, 81 })

	lines = ui_rect_grid_make(rect_group_2, { 1, 5 }, allocator)

	// Ins - PgUp
	rect_group_2_0 := lines[4]
	ui_rect_grid(rect_group_2_0, { 3, 1 }, &rects)

	// Del - PgDown
	rect_group_2_1 := lines[3]
	ui_rect_grid(rect_group_2_1, { 3, 1 }, &rects)

	// Up
	rect_group_2_2 := lines[1]
	grid := ui_rect_grid(rect_group_2_2, { 3, 1 }, allocator)
	append(&rects, grid[1])

	// Left - Right
	rect_group_2_3 := lines[0]
	ui_rect_grid(rect_group_2_3, { 3, 1 }, &rects)

	lines = ui_rect_grid_make(rect_group_3, { 1, 5 }, allocator)

	// NumLk - -
	rect_group_3_0 := lines[4]
	ui_rect_grid(rect_group_3_0, { 4, 1 }, &rects)

	// 7 - +
	rect_group_3_1 := lines[3]
	ui_rect_grid(rect_group_3_1, { 4, 1 }, &rects)

	// 4 - +
	rect_group_3_2 := lines[2]
	ui_rect_grid(rect_group_3_2, { 4, 1 }, &rects)
	ui_rects_merge(&rects, { 98, 103 }, remove_range=false)

	// 1 - NumEnter
	rect_group_3_3 := lines[1]
	ui_rect_grid(rect_group_3_3, { 4, 1 }, &rects)

	// 0 - NumEnter
	rect_group_3_4 := lines[0]
	ui_rect_grid(rect_group_3_4, { 4, 1 }, &rects)
	ui_rects_merge_range(&rects, { 106, 108 })
	ui_rects_merge(&rects, { 105, 109 }, remove_range=false)

	// n := len(rects)
	// for rect in rects[0:n] do append(&rects, key_margins(rect))

	// ui_rect_grid_append(rect_left, { 2, 4 }, &rects)
	// ui_rect_slice_v_append(rect_right, 80, 4, &rects)
	return rects[:] }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="Input Example", temp_allocator_cap=1000 * mem.Megabyte),
		input_config=default_input_config(raw_input = false))

	font_group: Font_Group
	font_group_init(&font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	text_style: Text_Style = default_text_style(font_group = font_group, color = WHITE)
	ui_text_style_push(text_style)

	ASPECT_RATIO :: 3.5
	keyboard_rect: Rect = { { 0, 0 }, { ASPECT_RATIO * 256, 256 } }
	rects := make_rects(keyboard_rect, context.allocator)
	keys: []string = {
		"Esc", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
		"PrtSc", "ScrLk", "Pause", "Cal", "Mute", "VolUp", "VolDn",
		"`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "<---",
		"Tab", "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", "\\",
		"CapsLock", "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", "<--'",
		"Shift", "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "Shift",
		"Ctrl", "Win", "Alt", "----", "Alt", "Win", "Fn", "Ctrl",
		"Ins", "Home", "PgUp", "Del", "End", "PgDn",
		"^", "<", "v", ">",
		"NumLk", "/", "x", "-",
		"7", "8", "9", "+",
		"4", "5", "6",
		"1", "2", "3", "<-'",
		"0", "." }
	inputs: []Input = {
		.Escape, .F1, .F2, .F3, .F4, .F5, .F6, .F7, .F8, .F9, .F10, .F11, .F12,
		.Print_Screen, .Scroll_Lock, .Pause, .None, .None, .None, .None,
		.Backtick, .Num_1, .Num_2, .Num_3, .Num_4, .Num_5, .Num_6, .Num_7, .Num_8, .Num_9, .Num_0, .Minus, .Equal, .Backspace,
		.Tab, .Q, .W, .E, .R, .T, .Y, .U, .I, .O, .P, .Left_Bracket, .Left_Bracket, .Backslash,
		.Caps_Lock, .A, .S, .D, .F, .G, .H, .J, .K, .L, .Semicolon, .None, .Enter,
		.Left_Shift, .Z, .X, .C, .V, .B, .N, .M, .Comma, .Period, .Slash, .None,
		.Left_Control, .Left_Super, .Left_Alt, .Space, .None, .None, .None, .None,
		.Insert, .Home, .Page_Up, .Delete, .End, .Page_Down,
		.Up, .Left, .Down, .Right,
		.Num_Lock, .Numpad_Divide, .Numpad_Multiply, .Numpad_Subtract,
		.Numpad_7, .Numpad_8, .Numpad_9, .Numpad_Add,
		.Numpad_4, .Numpad_5, .Numpad_6,
		.Numpad_1, .Numpad_2, .Numpad_3, .Numpad_Enter,
		.Numpad_0, .Numpad_Decimal }

	context = engine_end_init()

	for engine_running() {
		engine_tick()
		log.info(engine.tick_manager.frame_rate)
		for rect, i in rects {
			down: bool = false
			if inputs[i] != .None do down = input_query(inputs[i], .DOWN)
			down_offset: [2]f32 = { 0, down ? -4 : 0 }
			if down do dr_rect(rect, DARK_GRAY)
			dr_rect({ engine.input_manager.mouse_position, { 4, 4 } }, RED)
			dr_rect_outline(rect, WHITE)
			dr_rect_outline(ui_rect_translate(key_margins(rect), down_offset), GRAY)
			dr_text_line(keys[i], rect.position + down_offset) } }
	k: f32 = query().scalar
	return }
