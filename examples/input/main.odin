package example_input
import "shared:willow"
import "base:runtime"
import "core:fmt"
import "core:log"

asset_man: willow.Asset_Manager
graphics_man: willow.Graphics_Manager
input_manager: willow.Input_Manager
window_manager: willow.Window_Manager
font: willow.Bitmap_Font

main :: proc() {
	context.logger = log.create_console_logger()
	willow.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1.0 } }

key_margins :: proc(rect_in: willow.Rect) -> (rect_out: willow.Rect) {
	return willow.rect_extend(rect_in, -7, -7, -7, -2) }

@(export)
make_rects :: proc(keyboard_rect: willow.Rect, allocator: runtime.Allocator) -> []willow.Rect {
	rects := make_dynamic_array([dynamic]willow.Rect, allocator = context.temp_allocator)

	rect_group_0, rect_group := willow.rect_split_ratio_v(keyboard_rect, 0.187, 20)
	DIV_H1 :: 0.672
	DIV_H2 :: 0.434
	rect_group_1, _rect := willow.rect_split_ratio_h(rect_group, DIV_H1, 10)
	rect_group_2, rect_group_3 := willow.rect_split_ratio_h(_rect, DIV_H2, 10)

	// Esc
	rect_group_0_0: willow.Rect
	rect_group_0_0, _rect = willow.rect_split_ratio_h(rect_group_0, 0.065, 40)
	append(&rects, rect_group_0_0)

	// F1 - F4
	rect_group_0_1: willow.Rect
	rect_group_0_1, _rect = willow.rect_split_ratio_h(_rect, 0.207, 20)
	willow.rect_grid(rect_group_0_1, { 4, 1 }, &rects)

	// F5 - F8
	rect_group_0_2: willow.Rect
	rect_group_0_2, _rect = willow.rect_split_ratio_h(_rect, 0.266, 20)
	willow.rect_grid(rect_group_0_2, { 4, 1 }, &rects)

	// F9 - F12
	rect_group_0_3: willow.Rect
	rect_group_0_3, _rect = willow.rect_split_ratio_h(_rect, 0.36, 10)
	willow.rect_grid(rect_group_0_3, { 4, 1 }, &rects)

	// PrtScr ScrLk Pause
	rect_group_0_4: willow.Rect
	rect_group_0_4, _rect = willow.rect_split_ratio_h(_rect, 0.43, 10)
	willow.rect_grid(rect_group_0_4, { 3, 1 }, &rects)

	// Del - Home
	rect_group_0_5 := _rect
	willow.rect_grid(rect_group_0_5, { 4, 1 }, &rects)

	lines := willow.rect_grid_make(rect_group_1, { 1, 5 }, allocator)

	KEY_WIDTH :: 39.8

	// ~ - <-
	rect_group_1_0 := lines[4]
	willow.rect_slice_h_append(rect_group_1_0, KEY_WIDTH, 14, &rects)

	// Tab - \
	rect_group_1_1 := lines[3]
	_rect, rect_group_1_1 = willow.rect_split_ratio_h(rect_group_1_1, 0.099, 0)
	append(&rects, _rect)
	willow.rect_slice_h_append(rect_group_1_1, KEY_WIDTH, 13, &rects)

	// CapsLock - Enter
	rect_group_1_2 := lines[2]
	_rect, rect_group_1_2 = willow.rect_split_ratio_h(rect_group_1_2, 0.116, 0)
	append(&rects, _rect)
	willow.rect_slice_h_append(rect_group_1_2, KEY_WIDTH, 12, &rects)

	// LShift - RShift
	rect_group_1_3 := lines[1]
	_rect, rect_group_1_3 = willow.rect_split_ratio_h(rect_group_1_3, 0.150, 0)
	append(&rects, _rect)
	willow.rect_slice_h_append(rect_group_1_3, KEY_WIDTH, 11, &rects)

	// LCtrl - RCtrl
	rect_group_1_4 := lines[0]
	willow.rect_grid(rect_group_1_4, { 12, 1 }, &rects)
	willow.rects_merge_range(&rects, { 76, 81 })

	lines = willow.rect_grid_make(rect_group_2, { 1, 5 }, allocator)

	// Ins - PgUp
	rect_group_2_0 := lines[4]
	willow.rect_grid(rect_group_2_0, { 3, 1 }, &rects)

	// Del - PgDown
	rect_group_2_1 := lines[3]
	willow.rect_grid(rect_group_2_1, { 3, 1 }, &rects)

	// Up
	rect_group_2_2 := lines[1]
	grid := willow.rect_grid(rect_group_2_2, { 3, 1 }, allocator)
	append(&rects, grid[1])

	// Left - Right
	rect_group_2_3 := lines[0]
	willow.rect_grid(rect_group_2_3, { 3, 1 }, &rects)

	lines = willow.rect_grid_make(rect_group_3, { 1, 5 }, allocator)

	// NumLk - -
	rect_group_3_0 := lines[4]
	willow.rect_grid(rect_group_3_0, { 4, 1 }, &rects)

	// 7 - +
	rect_group_3_1 := lines[3]
	willow.rect_grid(rect_group_3_1, { 4, 1 }, &rects)

	// 4 - +
	rect_group_3_2 := lines[2]
	willow.rect_grid(rect_group_3_2, { 4, 1 }, &rects)
	willow.rects_merge_range_retaining(&rects, { 98, 103 })

	// 1 - NumEnter
	rect_group_3_3 := lines[1]
	willow.rect_grid(rect_group_3_3, { 4, 1 }, &rects)

	// 0 - NumEnter
	rect_group_3_4 := lines[0]
	willow.rect_grid(rect_group_3_4, { 4, 1 }, &rects)
	willow.rects_merge_range(&rects, { 106, 108 })
	willow.rects_merge_range_retaining(&rects, { 105, 109 })

	// n := len(rects)
	// for rect in rects[0:n] do append(&rects, key_margins(rect))

	// willow.rect_grid_append(rect_left, { 2, 4 }, &rects)
	// willow.rect_slice_v_append(rect_right, 80, 4, &rects)
	return rects[:] }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	context.logger = log.create_console_logger()

	asset_man = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	willow.window_init(&window_manager, willow.WINDOW_CONFIG_DEFAULT)
	willow.input_init(&input_manager, &window_manager, { raw_input = true })
	willow.graphics_init(
		graphics_manager = &graphics_man,
		as_mngr = &asset_man,
		graphics_config = { window_manager = &window_manager, clear_color = willow.BLACK })

	willow.bitmap_font_init(&asset_man, &font, { name = "terminus", default_bearing = 0, default_advance = 0 })
	image: willow.Image_Asset
	willow.init_image(&asset_man, &image, { url = "image:kitten-2.png" })
	assert(willow.asset_commands(&asset_man, willow.Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	ASPECT_RATIO :: 3.5
	keyboard_rect: willow.Rect = { { 0, 0 }, { ASPECT_RATIO * 256, 256 } }
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
		"NumLk", "/", "*", "-",
		"7", "8", "9", "+",
		"4", "5", "6",
		"1", "2", "3", "<-'",
		"0", "." }
	inputs: []willow.Input = {
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

	colors: [][4]f32 = make([][4]f32, 512)
	for _, i in colors {
		colors[i] = willow.color_random()
		colors[i].a = 0.75 }

	for ! graphics_man.window_closed {
		willow.process(&input_manager)
		willow.tick(&graphics_man)
		for rect, i in rects {
			// willow.render_image(&graphics_man, &image, rect, depth = 0.99)
			down: bool = false
			if inputs[i] != .None do down = willow.input_query(&input_manager, inputs[i], .Down)
			down_offset: [2]f32 = { 0, down ? -4 : 0 }
			if down do willow.render_rect(&graphics_man, rect, willow.DARK_GRAY, depth = 0.99)
			willow.render_rect_hollow(&graphics_man, rect, willow.WHITE)
			willow.render_rect_hollow(&graphics_man, willow.rect_offset(key_margins(rect), down_offset), willow.GRAY)
			willow.render_bitmap_text(&graphics_man, keys[i], pos = rect.pos + down_offset, font = &font, color = willow.WHITE, scale_factor = 1.0) } }
	k: f32 = query().scalar
	return }
