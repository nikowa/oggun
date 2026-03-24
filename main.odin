package game
import bs "engine/base"
import os "core:os"
import fmt "core:fmt"
import mem "core:mem"
import log "core:log"
import m "core:math"
import la "core:math/linalg"
import dl "core:dynlib"
import tm "core:time"
import db "engine/database"
import gx "engine/graphics"
import ipt "engine/input"
import r "engine/container/rect"
import scn "engine/scene"
import dll "engine/dll"
import msh "engine/mesh"



RO_State :: struct {
	_: u8 }

Example_DLL :: struct {
	using base: dll.DLL,
	dev_tick: proc(camera_node: ^scn.Camera_Node, time: f32) }

database: db.Database
graphics_context: gx.Graphics_Context
input_context: ipt.Input_Context

main :: proc() {
	context.logger = log.create_console_logger()
	bs.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^bs.Thread_Data) {
	entry: ^db.Entry
	ok: bool
	image: gx.Image
	model: gx.Model
	err: os.Error
	model_node: ^scn.Model_Node
	effect_node: ^scn.Effect_Node
	camera: scn.Camera
	camera_node: ^scn.Camera_Node
	mesh: msh.Mesh(3)
	mesh_node: ^scn.Mesh_Node
	scene: scn.Scene
	node_config: scn.Node_Config
	example_dll: Example_DLL
	modification_time: tm.Time
	stopwatch: tm.Stopwatch
	time: f32
	effect: gx.Effect

	context.logger = log.create_console_logger()
	bs.zero_stopwatch(&stopwatch)
	example_dll, err = dll.make_dll(Example_DLL, "example-dll/example-dll.odin")
	assert(err == nil)
	assert(example_dll.dev_tick != nil)
	database = db.make_or_read_database({
		relpath = "Data.bin",
		source_directory_relpath = "data",
		autosave_interval = db.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = db.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	gx.graphics_init(&graphics_context, &database, "Willow")
	image, _ = gx.import_or_retreive_image(&database, "image:kitten", context.allocator)
	model, err = gx.load_model(db.relpath_to_path("data/castle.glb", context.allocator), "model:castle", context.allocator)
	gx.upload_model(&model)
	effect = gx.make_effect({ "effect:explosion", { { 4, 4 }, { 16, 16 } } }, &graphics_context, &database, "shader:veffect-explosion", "shader:feffect-explosion", context.allocator)
	gx.upload_effect(&effect)
	scene = scn.make_scene("scene:castle")
	camera = scn.DEFAULT_CAMERA
	node_config = scn.DEFAULT_NODE_CONFIG
	node_config.name = "camera"
	node_config.tick_proc = tick_camera_node
	camera_node = scn.make_camera_node(node_config, &camera, context.allocator)
	model_node = scn.make_model_node(scn.default_node_config("castle"), &model, context.allocator)
	model_node.node.translate.z = -0
	effect_node = scn.make_effect_node(scn.default_node_config("effect"), &effect, context.allocator)
	mesh = msh.make_line_cube_mesh(3, context.allocator)
	msh.upload_mesh(&mesh)
	mesh_node = scn.make_mesh_node(scn.default_node_config("mesh"), &mesh, context.allocator)
	scn.scene_attach(&scene, &camera_node.node)
	scn.scene_attach(&scene, &model_node.node)
	scn.scene_attach(&scene, &effect_node.node)
	scn.scene_attach(&scene, &mesh_node.node)
	if err != nil do log.error(err)
	ipt.input_init(&input_context)
	// log.info(la.quaternion_from_euler_angles_f32(0, 0, 0, .XYZ))
	for ! graphics_context.window_closed {
		time = bs.read_stopwatch(&stopwatch)
		example_dll.dev_tick(camera_node, time)
		dll.watch_dll(&example_dll)
		// if db.file_was_modified("example-dll/example-dll.odin", &modification_time) do log.info("Main modified.")
		db.autosave(&database)
		ipt.input_tick(&input_context)
		scn.tick_scene(&scene)
		gx.graphics_tick(&graphics_context)
		// gx.render_rect(&graphics_context, r.Rect{ { 0, 0 }, { 400, 20 } }, gx.RED, 0.0)
		// gx.render_image(&graphics_context, &image, r.Rect{ { 0, 20 }, { 400, 400 } })
		scn.render_scene(&graphics_context, &scene, camera_node) }
	db.write(&database, context.allocator)
	return }

tick_camera_node :: proc(node: ^scn.Node) {
	camera_node: ^scn.Camera_Node

	scn.tick_camera_node(node)
	camera_node = scn.node_object(node, scn.Camera_Node, "node")
	camera_node.node.translate = { 0, 0, -50 }
	camera_node.node.rotate = la.quaternion_from_euler_angles_f32(2 * m.PI, 0, 0, .XYZ) }
