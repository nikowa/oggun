package scene
import rt "base:runtime"
import log "core:log"
import la "core:math/linalg"
import m "core:math"
import gx "../graphics"



Camera_Node :: struct {
	node: Node,
	using camera: ^Camera }

make_camera_node :: proc(node_config: Node_Config, camera: ^Camera, allocator: rt.Allocator) -> (camera_node: ^Camera_Node) {
	camera_node = new(Camera_Node, allocator)
	init_node(&camera_node.node, node_config)
	camera_node.node.render_proc = render_camera_node
	camera_node.node.tick_proc = tick_camera_node
	camera_node.camera = camera
	return camera_node }

// (NODE): The camera node's render proc is the only one that should be called directly, unless you're not using any cameras,
// because it will render everything.
render_camera_node :: proc(graphics_context: ^gx.Graphics_Context, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	tree_iterator: Tree_Iterator

	assert(graphics_context != nil)
	assert(scene != nil)
	assert(camera_node == nil)
	assert(node != nil)
	tree_iterator = tree_iterator_root(&scene.tree)
	for other_node in tree_iterate_next(&tree_iterator) {
		if other_node == node do continue
		render_node(graphics_context, scene, node_object(node, Camera_Node, "node"), other_node) } }

tick_camera_node :: proc(node: ^Node) {
	camera_node: ^Camera_Node
	fovy, aspect, near, far: f32
	rotation_matrix: matrix[4, 4]f32

	camera_node = node_object(node, Camera_Node, "node")
	camera_node.node.translate = { 0, 0, -50 }
	fovy = 2 * la.atan2(camera_node.sensor_size.y / 2, camera_node.focal_length)
	aspect = camera_node.sensor_size.x / camera_node.sensor_size.y
	near = camera_node.near_clip
	far = camera_node.far_clip
	// rotation_matrix = la.matrix4_rotate_f32(- camera_node.angle.y, { 1, 0, 0 }) * la.matrix4_rotate_f32(camera_node.angle.x, { 0, 0, 1 })
	camera_node.view_matrix = /*rotation_matrix * */la.matrix4_translate_f32(- camera_node.node.translate)
	camera_node.projection_matrix = la.matrix4_perspective_f32(fovy = fovy, aspect = aspect, near = near, far = far, flip_z_axis = false) // Maybe flip the z axis?
	camera_node.camera_matrix = camera_node.projection_matrix * camera_node.view_matrix
	camera_node.local_matrix = camera_node.projection_matrix * rotation_matrix }

matrix4_perspective_f32 :: proc(fovy, aspect, near, far: f32) -> (m: matrix[4, 4]f32) {
	X :: 0
	Y :: 1
	Z :: 2
	W :: 3
	tan_half_fovy := la.tan(0.5 * fovy)
	m[X, X] = 1 / (aspect * tan_half_fovy)
	m[Y, Z] = 1 / (tan_half_fovy)
	m[Z, Y] = + (far + near) / (far - near)
	m[W, Y] = + 1
	m[Z, W] = -2 * far * near / (far - near)
	m[Z] = m[Z]
	return }
