package rects_dll
import "shared:willow/base"
import "shared:willow/graphics"
import "shared:willow/input"
import "shared:willow/window"
import "shared:willow/gui"
import "shared:willow/asset_manager"
import "shared:willow/container/rect"
import "shared:willow/dll"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math/linalg"
import "core:math"

key_margins :: proc(rect_in: rect.Rect) -> (rect_out: rect.Rect) {
	return gui.rect_extend(rect_in, -7, -7, -7, -2) }

@(export)
make_rects :: proc(keyboard_rect: rect.Rect, allocator: runtime.Allocator) -> []rect.Rect {
	rects := make_dynamic_array([dynamic]rect.Rect, allocator = context.temp_allocator)

	rect_group_0, rect_group := gui.rect_split_v(keyboard_rect, 0.187, 20)
	DIV_H1 :: 0.672
	DIV_H2 :: 0.434
	rect_group_1, _rect := gui.rect_split_h(rect_group, DIV_H1, 10)
	rect_group_2, rect_group_3 := gui.rect_split_h(_rect, DIV_H2, 10)

	// Esc
	rect_group_0_0: rect.Rect
	rect_group_0_0, _rect = gui.rect_split_h(rect_group_0, 0.065, 40)
	append(&rects, rect_group_0_0)

	// F1 - F4
	rect_group_0_1: rect.Rect
	rect_group_0_1, _rect = gui.rect_split_h(_rect, 0.207, 20)
	gui.rect_grid(rect_group_0_1, { 4, 1 }, &rects)

	// F5 - F8
	rect_group_0_2: rect.Rect
	rect_group_0_2, _rect = gui.rect_split_h(_rect, 0.266, 20)
	gui.rect_grid(rect_group_0_2, { 4, 1 }, &rects)

	// F9 - F12
	rect_group_0_3: rect.Rect
	rect_group_0_3, _rect = gui.rect_split_h(_rect, 0.36, 10)
	gui.rect_grid(rect_group_0_3, { 4, 1 }, &rects)

	// PrtScr ScrLk Pause
	rect_group_0_4: rect.Rect
	rect_group_0_4, _rect = gui.rect_split_h(_rect, 0.43, 10)
	gui.rect_grid(rect_group_0_4, { 3, 1 }, &rects)

	// Del - Home
	rect_group_0_5 := _rect
	gui.rect_grid(rect_group_0_5, { 4, 1 }, &rects)

	lines := gui.rect_grid_make(rect_group_1, { 1, 5 }, allocator)

	KEY_WIDTH :: 39.8

	// ~ - <-
	rect_group_1_0 := lines[4]
	gui.rect_slice_h_append(rect_group_1_0, KEY_WIDTH, 14, &rects)

	// Tab - \
	rect_group_1_1 := lines[3]
	_rect, rect_group_1_1 = gui.rect_split_h(rect_group_1_1, 0.099, 0)
	append(&rects, _rect)
	gui.rect_slice_h_append(rect_group_1_1, KEY_WIDTH, 13, &rects)

	// CapsLock - Enter
	rect_group_1_2 := lines[2]
	_rect, rect_group_1_2 = gui.rect_split_h(rect_group_1_2, 0.116, 0)
	append(&rects, _rect)
	gui.rect_slice_h_append(rect_group_1_2, KEY_WIDTH, 12, &rects)

	// LShift - RShift
	rect_group_1_3 := lines[1]
	_rect, rect_group_1_3 = gui.rect_split_h(rect_group_1_3, 0.150, 0)
	append(&rects, _rect)
	gui.rect_slice_h_append(rect_group_1_3, KEY_WIDTH, 11, &rects)

	// LCtrl - RCtrl
	rect_group_1_4 := lines[0]
	gui.rect_grid(rect_group_1_4, { 12, 1 }, &rects)
	gui.rects_merge_range(&rects, { 76, 81 })

	lines = gui.rect_grid_make(rect_group_2, { 1, 5 }, allocator)

	// Ins - PgUp
	rect_group_2_0 := lines[4]
	gui.rect_grid(rect_group_2_0, { 3, 1 }, &rects)

	// Del - PgDown
	rect_group_2_1 := lines[3]
	gui.rect_grid(rect_group_2_1, { 3, 1 }, &rects)

	// Up
	rect_group_2_2 := lines[1]
	grid := gui.rect_grid(rect_group_2_2, { 3, 1 }, allocator)
	append(&rects, grid[1])

	// Left - Right
	rect_group_2_3 := lines[0]
	gui.rect_grid(rect_group_2_3, { 3, 1 }, &rects)

	lines = gui.rect_grid_make(rect_group_3, { 1, 5 }, allocator)

	// NumLk - -
	rect_group_3_0 := lines[4]
	gui.rect_grid(rect_group_3_0, { 4, 1 }, &rects)

	// 7 - +
	rect_group_3_1 := lines[3]
	gui.rect_grid(rect_group_3_1, { 4, 1 }, &rects)

	// 4 - +
	rect_group_3_2 := lines[2]
	gui.rect_grid(rect_group_3_2, { 4, 1 }, &rects)
	gui.rects_merge_range_retaining(&rects, { 98, 103 })

	// 1 - NumEnter
	rect_group_3_3 := lines[1]
	gui.rect_grid(rect_group_3_3, { 4, 1 }, &rects)

	// 0 - NumEnter
	rect_group_3_4 := lines[0]
	gui.rect_grid(rect_group_3_4, { 4, 1 }, &rects)
	gui.rects_merge_range(&rects, { 106, 108 })
	gui.rects_merge_range_retaining(&rects, { 105, 109 })

	n := len(rects)
	for rect in rects[0:n] do append(&rects, key_margins(rect))

	// gui.rect_grid_append(rect_left, { 2, 4 }, &rects)
	// gui.rect_slice_v_append(rect_right, 80, 4, &rects)
	return rects[:] }
