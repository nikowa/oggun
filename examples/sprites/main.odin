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
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"

asset_man: asset_manager.Asset_Manager
graphics_man: graphics.Graphics_Manager
input_man: input.Input_Manager
window_man: window.Window_Manager
stopwatch: time.Stopwatch
tick_man: base.Tick_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	base.start(entry_point, n_workers_override = 1) }

Sprite :: struct {
	position: [2]f32,
	direction: [2]f32,
	depth: f32,
	speed: f32 }

sprite_init :: proc(sprite: ^Sprite) {
	sprite.position = { rand.float32(), rand.float32() }
	sprite.depth = rand.float32()
	angle: f32 = 2 * math.PI * rand.float32()
	sprite.direction = { linalg.cos(angle), linalg.sin(angle) }
	sprite.speed = 0.1 * (1 + rand.float32()) }

@(export)
entry_point :: proc(thread_data: ^base.Thread_Data) {
	context.logger = log.create_console_logger()

	asset_man = asset_manager.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../../data",
		autosave_interval = asset_manager.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = asset_manager.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	window.init(&window_man, window.WINDOW_CONFIG_DEFAULT)
	graphics.init(
		graphics_manager = &graphics_man,
		as_mngr = &asset_man,
		graphics_config = { window_manager = &window_man })
	base.init_tick_manager(&tick_man, { tickrate_setting = .LIMITED_60_FPS })

	images: [5]graphics.Image_Asset
	graphics.init_image(&asset_man, &images[0], { url = "image:kitten-1.png" })
	graphics.init_image(&asset_man, &images[1], { url = "image:kitten-2.png" })
	graphics.init_image(&asset_man, &images[2], { url = "image:kitten-3.png" })
	graphics.init_image(&asset_man, &images[3], { url = "image:kitten-4.png" })
	graphics.init_image(&asset_man, &images[4], { url = "image:kitten-5.png" })
	for &image in images do assert(asset_manager.asset_commands(&asset_man, graphics.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	N :: 1000
	splits: [5]int
	for &split in splits do split = rand.int_max(N)
	slice.sort(splits[:])
	splits[4] = N

	font: graphics.Bitmap_Font
	graphics.bitmap_font_init(&asset_man, &font, { name = "font-12pt", default_bearing = 0, default_advance = 0 })

	sprites := make([]Sprite, N)
	for &sprite in sprites do sprite_init(&sprite)

	base.zero_stopwatch(&stopwatch)
	for ! graphics_man.window_closed {
		time := base.read_stopwatch(&stopwatch)
		asset_manager.watch_assets(&asset_man)

		if base.tick_manager_tick(&tick_man) {
			defer base.tick_manager_reset(&tick_man)
			// fmt.printfln("fps: %v", cast(int)tick_man.frame_rate)
			graphics.tick(&graphics_man)
			rect_screen := gui.rect_screen(&graphics_man)
			image_index: int = 0
			for &sprite, i in sprites {
				sprite.position += tick_man.delta_time * sprite.speed * sprite.direction
				if sprite.position.x > 1 {
					sprite.position.x = 1
					sprite.direction.x *= -1 }
				if sprite.position.x < 0 {
					sprite.position.x = 0
					sprite.direction.x *= -1 }
				if sprite.position.y > 1 {
					sprite.position.y = 1
					sprite.direction.y *= -1 }
				if sprite.position.y < 0 {
					sprite.position.y = 0
					sprite.direction.y *= -1 }
				sprite_rect: rect.Rect = { graphics_man.active_resolution * (sprite.position - { 0.5, 0.5 }), { 80, 80 } }
				// graphics.render_image(&graphics_man, &images[image_index], sprite_rect, depth = sprite.depth)
				if i > splits[image_index] do image_index += 1 }
			graphics.render_bitmap_text(&graphics_man, "Hello, world!", font = &font, color = graphics.WHITE, scale_factor = 2.0) }

		free_all(context.temp_allocator) }
	return }
