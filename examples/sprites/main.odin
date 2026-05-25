#+feature using-stmt
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

settings_manager: willow.Settings_Manager
asset_manager: willow.Asset_Manager
graphics_manager: willow.Graphics_Manager
window_manager: willow.Window_Manager
tick_manager: willow.Tick_Manager
stopwatch: time.Stopwatch

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
	sprite.speed = 0.01 * (1 + rand.float32()) }

Settings :: struct {
	player_name: string,
	resolution: [2]f32,
	fullscreen: bool }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow

	context.logger = log.create_console_logger()
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 1000 * mem.Megabyte))
	context.temp_allocator = mem.arena_allocator(&arena)

	settings: Settings = {
		player_name = "Destroyer",
		resolution = { 1920, 1080 },
		fullscreen = true }
	settings_manager_init(&settings_manager, "Willow Examples", "Settings")
	settings_manager_write(&settings_manager, &settings)

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_manager, default_window_config(title = "Sprites"))
	graphics_init(graphics_manager = &graphics_manager, asset_manager = &asset_manager,
		graphics_config = default_graphics_config(window_manager = &window_manager))
	tick_manager_init(&tick_manager, { tickrate_setting = .LIMITED_60_FPS })

	images: [5]Image_Asset
	init_image(&asset_manager, &images[0], { url = "image:kitten-1.png" })
	init_image(&asset_manager, &images[1], { url = "image:kitten-2.png" })
	init_image(&asset_manager, &images[2], { url = "image:kitten-3.png" })
	init_image(&asset_manager, &images[3], { url = "image:kitten-4.png" })
	init_image(&asset_manager, &images[4], { url = "image:kitten-5.png" })
	for &image in images do assert(asset_commands(&asset_manager, Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	N :: 10000
	splits: [5]int
	for &split in splits do split = rand.int_max(N)
	slice.sort(splits[:])
	splits[4] = N

	font: Font
	font_init(&asset_manager, &font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	sprites := make([]Sprite, N)
	for &sprite in sprites do sprite_init(&sprite)

	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		tick_asset_manager(&asset_manager)

		if tick_manager_tick(&tick_manager) {
			defer tick_manager_reset(&tick_manager)
			tick_graphics_manager(&graphics_manager)
			gui_screen := gui_screen(&graphics_manager)
			image_index: int = 0
			for &sprite, i in sprites {
				sprite.position += tick_manager.delta_time * sprite.speed * sprite.direction
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
				sprite_rect: Rect = { graphics_manager.active_resolution * (sprite.position - { 0.5, 0.5 }), { 80, 80 } }
				draw_image(&graphics_manager, &images[image_index], sprite_rect, depth = sprite.depth)
				if i > splits[image_index] do image_index += 1 } }

		free_all(context.temp_allocator) }
	return }
