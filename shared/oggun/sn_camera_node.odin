package oggun
import "base:runtime"
import "core:math/linalg"

Camera_Node :: struct {
	node: Node,
	using camera: ^Camera }

make_camera_node :: proc(node_config: Node_Config, camera: ^Camera, allocator: runtime.Allocator) -> (camera_node: ^Camera_Node) {
	camera_node = make_derived_node(Camera_Node, node_config, render_camera_node, tick_camera_node, allocator)
	camera_node.camera = camera
	return camera_node }

// (NODE): The camera node's render proc is the only one that should be called directly, unless you're not using any cameras,
// because it will render everything.
render_camera_node :: proc(scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	tree_iterator: Scene_Tree_Iterator

	assert(scene != nil)
	assert(camera_node == nil)
	assert(node != nil)
	tree_iterator = tree_iterator_root(&scene.tree)
	for other_node in tree_iterate_next(&tree_iterator) {
		if other_node == node do continue
		render_node(scene, node_object(node, Camera_Node, "node"), other_node) } }

tick_camera_node :: proc(node: ^Node) {
	camera_node: ^Camera_Node
	fovy, aspect, near, far: f32
	rotation_matrix: matrix[4, 4]f32

	camera_node = node_object(node, Camera_Node, "node")
	fovy = 2 * linalg.atan2(camera_node.sensor_size.y / 2, camera_node.focal_length)
	aspect = camera_node.sensor_size.x / camera_node.sensor_size.y
	near = camera_node.near_clip
	far = camera_node.far_clip
	rotation_matrix = linalg.matrix4_from_quaternion_f32(camera_node.node.rotate)
	camera_node.view_matrix = rotation_matrix * linalg.matrix4_translate_f32(- camera_node.node.translate)
	camera_node.projection_matrix = linalg.matrix4_perspective_f32(fovy = fovy, aspect = aspect, near = near, far = far, flip_z_axis = false) // Maybe flip the z axis?
	camera_node.projection_matrix = linalg.matrix_ortho3d_f32(left = - camera_node.sensor_size.x / 2, right = camera_node.sensor_size.x / 2, bottom = -camera_node.sensor_size.y / 2, top = camera_node.sensor_size.y / 2, near = near, far = far, flip_z_axis = false)
	camera_node.camera_matrix = camera_node.projection_matrix * camera_node.view_matrix
	camera_node.local_matrix = camera_node.projection_matrix * rotation_matrix }

matrix4_perspective_f32 :: proc(fovy, aspect, near, far: f32) -> (m: matrix[4, 4]f32) {
	X :: 0
	Y :: 1
	Z :: 2
	W :: 3
	tan_half_fovy := linalg.tan(0.5 * fovy)
	m[X, X] = 1 / (aspect * tan_half_fovy)
	m[Y, Z] = 1 / (tan_half_fovy)
	m[Z, Y] = + (far + near) / (far - near)
	m[W, Y] = + 1
	m[Z, W] = -2 * far * near / (far - near)
	m[Z] = m[Z]
	return }
