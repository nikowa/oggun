#+feature using-stmt
package example_input
import "shared:oggun"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"
import "core:container/intrusive/list"
import "core:mem"

stopwatch: time.Stopwatch
screen_rect: oggun.Rect
images: [dynamic]^oggun.Image_Asset
background_image, car_image, tree_image, aardvark_image, meerkat_image, zebra_image: oggun.Image_Asset
font_group: oggun.Font_Group

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

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

dr_entity :: proc(entity: ^Entity) {
	using oggun

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
	{ gx_depth_scope(entity.depth); dr_image(image, { screen_position, image_size }) }
	dr_text_line(label, screen_position + { 0, image_size.y / 2 }) }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun
	sync_context: Context = make_context()

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="Sync Example", temp_allocator_cap=1000 * mem.Megabyte))
	screen_rect = rect_screen()

	init_image(&background_image, { url = "image:savanna-background.png" })
	append(&images, &background_image)
	init_image(&car_image, { url = "image:car.png" })
	append(&images, &car_image)
	init_image(&tree_image, { url = "image:tree.png" })
	append(&images, &tree_image)
	init_image(&aardvark_image, { url = "image:aardvark.png" })
	append(&images, &aardvark_image)
	init_image(&meerkat_image, { url = "image:meerkat.png" })
	append(&images, &meerkat_image)
	init_image(&zebra_image, { url = "image:zebra.png" })
	append(&images, &zebra_image)

	for &image in images do assert(am_commands(Image_Asset, &image.asset, { .Import, .Load, .Upload }))

	font_group_init(&font_group, normal = default_font_config(name = "terminus"))
	text_style: oggun.Text_Style = default_text_style(font_group = font_group, color = WHITE, tracking = 0)
	ui_text_style_push(text_style)

	for _ in 0 ..< 10 do spawn_tree(random_position())
	for _ in 0 ..< 2 do spawn_car(random_position())

	zero_stopwatch(&stopwatch)

	context = engine_end_init()

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			dr_image(&background_image, screen_rect)

			iter := list.iterator_head(entities, Entity, "node")
			for entity in list.iterate_next(&iter) {
				dr_entity(entity) }

			{
				gx_depth_scope(0.0)
				dr_image(&meerkat_image, { { -50, 0 }, MEERKAT_SIZE })
				dr_image(&zebra_image, { { 50, 0 }, ZEBRA_SIZE })
			}
			// dr_text("Hello, world!", font = &font, color = WHITE, scale_factor = 1.0)
		}

		free_all(context.temp_allocator) }
	return }
