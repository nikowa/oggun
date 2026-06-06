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
import "core:mem"

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

	engine_begin_init("Sprites Example")

	settings: Settings = {
		player_name = "Destroyer",
		resolution = { 1920, 1080 },
		fullscreen = true }
	settings_manager_write(&engine.settings_manager, &settings)

	images: [5]Image_Asset
	init_image(&images[0], { url = "image:kitten-1.png" })
	init_image(&images[1], { url = "image:kitten-2.png" })
	init_image(&images[2], { url = "image:kitten-3.png" })
	init_image(&images[3], { url = "image:kitten-4.png" })
	init_image(&images[4], { url = "image:kitten-5.png" })
	for &image in images do assert(am_commands(Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	N :: 10000
	splits: [5]int
	for &split in splits do split = rand.int_max(N)
	slice.sort(splits[:])
	splits[4] = N

	font: Font
	font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	sprites := make([]Sprite, N)
	for &sprite in sprites do sprite_init(&sprite)

	zero_stopwatch(&stopwatch)

	context = engine_end_init()
	// backing_allocator := context.allocator
	// context.allocator = context.temp_allocator

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			gi_rect_screen := gi_rect_screen()
			image_index: int = 0
			for &sprite, i in sprites {
				sprite.position += engine.tick_manager.delta_time * sprite.speed * sprite.direction
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
				sprite_rect: Rect = { engine.graphics_manager.active_resolution * (sprite.position - { 0.5, 0.5 }), { 80, 80 } }
				{ gx_depth_scope(sprite.depth); dr_image(&images[image_index], sprite_rect) }
				if i > splits[image_index] do image_index += 1 } } }
	return }
