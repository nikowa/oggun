package example_input
import "shared:willow/base"
import "shared:willow/graphics"
import "shared:willow/input"
import "shared:willow/window"
import "shared:willow/gui"
import "shared:willow/asset_manager"
import "shared:willow/container/rect"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math/linalg"
import "core:math"

asset_man: asset_manager.Asset_Manager
graphics_manager: graphics.Graphics_Manager
input_manager: input.Input_Manager
window_manager: window.Window_Manager
stopwatch: time.Stopwatch
MARGIN :: 8

main :: proc() {
	context.logger = log.create_console_logger()
	base.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1.0 } }

@(export)
entry_point :: proc(thread_data: ^base.Thread_Data) {
	context.logger = log.create_console_logger()
	asset_man = asset_manager.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../../data",
		autosave_interval = asset_manager.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = asset_manager.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	window.init(&window_manager, window.WINDOW_CONFIG_DEFAULT)
	graphics.init(
		graphics_manager = &graphics_manager,
		as_mngr = &asset_man,
		graphics_config = { window_manager = &window_manager },
		title = "Willow")
	colors: [][4]f32 = make([][4]f32, 64)
	for _, i in colors do colors[i] = graphics.color_random()
	base.zero_stopwatch(&stopwatch)
	for ! graphics_manager.window_closed {
		time := base.read_stopwatch(&stopwatch)
		osc := 32 * linalg.sin(16 * time)
		rects := make_dynamic_array([dynamic]rect.Rect, allocator = context.temp_allocator)
		asset_manager.watch_assets(&asset_man)
		graphics.tick(&graphics_manager)
		rect := gui.rect_screen(&graphics_manager)
		rect = gui.rect_margins(rect, MARGIN)
		rect_left, rect_right := gui.rect_split_h(rect, 0.25, MARGIN)
		// append(&rects, rect_left)
		// append(&rects, rect_right)

// keyboard-layout
		gui.rect_grid_append(rect_left, { 2, 4 }, &rects)
		gui.rect_slice_v_append(rect_right, 80, 4, &rects)
		gui.rects_mirror_x(rects[:], -100)
		for rect, i in rects do graphics.render_rect(&graphics_manager, rect, colors[i], 0.0)
		free_all(context.temp_allocator) }
	k: f32 = query().scalar
	return }
