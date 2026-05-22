package example_input
import "shared:willow"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math/linalg"
import "core:math"

asset_manager: willow.Asset_Manager
graphics_manager: willow.Graphics_Manager
window_manager: willow.Window_Manager
stopwatch: time.Stopwatch
rects_dll: Rects_DLL

Rects_DLL :: struct {
	using base: willow.DLL,
	make_rects: proc(keyboard_rect: willow.Rect, allocator: runtime.Allocator) -> []willow.Rect }

main :: proc() {
	context.logger = log.create_console_logger()
	willow.start(entry_point, n_workers_override = 1) }

query :: proc() -> struct #raw_union { scalar: f32, boolean: b32 } {
	return { scalar = 1.0 } }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow
	context.logger = log.create_console_logger()

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_man, default_window_config(title = "GUI"))
	graphics_init(
		graphics_manager = &graphics_manager,
		as_mngr = &asset_manager,
		graphics_config = { window_manager = &window_manager, clear_color = BLACK })

	// dll_path := relpath_to_path("rects_dll/rects_dll.odin", context.allocator)
	// rects_dll, _ = make_dll(Rects_DLL, dll_path)
	rects_dll, _ = make_dll(Rects_DLL, "rects_dll/rects_dll.odin")
	assert(rects_dll.make_rects != nil)

	image: Image_Asset
	init_image(&asset_manager, &image, { url = "image:keyboard-layout.png" })
	assert(asset_commands(&asset_manager, Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	font: Font
	font_init(&asset_manager, &font, DEFAULT_FONT_CONFIG)
	assert(asset_commands(&asset_manager, Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))

	colors: [][4]f32 = make([][4]f32, 256)
	for _, i in colors {
		colors[i] = color_random()
		colors[i].a = 0.75 }

	// - text rendering

	zero_stopwatch(&stopwatch)
	ASPECT_RATIO :: 3.5
	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		osc := 32 * linalg.sin(16 * time)
		tick_asset_manager(&asset_manager)
		tick_graphics_manager(&graphics_manager)

		gui_screen := gui_screen(&graphics_manager)
		keyboard_rect: Rect = { { 0, 0 }, { ASPECT_RATIO * 256, 256 } }
		// render_image(&graphics_manager, &image, keyboard_rect)

		rects := rects_dll.make_rects(keyboard_rect, context.temp_allocator)

		for rect, i in rects do render_rect_outline(&graphics_manager, rect, WHITE/*colors[i]*/)

		watch_dll(&rects_dll)
		free_all(context.temp_allocator) }
	k: f32 = query().scalar
	return }
