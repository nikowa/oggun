package dev_dll
import rt "base:runtime"
import fmt "core:fmt"
import log "core:log"
import m "core:math"
import la "core:math/linalg"
import scn "../engine/scene"
import bs "../engine/base"
// (NOTE): It is recommended that the game's types are put in a separate package, so you can include them here, without including
// everything else.



@(export)
dev_tick :: proc(camera_node: ^scn.Camera_Node, done_onces: ^map[rt.Source_Code_Location]bool, time: f32) {
	arm_length: f32 = 50.0
	yaw, pitch: f32 = 0.0, 0.0
	distance: f32
	rotate_matrix: matrix[4, 4]f32
	pitch = 0.1 * la.sin(4 * time)
	pitch = -0.8 * m.PI
	yaw = 0.1 * time
	distance = 12.0
	yaw = 0.0
	distance = 12.0

	// Debug //
	// pitch = 0.4 * time
	distance = 8.0

	if bs.once(done_onces) { fmt.println("Done again!") }
	camera_node.node.translate = - distance * ([4]f32{ 0, 0, 1, 1 } * la.matrix4_from_euler_angles_f32(pitch, 0, yaw, .XYZ)).xyz
	camera_node.node.rotate = la.quaternion_from_euler_angles_f32(pitch, 0, yaw, .XYZ)
	// camera_node.node.translate.z = 50
	// camera_node.node.rotate = la.quaternion_from_euler_angles_f32(pitch, 0, yaw, .XYZ)
}
