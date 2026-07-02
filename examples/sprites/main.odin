#+feature using-stmt
package example_input
import og "shared:oggun"
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

Sprite :: struct {
	position: [2]f32,
	direction: [2]f32,
	depth: f32,
	speed: f32 }

sprite_init :: proc(sprite: ^Sprite) {
	sprite.position = { rand.float32(), rand.float32() }
	sprite.depth = rand.float32_range(0.1, 0.9999) // (TODO): Make a "DEPTH_MAX" constant.
	angle: f32 = 2 * math.PI * rand.float32()
	sprite.direction = { linalg.cos(angle), linalg.sin(angle) }
	sprite.speed = 0.01 * (1 + rand.float32()) }

Settings :: struct {
	player_name: string,
	resolution: [2]f32,
	fullscreen: bool }

main :: proc() {
	context.logger = log.create_console_logger()
	context = og.engine_begin_init(
		engine_config=og.default_engine_config(
			game_name="Sprites Example",
			track_backing_allocations=true,
			track_temp_allocations=true,
			temp_allocator_cap=1000 * mem.Megabyte))

	settings: Settings = {
		player_name = "Destroyer",
		resolution = { 1920, 1080 },
		fullscreen = true }
	og.settings_manager_write(&og.engine.settings_manager, &settings)

	images: [5]og.Image_Asset
	og.init_image(&images[0], { url = "image:kitten-1.png" })
	og.init_image(&images[1], { url = "image:kitten-2.png" })
	og.init_image(&images[2], { url = "image:kitten-3.png" })
	og.init_image(&images[3], { url = "image:kitten-4.png" })
	og.init_image(&images[4], { url = "image:kitten-5.png" })
	for &image in images do assert(og.am_commands(og.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	N :: 10000
	splits: [5]int
	for &split in splits do split = rand.int_max(N)
	slice.sort(splits[:])
	splits[4] = N

	font: og.Font
	og.font_init(&font, { name = "terminus", default_bearing = 0, default_advance = 0 })

	sprites := make([]Sprite, N)
	for &sprite in sprites do sprite_init(&sprite)

	og.zero_stopwatch(&stopwatch)

	context = og.engine_end_init()

	for og.engine_running() {
		time := og.read_stopwatch(&stopwatch)
		if og.engine_tick() {
			rect_screen := og.ui_rect_screen()

			// Sprites //
			image_index: int = 0
			for &sprite, i in sprites {
				sprite.position += og.engine.tick_manager.delta_time * sprite.speed * sprite.direction
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
				sprite_rect: og.Rect = { og.engine.graphics_manager.active_resolution * (sprite.position - { 0.5, 0.5 }), { 80, 80 } }
				{ og.gx_depth_scope(sprite.depth); og.dr_image(&images[image_index], sprite_rect, integer=false) }
				if i > splits[image_index] do image_index += 1 }

			// Metrics //
			{ og.gx_depth_scope(0.0); og.ui_metrics_widget() } } }
	return }
