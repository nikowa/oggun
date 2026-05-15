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
import "core:container/intrusive/list"

settings_man: willow.Settings_Manager
asset_man: willow.Asset_Manager
graphics_man: willow.Graphics_Manager
window_man: willow.Window_Manager
stopwatch: time.Stopwatch
tick_man: willow.Tick_Manager
rect_screen: willow.Rect
images: [dynamic]^willow.Image_Asset
background_image, car_image, tree_image, aardvark_image, meerkat_image, zebra_image: willow.Image_Asset
font: willow.Bitmap_Font

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

CAR_SIZE: [2]f32 : { 260, 83 }
TREE_SIZE: [2]f32 : { 381, 144 }
AARDVARK_SIZE: [2]f32 : { 127, 58 }
MEERKAT_SIZE: [2]f32 : { 44, 51 }
ZEBRA_SIZE: [2]f32 : { 150, 95 }
DEPTH_TREES :: 0.9
DEPTH_BUILDINGS :: 0.8

// The shared resources are the entities themselves. Entities can interact with one-another in various ways.

Entity :: struct {
	using node: list.Node,
	position: [2]f32,
	depth: f32,
	variant: Entity_Variant }

Entity_Variant :: union {
	Entity_Tree,
	Entity_Car }

Entity_Tree :: struct {
	size: f32 }

Entity_Car :: struct {
	size: f32 }

entities: list.List

random_position :: proc() -> (position: [2]f32) {
	return -{ 1, 1 } + 2 * { rand.float32(), rand.float32() } }

spawn_tree :: proc(position: [2]f32) {
	entity := new(Entity)
	tree: Entity_Tree = {
		size = 1.0 }
	entity^ = {
		position = position,
		depth = DEPTH_TREES + swing(),
		variant = tree }
	list.push_back(&entities, &entity.node) }

spawn_car :: proc(position: [2]f32) {
	entity := new(Entity)
	car: Entity_Car = {
		size = 1.0 }
	entity^ = {
		position = position,
		depth = DEPTH_BUILDINGS + swing(),
		variant = car }
	list.push_back(&entities, &entity.node) }

swing :: proc() -> f32 {
	return rand.float32_range(-0.05, 0.05) }

render_entity :: proc(entity: ^Entity) {
	screen_position: [2]f32
	screen_position = entity.position * rect_screen.size / 2
	image: ^willow.Image_Asset
	image_size: [2]f32
	label: string
	#partial switch variant in entity.variant {
	case Entity_Tree:
		image = &tree_image
		image_size = TREE_SIZE
		label = "Tree"
	case Entity_Car:
		image = &car_image
		image_size = CAR_SIZE
		label = "Car" }
	willow.render_image(&graphics_man, image, { screen_position, image_size }, depth = entity.depth)
	willow.render_bitmap_text(&graphics_man, label, pos = screen_position + { 0, image_size.y / 2 }, font = &font, color = willow.WHITE, scale_factor = 1.0) }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	sync_context: willow.Context = willow.make_context()

	context.logger = log.create_console_logger()

	asset_man = willow.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "../data",
		autosave_interval = willow.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = willow.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	window_config: willow.Window_Config = willow.WINDOW_CONFIG_DEFAULT

	window_config.size = { 1664, 936 }
	window_config.position = [2]f32{ 0, 0 }
	window_config.title = "Savanna"
	willow.window_init(&window_man, window_config)
	willow.graphics_init(
		graphics_manager = &graphics_man,
		as_mngr = &asset_man,
		graphics_config = { window_manager = &window_man, clear_color = willow.BLACK })
	willow.init_tick_manager(&tick_man, { tickrate_setting = .LIMITED_60_FPS })
	rect_screen = willow.rect_screen(&graphics_man)

	willow.init_image(&asset_man, &background_image, { url = "image:savanna-background.png" })
	append(&images, &background_image)
	willow.init_image(&asset_man, &car_image, { url = "image:car.png" })
	append(&images, &car_image)
	willow.init_image(&asset_man, &tree_image, { url = "image:tree.png" })
	append(&images, &tree_image)
	willow.init_image(&asset_man, &aardvark_image, { url = "image:aardvark.png" })
	append(&images, &aardvark_image)
	willow.init_image(&asset_man, &meerkat_image, { url = "image:meerkat.png" })
	append(&images, &meerkat_image)
	willow.init_image(&asset_man, &zebra_image, { url = "image:zebra.png" })
	append(&images, &zebra_image)

	for &image in images do assert(willow.asset_commands(&asset_man, willow.Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	willow.bitmap_font_init(&asset_man, &font, { name = "font-dev", default_bearing = 0, default_advance = 11 })

	for _ in 0 ..< 10 do spawn_tree(random_position())
	for _ in 0 ..< 2 do spawn_car(random_position())

	willow.zero_stopwatch(&stopwatch)
	for ! graphics_man.window_closed {
		time := willow.read_stopwatch(&stopwatch)
		willow.watch_assets(&asset_man)

		if willow.tick_manager_tick(&tick_man) {
			defer willow.tick_manager_reset(&tick_man)
			willow.tick_graphics_manager(&graphics_man)

			willow.render_image(&graphics_man, &background_image, rect_screen, depth = 0.99)

			iter := list.iterator_head(entities, Entity, "node")
			for entity in list.iterate_next(&iter) {
				render_entity(entity) }

			willow.render_image(&graphics_man, &meerkat_image, { { -50, 0 }, MEERKAT_SIZE }, depth = 0.0)
			willow.render_image(&graphics_man, &zebra_image, { { 50, 0 }, ZEBRA_SIZE }, depth = 0.0)
			// willow.render_bitmap_text(&graphics_man, "Hello, world!", font = &font, color = willow.WHITE, scale_factor = 1.0)
		}

		free_all(context.temp_allocator) }
	return }
