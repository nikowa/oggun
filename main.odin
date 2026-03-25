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
import as "engine/asset_manager"
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

as_mngr: as.Asset_Manager
gx_mngr: gx.Graphics_Context
input_context: ipt.Input_Context

main :: proc() {
	context.logger = log.create_console_logger()
	bs.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^bs.Thread_Data) {
	entry: ^as.Entry
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
	as_mngr = as.make_asset_manager({
		relpath = "Data.bin",
		source_directory_relpath = "data",
		autosave_interval = as.DEFAULT_AUTOSAVE_INTERVAL,
		autosave_cap = as.DEFAULT_AUTOSAVE_CAP }, context.allocator)
	gx.graphics_init(&gx_mngr, &as_mngr, "Willow")
	image, _ = gx.import_or_retreive_image(&as_mngr, "image:kitten", context.allocator)
	model, err = gx.load_model(as.relpath_to_path("data/castle.glb", context.allocator), "model:castle", context.allocator)
	gx.upload_model(&model)
	gx.init_effect(&effect, { "effect:explosion", { { 64, 64 }, { 16, 16 } } }, &gx_mngr, &as_mngr, "string:veffect-explosion.glsl", "string:feffect-explosion.glsl", context.allocator)
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
	for ! gx_mngr.window_closed {
		time = bs.read_stopwatch(&stopwatch)
		example_dll.dev_tick(camera_node, time)
		dll.watch_dll(&example_dll)
		// if as.file_was_modified("example-dll/example-dll.odin", &modification_time) do log.info("Main modified.")
		// as.watch_assets(&as_mngr)
		as.autosave(&as_mngr)
		ipt.input_tick(&input_context)
		scn.tick_scene(&scene)
		gx.graphics_tick(&gx_mngr)
		// gx.render_rect(&gx_mngr, r.Rect{ { 0, 0 }, { 400, 20 } }, gx.RED, 0.0)
		// gx.render_image(&gx_mngr, &image, r.Rect{ { 0, 20 }, { 400, 400 } })
		scn.render_scene(&gx_mngr, &scene, camera_node) }
	as.write(&as_mngr, context.allocator)
	return }

tick_camera_node :: proc(node: ^scn.Node) {
	camera_node: ^scn.Camera_Node

	scn.tick_camera_node(node)
	camera_node = scn.node_object(node, scn.Camera_Node, "node")
	camera_node.node.translate = { 0, 0, -50 }
	camera_node.node.rotate = la.quaternion_from_euler_angles_f32(2 * m.PI, 0, 0, .XYZ) }
