package dev_dll
import log "core:log"
import scn "../engine/scene"
// (NOTE): It is recommended that the game's types are put in a separate package, so you can include them here, without including
// everything else.



@(export)
dev_tick :: proc(camera_node: ^scn.Camera_Node) {
	camera_node.node.translate.x = 0
}
