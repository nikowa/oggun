#+feature using-stmt
package scene
import rt "base:runtime"
import log "core:log"
import la "core:math/linalg"
import m "core:math"
import gl "vendor:OpenGL"
import gx "../graphics"



Effect_Node :: struct {
	node: Node,
	using effect: ^gx.Effect }

make_effect_node :: proc(node_config: Node_Config, effect: ^gx.Effect, allocator: rt.Allocator) -> (effect_node: ^Effect_Node) {
	effect_node = make_derived_node(Effect_Node, node_config, render_effect_node, nil, allocator)
	effect_node.effect = effect
	return effect_node }

render_effect_node :: proc(graphics_context: ^gx.Graphics_Context, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	using gx.Effect_Shader_Uniforms
	// (TODO): Render a bounding box. Effect must be bound to the bounding box.
	assert(graphics_context != nil)
	assert(node != nil)
	effect_node := node_object(node, Effect_Node, "node")
	assert(gx.effect_is_uploaded(effect_node.effect))
	gx.use_shader(&effect_node.shader)
	translate_matrix, rotate_matrix, scale_matrix, transform_matrix := node_transforms(&effect_node.node)
	gx.set_shader_param(NODE_MATRIX, &transform_matrix)
	gx.set_shader_param(CAMERA_POSITION_MATRIX, &camera_node.view_matrix)
	gx.set_shader_param(CAMERA_PROJECTION_MATRIX, &camera_node.projection_matrix)
	gx.set_shader_param(CAMERA_FAR_CLIP, camera_node.far_clip)
	gx.set_shader_param(TIME, graphics_context.time)
	// (TODO): How is this a different camera node from the camera node set in the DLL?
	gx.set_shader_param(CAMERA_POSITION, camera_node.node.translate)
	// log.info(camera_node.node.translate)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect_node.mesh.verts_handle)
	gl.VertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect_node.mesh.surface_indexes_handle)
	gl.VertexAttribPointer(1, 1, gl.INT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(1)
	gx.polygon_mode(.Fill)
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	gl.Disable(gl.CULL_FACE)
	gx.draw_triangles(cast(i32)(len(effect_node.mesh.verts) * 2)) }
