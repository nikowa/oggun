package example_input
import "shared:willow"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"

settings_man: willow.Settings_Manager
asset_man: willow.Asset_Manager
graphics_man: willow.Graphics_Manager
window_man: willow.Window_Manager
stopwatch: time.Stopwatch
tick_man: willow.Tick_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	willow.start(entry_point, n_workers_override = 1) }

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

Settings :: struct {
	player_name: string,
	resolution: [2]f32,
	fullscreen: bool }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	context.logger = log.create_console_logger()

	settings: Settings = {
		player_name = "Destroyer",
		resolution = { 1920, 1080 },
		fullscreen = true }
	willow.init_settings_manager(&settings_man, "Sprites")
	willow.settings_manager_write(&settings_man, &settings)

	asset_man = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP,
		watch = true }, context.allocator)
	willow.window_init(&window_man, willow.WINDOW_CONFIG_DEFAULT)
	willow.graphics_init(
		graphics_manager = &graphics_man,
		as_mngr = &asset_man,
		graphics_config = { window_manager = &window_man, clear_color = willow.BLACK })
	willow.init_tick_manager(&tick_man, { tickrate_setting = .LIMITED_60_FPS })

	images: [5]willow.Image_Asset
	willow.init_image(&asset_man, &images[0], { url = "image:kitten-1.png" })
	willow.init_image(&asset_man, &images[1], { url = "image:kitten-2.png" })
	willow.init_image(&asset_man, &images[2], { url = "image:kitten-3.png" })
	willow.init_image(&asset_man, &images[3], { url = "image:kitten-4.png" })
	willow.init_image(&asset_man, &images[4], { url = "image:kitten-5.png" })
	for &image in images do assert(willow.asset_commands(&asset_man, willow.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	N :: 1000
	splits: [5]int
	for &split in splits do split = rand.int_max(N)
	slice.sort(splits[:])
	splits[4] = N

	font: willow.Bitmap_Font
	willow.bitmap_font_init(&asset_man, &font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	sprites := make([]Sprite, N)
	for &sprite in sprites do sprite_init(&sprite)

	willow.zero_stopwatch(&stopwatch)
	for ! graphics_man.window_closed {
		time := willow.read_stopwatch(&stopwatch)
		willow.tick_asset_manager(&asset_man)

		if willow.tick_manager_tick(&tick_man) {
			defer willow.tick_manager_reset(&tick_man)
			// fmt.printfln("fps: %v", cast(int)tick_man.frame_rate)
			willow.tick_graphics_manager(&graphics_man)
			gui_screen := willow.gui_screen(&graphics_man)
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
				sprite_rect: willow.Rect = { graphics_man.active_resolution * (sprite.position - { 0.5, 0.5 }), { 80, 80 } }
				willow.render_image(&graphics_man, &images[image_index], sprite_rect, depth = sprite.depth)
				if i > splits[image_index] do image_index += 1 }
			// willow.render_bitmap_text(&graphics_man, "Hello, world!", font = &font, color = willow.WHITE, scale_factor = 2.0)
		}

		free_all(context.temp_allocator) }
	return }
