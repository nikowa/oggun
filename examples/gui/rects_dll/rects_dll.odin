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

MARGIN :: 8

@(export)
make_rects :: proc(keyboard_rect: rect.Rect, allocator: runtime.Allocator) -> []rect.Rect {
	rects := make_dynamic_array([dynamic]rect.Rect, allocator = context.temp_allocator)
	rect_left, rect_right := gui.rect_split_h(keyboard_rect, 0.25, MARGIN)
	gui.rect_grid_append(rect_left, { 2, 4 }, &rects)
	gui.rect_slice_v_append(rect_right, 80, 4, &rects)
	return rects[:] }
