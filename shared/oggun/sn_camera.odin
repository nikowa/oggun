#+feature using-stmt
package oggun
import "core:log"

// (TODO): Does the camera need all these fields? Perhaps refactor this into a basic camera and an extended camera.
// Camera_Ext :: struct {
//     using camera: Camera,
// }
// Every field is used by one of these three components:
// * model camera
// * effect camera
// * camera controller
// Camera (model camera)
// Extended Camera (model camera, effect camera)
// Camera Controller (model camera, effect camera, camera controller))

Camera_2D_Config :: struct {
	rect: Rect,
	rotation: f32 }

DEFAULT_CAMERA_2D_CONFIG: Camera_2D_Config : {
	rect={ { 0, 0 }, DEFAULT_WINDOW_CONFIG.size },
	rotation=0 }

sn_init_camera_2d :: proc(camera: ^Camera_2D, config: Camera_2D_Config) {
	camera.config = config
	camera.scale = camera.rect.size.y
	camera.rect_normalized = camera.rect
	camera.rect_normalized.size.x /= camera.rect.size.y
	camera.rect_normalized.size.y = 1
	camera.initial_rect = camera.rect }

sn_camera_2d_rect :: proc(camera: ^Camera_2D) -> Rect {
	return { camera.rect_normalized.position, camera.rect_normalized.size * camera.scale } }

Camera_2D :: struct {
	using config: Camera_2D_Config,
	initial_rect: Rect,
	rect_normalized: Rect,
	scale: f32,
	view_matrix: matrix[3, 3]f32,
	last_tick: uint }

Camera_Config :: struct {
	focal_length: f32,
	sensor_size: [2]f32,
	near_clip: f32,
	far_clip: f32 }

Camera :: struct {
	using config: Camera_Config,
	view_matrix: matrix[4, 4]f32,
	projection_matrix: matrix[4, 4]f32,
	camera_matrix: matrix[4, 4]f32,
	local_matrix: matrix[4, 4]f32 }

DEFAULT_CAMERA_CONFIG: Camera_Config : {
	focal_length = 2,
	sensor_size = { 1.777777777777, 1.0 },
	near_clip = 0.0,
	far_clip = 128.0 }

sn_camera_2d_tick :: proc(camera: ^Camera_2D) {
	if ! tick_safe(camera) do return
	// if camera.last_tick == engine.tick_count do return
	// camera.last_tick = engine.tick_count
	camera.rect = sn_camera_2d_rect(camera)
	camera.view_matrix =
		matrix3_rotate_f32(camera.rotation) *
		matrix3_scale_f32(1.0 / (camera.rect.size / 2)) *
		matrix3_translate_f32(- camera.rect.position) }

sn_camera_2d_map_point :: proc(camera: ^Camera_2D, dest_rect: Rect, point: [2]f32) -> [2]f32 {
	return ui_rect_interpolate_centered(dest_rect, matrix3_apply(camera.view_matrix, point)) }

sn_camera_2d_map_rect :: proc(camera: ^Camera_2D, dest_rect: Rect, rect: Rect) -> Rect {
	range := rect_range(rect)
	for i in 0 ..< 2 do range[i] = sn_camera_2d_map_point(camera, dest_rect, range[i])
	return rect_from_range(range) }

sn_camera_2d_scale :: proc(camera: ^Camera_2D) -> [2]f32 {
	return { camera.view_matrix[0][0], camera.view_matrix[1][1] } }

// 	mode:              enum { FREE, FOLLOW },
// 	control_direction: [3]f32,
// 	direction:         [3]f32,
// 	up_direction:      [3]f32,
// 	side_direction:    [3]f32,
// 	distance:          f32,
// 	zoom:              f32,
// 	speed:             f32,
// 	view_matrix:       matrix[4, 4]f32,
// 	projection_matrix: matrix[4, 4]f32,

