#+feature using-stmt
package camera
import "core:fmt"
import "core:math"
import "core:math/linalg"


Cubemap_Camera_Iterator :: struct {
	position:  [3]f32,
	direction: Cubemap_Direction }


make_cubemap_camera_iterator :: proc(position: [3]f32) -> Cubemap_Camera_Iterator { return { position = position } }


cubemap_camera_iterate_next :: proc(iterator: ^Cubemap_Camera_Iterator) -> (Camera, Cubemap_Direction, bool) {
	camera:    Camera
	direction: Cubemap_Direction
	ok:        bool

// Camera :: struct {
// 	mode:              enum { FREE, FOLLOW },
// 	position:          [3]f32,
// 	angle:             [2]f32,
// 	orientation:       quaternion128,
// 	control_direction: [3]f32,
// 	direction:         [3]f32,
// 	up_direction:      [3]f32,
// 	side_direction:    [3]f32,
// 	focal_length:      f32,
// 	sensor_size:       [2]f32,
// 	distance:          f32,
// 	zoom:              f32,
// 	near_clip:         f32,
// 	far_clip:          f32,
// 	speed:             f32,
// 	view_matrix:       matrix[4, 4]f32,
// 	projection_matrix: matrix[4, 4]f32,
// 	camera_matrix:     matrix[4, 4]f32,
// 	local_matrix:      matrix[4, 4]f32 }

	direction = iterator.direction
	x_ax: [3]f32 = { 1, 0, 0 }
	z_ax: [3]f32 = { 0, 0, 1 }
	// camera.projection_matrix = matrix4_perspective_f32(math.to_radians_f32(90), 1.0, 0.0, 64.0)
	fovy: f32 = math.PI / 2
	aspect: f32 = 1.0
	camera.projection_matrix = linalg.matrix4_infinite_perspective_f32(fovy = fovy, aspect = aspect, near = 0.0, flip_z_axis = true)
	camera.projection_matrix = matrix4_perspective_f32(fovy = fovy, aspect = aspect, near = 0.0, far = 64.0)
	camera.near_clip = 0.0
	camera.far_clip = 64.0
	camera.position = iterator.position
	switch iterator.direction {
	case .UP:
		camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), x_ax)
	// 	camera.view_matrix = linalg.MATRIX4F32_IDENTITY
	case .DOWN:
		camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(90), x_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-180), x_ax)
	case .LEFT:
		camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), z_ax)
	case .RIGHT:
		camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(90), z_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), x_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(180), z_ax) * camera.view_matrix
	case .BACK:
		camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-180), z_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), x_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), z_ax) * camera.view_matrix
	case .FRONT:
		camera.view_matrix = linalg.MATRIX4F32_IDENTITY
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(-90), x_ax)
	// 	camera.view_matrix = linalg.matrix4_rotate_f32(math.to_radians_f32(90), z_ax) * camera.view_matrix
	case: return {}, direction, false }
	camera.view_matrix = camera.view_matrix * linalg.matrix4_translate_f32(- iterator.position)
	iterator.direction = cast(Cubemap_Direction)(cast(u8)iterator.direction + 1)
	return camera, direction, true }

