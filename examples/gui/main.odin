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
	context.logger = log.create_console_logger()

	asset_manager = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP,
		watch = true }, context.allocator)
	willow.window_init(&window_man, willow.default_window_config(title = "GUI"))
	willow.graphics_init(
		graphics_manager = &graphics_manager,
		as_mngr = &asset_manager,
		graphics_config = { window_manager = &window_manager, clear_color = willow.BLACK })

	// dll_path := willow.relpath_to_path("rects_dll/rects_dll.odin", context.allocator)
	// rects_dll, _ = willow.make_dll(Rects_DLL, dll_path)
	rects_dll, _ = willow.make_dll(Rects_DLL, "rects_dll/rects_dll.odin")
	assert(rects_dll.make_rects != nil)

	image: willow.Image_Asset
	willow.init_image(&asset_manager, &image, { url = "image:keyboard-layout.png" })
	assert(willow.asset_commands(&asset_manager, willow.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	font: willow.Font
	willow.font_init(&asset_manager, &font, willow.DEFAULT_FONT_CONFIG)
	assert(willow.asset_commands(&asset_manager, willow.Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))

	colors: [][4]f32 = make([][4]f32, 256)
	for _, i in colors {
		colors[i] = willow.color_random()
		colors[i].a = 0.75 }

	// - text rendering

	willow.zero_stopwatch(&stopwatch)
	ASPECT_RATIO :: 3.5
	for ! graphics_manager.window_closed {
		time := willow.read_stopwatch(&stopwatch)
		osc := 32 * linalg.sin(16 * time)
		willow.tick_asset_manager(&asset_manager)
		willow.tick_graphics_manager(&graphics_manager)

		gui_screen := willow.gui_screen(&graphics_manager)
		keyboard_rect: willow.Rect = { { 0, 0 }, { ASPECT_RATIO * 256, 256 } }
		// willow.render_image(&graphics_manager, &image, keyboard_rect)

		rects := rects_dll.make_rects(keyboard_rect, context.temp_allocator)

		for rect, i in rects do willow.render_rect_outline(&graphics_manager, rect, willow.WHITE/*colors[i]*/)

		willow.watch_dll(&rects_dll)
		free_all(context.temp_allocator) }
	k: f32 = query().scalar
	return }
