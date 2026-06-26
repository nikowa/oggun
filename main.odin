package game
import bs "shared/oggun/base"
import rt "base:runtime"
import os "core:os"
import fmt "core:fmt"
import mem "core:mem"
import log "core:log"
import m "core:math"
import la "core:math/linalg"
import dl "core:dynlib"
import tm "core:time"
import as "shared/oggun/asset_manager"
import gx "shared/oggun/graphics"
import "shared/oggun/input"
import r "shared/oggun/container/rect"
import scn "shared/oggun/scene"
import dll "shared/oggun/dll"
import msh "shared/oggun/mesh"
import hsh "core:crypto/hash"



RO_State :: struct {
	_: u8 }

Example_DL :: struct {
	using base: dll.DL,
	dev_tick: proc(camera_node: ^scn.Camera_Node, done_onces: ^map[rt.Source_Code_Location]bool, time: f32) }

asset_manager: as.Asset_Manager
graphics_manager: gx.Graphics_Manager
input_manager: input.Input_Manager

main :: proc() {
	context.logger = log.create_console_logger()
	bs.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^bs.Thread_Data) {
	entry: ^as.Entry
	ok: bool
	image: gx.Image_Asset
	model: gx.Model
	err: os.Error
	model_node: ^scn.Model_Node
	camera: scn.Camera
	camera_node: ^scn.Camera_Node
	scene: scn.Scene
	node_config: scn.Node_Config
	example_dll: Example_DL
	modification_time: tm.Time
	stopwatch: tm.Stopwatch
	time: f32
	string_asset: as.String_Asset
	track: mem.Tracking_Allocator
	done_onces := make(map[rt.Source_Code_Location]bool)

	// when ODIN_DEBUG {
		// mem.tracking_allocator_init(&track, context.allocator)
		// context.allocator = mem.tracking_allocator(&track)
	// }
	// for digest_size in hsh.DIGEST_SIZES do log.info(digest_size)
	context.logger = log.create_console_logger()
	bs.zero_stopwatch(&stopwatch)
	example_dll, err = dll.dl_make(Example_DL, "example-dll/example-dll.odin")
	assert(err == nil)
	assert(example_dll.dev_tick != nil)
	asset_manager = as.am_init({
		relpath = "Data.bin",
		source_directory_relpath = "data",
		autosave_interval = as.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = as.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	gx.graphics_init(&graphics_manager, &asset_manager, gx.DEFAULT_GRAPHICS_CONFIG, "Oggun")
	// gx.graphics_init(&graphics_manager, &asset_manager, { window_size = { 1920, 1080 } }, "Oggun")
	gx.init_image(&asset_manager, &image, { url = "image:kitten.png" })
	assert(as.asset_commands(&asset_manager, gx.Image_Asset, &image.asset, { .Import, .Load, .Upload }))
	model, err = gx.load_model(as.relpath_to_path("data/castle.glb", context.allocator), "model:castle", context.allocator)
	gx.upload_model(&model)
	explosion_effect: gx.Effect
	gx.init_and_upload_effect(&explosion_effect, { "effect:explosion", { { 24, 24 }, { 16, 16 } } }, &graphics_manager, &asset_manager, "string:veffect-explosion.glsl", "string:feffect-explosion.glsl", context.allocator)
	swamp_effect: gx.Effect
	gx.init_and_upload_effect(&swamp_effect, { "effect:swamp", { { 1, 1 }, { 1, 1 }, { 1, 1 } } }, &graphics_manager, &asset_manager, "string:veffect-swamp.glsl", "string:feffect-swamp.glsl", context.allocator)
	test_effect: gx.Effect
	gx.init_and_upload_effect(&test_effect, { "effect:test", { { 1, 1 } } }, &graphics_manager, &asset_manager, "string:veffect-test.glsl", "string:feffect-test.glsl", context.allocator)
	scene = scn.make_scene("scene:castle")
	camera = scn.DEFAULT_CAMERA
	camera.sensor_size *= 10
	node_config = scn.DEFAULT_NODE_CONFIG
	node_config.name = "camera"
	node_config.tick_proc = tick_camera_node
	camera_node = scn.make_camera_node(node_config, &camera, context.allocator)
	model_node = scn.make_model_node(scn.default_node_config(name = "castle", id = 1), &model, context.allocator)
	model_node.node.translate.z = -0
	explosion_effect_node := scn.make_effect_node(scn.default_node_config(name = "explosion-effect", id = 2), &explosion_effect, context.allocator)
	swamp_effect_node := scn.make_effect_node(scn.default_node_config(name = "swamp-effect", id = 2), &swamp_effect, context.allocator)
	test_effect_node := scn.make_effect_node(scn.default_node_config(name = "test-effect", id = 2), &test_effect, context.allocator)
	cube_mesh := msh.make_line_cube_mesh(context.allocator, 0.5)
	ground_mesh := msh.make_line_ground_mesh(context.allocator, 8)
	msh.upload_mesh(&cube_mesh)
	msh.upload_mesh(&ground_mesh)
	cube_mesh_node := scn.make_mesh_node(scn.default_node_config("cube-mesh"), &cube_mesh, context.allocator)
	ground_mesh_node := scn.make_mesh_node(scn.default_node_config("ground-mesh"), &ground_mesh, context.allocator)
	translate: [3]f32 = { -3.5, -3.5, 0.5 }
	explosion_effect_node.node.translate = translate
	cube_mesh_node.node.translate = translate
	scn.scene_attach(&scene, &camera_node.node)
	scn.scene_attach(&scene, &model_node.node)
	model_node.node.translate.y = 4
	model_node.node.scale = 4
	// scn.scene_attach(&scene, &explosion_effect_node.node)
	// scn.scene_attach(&scene, &swamp_effect_node.node)
	// scn.scene_attach(&scene, &test_effect_node.node)
	// scn.scene_attach(&scene, &cube_mesh_node.node)
	scn.scene_attach(&scene, &ground_mesh_node.node)
	if err != nil do log.error(err)
	input.input_init(&input_manager, graphics_manager.window)
	as.init_string_asset(&asset_manager, &string_asset, { "string:test-string.txt", as.String_Asset })
	assert(as.asset_commands(&asset_manager, as.String_Asset, &string_asset, { .Import, .Load }))
	// log.info(la.quaternion_from_euler_angles_f32(0, 0, 0, .XYZ))
	for ! graphics_manager.window_closed {
		time = bs.read_stopwatch(&stopwatch)
		example_dll.dev_tick(camera_node, &done_onces, time)
		dll.dl_watch(&example_dll)
		// if as.file_was_modified("example-dll/example-dll.odin", &modification_time) do log.info("Main modified.")
		as.watch_assets(&asset_manager) // TEMP
		// as.autosave(&asset_manager) // TEMP
		input.input_tick(&input_manager)
		scn.tick_scene(&scene)
		gx.graphics_tick(&graphics_manager)
		// log.info(string_asset.str)
		// gx.render_rect(&graphics_manager, r.Rect{ { 0, 0 }, { 400, 20 } }, gx.RED, 0.0)
		gx.render_image(&graphics_manager, &image, r.Rect{ { 0, 20 }, { 400, 400 } })
		if input.input_down(&input_manager, .W) do fmt.println("W")
		scn.render_scene(&graphics_manager, &scene, camera_node) }
	as.write(&asset_manager, context.allocator)
	return }

tick_camera_node :: proc(node: ^scn.Node) {
	camera_node: ^scn.Camera_Node

	scn.tick_camera_node(node)
	camera_node = scn.node_object(node, scn.Camera_Node, "node")
	// camera_node.node.translate = { 0, 0, -50 }
	// camera_node.node.rotate = la.quaternion_from_euler_angles_f32(2 * m.PI, 0, 0, .XYZ)
}

