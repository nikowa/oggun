package example_input
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

asset_man: asset_manager.Asset_Manager
graphics_manager: graphics.Graphics_Manager
input_manager: input.Input_Manager
window_manager: window.Window_Manager
stopwatch: time.Stopwatch
rects_dll: Rects_DLL

Rects_DLL :: struct {
	using base: dll.DLL,
	make_rects: proc(keyboard_rect: rect.Rect, allocator: runtime.Allocator) -> []rect.Rect }

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

	// dll_path := asset_manager.relpath_to_path("rects_dll/rects_dll.odin", context.allocator)
	// rects_dll, _ = dll.make_dll(Rects_DLL, dll_path)
	rects_dll, _ = dll.make_dll(Rects_DLL, "rects_dll/rects_dll.odin")
	assert(rects_dll.make_rects != nil)

	image: graphics.Image_Asset
	graphics.init_image(&asset_man, &image, { url = "image:keyboard-layout.png" })
	assert(asset_manager.asset_commands(&asset_man, graphics.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	font: graphics.Bitmap_Font
	graphics.bitmap_font_init(&asset_man, &font, graphics.DEFAULT_BITMAP_FONT_CONFIG)
	assert(asset_manager.asset_commands(&asset_man, graphics.Image_Asset, &font.bitmap_image.asset, { .Import, .Load, .Upload }))

	colors: [][4]f32 = make([][4]f32, 256)
	for _, i in colors {
		colors[i] = graphics.color_random()
		colors[i].a = 0.75 }

	// - text rendering

	base.zero_stopwatch(&stopwatch)
	ASPECT_RATIO :: 3.5
	for ! graphics_manager.window_closed {
		time := base.read_stopwatch(&stopwatch)
		osc := 32 * linalg.sin(16 * time)
		asset_manager.watch_assets(&asset_man)
		graphics.tick(&graphics_manager)

		rect_screen := gui.rect_screen(&graphics_manager)
		keyboard_rect: rect.Rect = { { 0, 0 }, { ASPECT_RATIO * 256, 256 } }
		// graphics.render_image(&graphics_manager, &image, keyboard_rect)

		rects := rects_dll.make_rects(keyboard_rect, context.temp_allocator)

		for rect, i in rects do graphics.render_rect_hollow(&graphics_manager, rect, graphics.WHITE/*colors[i]*/)

		dll.watch_dll(&rects_dll)
		free_all(context.temp_allocator) }
	k: f32 = query().scalar
	return }