// camera_init :: proc(camera: ^Camera, window_size: [2]int) {
// 	camera.mode = .FREE
// 	camera.position = [3]f32{ 0, 0, 4 }
// 	camera.orientation = linalg.quaternion_from_euler_angles_f32(0, 0, 0, .XYZ)
// 	camera.distance = 4
// 	camera.focal_length = 2
// 	camera.sensor_size = [2]f32{ 2 * auto_cast window_size.x / auto_cast window_size.y, 2 }
// 	camera.near_clip = 0.0
// 	camera.far_clip = 64.0
// 	camera.speed = 1.0 }


// Camera_Tick_Data :: struct {
// 	camera:  ^Locked_Struct(Camera),
// 	input:   ^Locked_Struct(Input),
// 	ui:      ^Locked_Struct(UI),
// 	physics: ^Locked_Struct(Physics),
// 	clock:   ^Locked_Struct(Clock) }
// camera_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag="job") camera_tick :: proc(data_ptr: rawptr) {
// 	// fmt.println("Camera Tick")
// 	data := cast(^Camera_Tick_Data)data_ptr
// 	defer free(data)
// 	using data
// 	lock_guard(&camera.lock)
// 	lock_guard(&clock.lock)
// 	lock_guard(&input.lock)
// 	lock_guard(&physics.lock)
// 	lock_guard(&ui.lock)
// 	switch ui.screen {
// 	case .TITLE:
// 		camera.position = { 4.902359, -6.02108, 0.190310329 }
// 		camera.direction = { -0.7208389, 0.6887648, 0.077422418 }
// 		camera.side_direction = { -0.6908385, -0.72300917, -0 }
// 		camera.up_direction = { 0.055977117, -0.053486388, 0.99699837 }
// 	case .GAME:
// 		camera.angle.x += input.mouse_delta.x * 0.0025
// 		camera.angle.y += input.mouse_delta.y * 0.0025
// 		// fmt.println(math.to_degrees(camera.angle.y), -85, 85)
// 		camera.angle.y = clamp(camera.angle.y, math.to_radians_f32(-80), math.to_radians_f32(80))
// 		controlled_orientation: quaternion128 = linalg.quaternion_from_euler_angles_f32(-camera.angle.y, 0, camera.angle.x, .XYZ)
// 		aligned_orientation: quaternion128 = linalg.quaternion_from_euler_angles_f32(0, 0, 0, .XYZ)
// 		camera.orientation = controlled_orientation
// 		switch camera.mode {
// 		case .FOLLOW:
// 			center: [3]f32
// 			switch ui.control {
// 			case .SURFER:
// 				center = physics.surfer_position + { 0, 0, 0.25 }
// 			case .SURF:
// 				center = physics.surf_position + { 0, 0, 0.35 }
// 				WAVE_SPEED : f32 : 0.70
// 				WAVE_RANGE : f32 : 64
// 				MIN_HEIGHT : f32 : 0
// 				MAX_HEIGHT : f32 : 4
// 				t1: f32 = linalg.fract(WAVE_SPEED * clock.net_time / 24)
// 				h := math.lerp(f32(MIN_HEIGHT), f32(MAX_HEIGHT), t1)
// 				wave_y := math.lerp(-f32(WAVE_RANGE) / 2, f32(WAVE_RANGE) / 2, t1) + h / 2
// 				wave_distance := max(abs(physics.surf_position.x - wave_y) - MAX_HEIGHT, 0)
// 				t := 1 - clamp(wave_distance / (2 * MAX_HEIGHT), 0, 1)
// 				center = linalg.lerp(center, [3]f32{
// 					wave_y,
// 					physics.surf_position.y,
// 					h / 2}, t)
// 				camera.orientation = linalg.quaternion_slerp_f32(controlled_orientation, aligned_orientation, t) }
// 			camera.position = center - camera.distance * camera.direction
// 		case .FREE:
// 			forward_delta:  f32 = 0.0
// 			sideward_delta: f32 = 0.0
// 			upward_delta:   f32 = 0.0
// 			frame_time: f32 = clock.frame_rate_controller.tick_period_sec
// 			if .W in input.keyboard_buttons_pressed do forward_delta  += frame_time * camera.speed
// 			if .S in input.keyboard_buttons_pressed do forward_delta  -= frame_time * camera.speed
// 			if .D in input.keyboard_buttons_pressed do sideward_delta += frame_time * camera.speed
// 			if .A in input.keyboard_buttons_pressed do sideward_delta -= frame_time * camera.speed
// 			if .E in input.keyboard_buttons_pressed do upward_delta   += frame_time * camera.speed
// 			if .Q in input.keyboard_buttons_pressed do upward_delta   -= frame_time * camera.speed
// 			camera.position += camera.direction * forward_delta
// 			camera.position += camera.side_direction * sideward_delta
// 			camera.position += camera.up_direction * upward_delta }
// 		camera.distance = clamp(camera.distance - input.scroll_delta * 0.1, 0.5, CAMERA_ZOOM_RADIUS)
// 		// NOTE: Forward looks ahead, sideward looks to the right, upward looks up. //
// 		camera.direction = ([4]f32{ 0, 1, 0, 1 } * linalg.matrix4_from_quaternion_f32(camera.orientation)).xyz
// 		camera.control_direction = ([4]f32{ 0, 1, 0, 1} * linalg.matrix4_from_quaternion_f32(controlled_orientation)).xyz
// 		camera.side_direction = linalg.vector_cross3(camera.direction, [3]f32{ 0, 0, 1 })
// 		camera.side_direction = linalg.vector_normalize(camera.side_direction)
// 		camera.up_direction = -linalg.vector_cross3(camera.direction, camera.side_direction)
// 		camera.up_direction = linalg.vector_normalize(camera.up_direction) }
// 	fovy: f32 = 2 * linalg.atan2(camera.sensor_size.y / 2, camera.focal_length)
// 	aspect: f32 = camera.sensor_size.x / camera.sensor_size.y
// 	near: f32 = camera.near_clip
// 	far: f32 = camera.far_clip
// 	rotation_matrix := linalg.matrix4_rotate_f32(- camera.angle.y, { 1, 0, 0 }) * linalg.matrix4_rotate_f32(camera.angle.x, { 0, 0, 1 })
// 	camera.view_matrix = rotation_matrix * linalg.matrix4_translate_f32(- camera.position)
// 	camera.projection_matrix = matrix4_perspective_f32(fovy = fovy, aspect = aspect, near = near, far = far)
// 	camera.camera_matrix = camera.projection_matrix * camera.view_matrix
// 	camera.local_matrix = camera.projection_matrix * rotation_matrix }


// camera_inverse_project :: proc(camera: ^Camera, screen_point: [2]int) -> [3]f32 {
// 	sensor_point: [2]f32 = { cast(f32)screen_point.x, cast(f32)screen_point.y } / (linalg.array_cast(draw.window_size, f32) / 2)
// 	point: [3]f32 = linalg.normalize([3]f32{
// 		(sensor_point.x - 0.5) * camera.sensor_size.x,
// 		(sensor_point.y - 0.5) * camera.sensor_size.y,
// 		camera.focal_length })
// 	return apply_transform(point, linalg.matrix4_rotate_f32(- camera.angle.y, { 1, 0, 0 }) * linalg.matrix4_rotate_f32(camera.angle.x, { 0, 0, 1 })) }


// // camera_matrix :: proc() {
// // 	matrix4_perspective_f32(fovy = fovy, aspect = aspect, near = near, far = far) * linalg.matrix4_rotate_f32(- camera.angle.y, { 1, 0, 0 }) * linalg.matrix4_rotate_f32(camera.angle.x, { 0, 0, 1 }) * linalg.matrix4_translate_f32(- camera.position)
// // }

