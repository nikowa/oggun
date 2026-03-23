package dev_dll
import log "core:log"
import m "core:math"
import la "core:math/linalg"
import scn "../engine/scene"
// (NOTE): It is recommended that the game's types are put in a separate package, so you can include them here, without including
// everything else.



@(export)
dev_tick :: proc(camera_node: ^scn.Camera_Node, time: f32) {
	arm_length: f32 = 50.0
	yaw, pitch: f32 = 0.0, 0.0
	rotate_matrix: matrix[4, 4]f32
	pitch = 0.1 * la.sin(4 * time)
	pitch = 0.4 * time
	yaw = 0.3 * time
	pitch = m.PI
	yaw = 0.0

	// camera_node.node.translate = - 64 * ([4]f32{ 0, 0, 1, 1 } * la.matrix4_from_euler_angles_f32(pitch, 0, yaw, .XYZ)).xyz
	// camera_node.node.rotate = la.quaternion_from_euler_angles_f32(pitch, 0, yaw, .XYZ)
	camera_node.node.translate.z = 100
	camera_node.node.rotate = la.quaternion_from_euler_angles_f32(pitch, 0, yaw, .XYZ)
}
