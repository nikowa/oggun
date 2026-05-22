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
import "core:container/intrusive/list"

asset_manager: willow.Asset_Manager
graphics_manager: willow.Graphics_Manager
window_manager: willow.Window_Manager
stopwatch: time.Stopwatch
tick_manager: willow.Tick_Manager
screen_rect: willow.Rect
images: [dynamic]^willow.Image_Asset
background_image, car_image, tree_image, aardvark_image, meerkat_image, zebra_image: willow.Image_Asset
font_group: willow.Font_Group
text_style: willow.Text_Style

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
	using willow

	screen_position: [2]f32
	screen_position = entity.position * screen_rect.size / 2
	image: ^Image_Asset
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
	render_image(&graphics_manager, image, { screen_position, image_size }, depth = entity.depth)
	gui_text_line(&graphics_manager, text_style, screen_position + { 0, image_size.y / 2 }, label) }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow
	sync_context: Context = make_context()

	context.logger = log.create_console_logger()

	asset_manager_init(&asset_manager, default_asset_manager_config(), context.allocator)
	window_init(&window_manager, default_window_config(title = "Sync"))
	graphics_init(
		graphics_manager = &graphics_manager,
		asset_manager = &asset_manager,
		graphics_config = default_graphics_config(window_manager = &window_manager))
	tick_manager_init(&tick_manager, default_tick_manager_config())
	screen_rect = gui_screen(&graphics_manager)

	init_image(&asset_manager, &background_image, { url = "image:savanna-background.png" })
	append(&images, &background_image)
	init_image(&asset_manager, &car_image, { url = "image:car.png" })
	append(&images, &car_image)
	init_image(&asset_manager, &tree_image, { url = "image:tree.png" })
	append(&images, &tree_image)
	init_image(&asset_manager, &aardvark_image, { url = "image:aardvark.png" })
	append(&images, &aardvark_image)
	init_image(&asset_manager, &meerkat_image, { url = "image:meerkat.png" })
	append(&images, &meerkat_image)
	init_image(&asset_manager, &zebra_image, { url = "image:zebra.png" })
	append(&images, &zebra_image)

	for &image in images do assert(asset_commands(&asset_manager, Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	font_group_init(&asset_manager, &font_group, normal = default_font_config(name = "font-dev"))
	text_style = default_text_style(font_group = font_group, color = WHITE, tracking = 0)

	for _ in 0 ..< 10 do spawn_tree(random_position())
	for _ in 0 ..< 2 do spawn_car(random_position())

	zero_stopwatch(&stopwatch)
	for ! graphics_manager.window_closed {
		time := read_stopwatch(&stopwatch)
		tick_asset_manager(&asset_manager)

		if tick_manager_tick(&tick_manager) {
			defer tick_manager_reset(&tick_manager)
			tick_graphics_manager(&graphics_manager)

			render_image(&graphics_manager, &background_image, screen_rect, depth = 0.99)

			iter := list.iterator_head(entities, Entity, "node")
			for entity in list.iterate_next(&iter) {
				render_entity(entity) }

			render_image(&graphics_manager, &meerkat_image, { { -50, 0 }, MEERKAT_SIZE }, depth = 0.0)
			render_image(&graphics_manager, &zebra_image, { { 50, 0 }, ZEBRA_SIZE }, depth = 0.0)
			// render_text(&graphics_manager, "Hello, world!", font = &font, color = WHITE, scale_factor = 1.0)
		}

		free_all(context.temp_allocator) }
	return }
