#+feature using-stmt
package scene
import rt "base:runtime"
import log "core:log"
import la "core:math/linalg"
import gl "vendor:OpenGL"
import gx "../graphics"
import msh "../mesh"



Mesh_Node :: struct {
	node: Node,
	using mesh: ^msh.Mesh(3) }

// (TODO): Add a make_and_attach function.
make_mesh_node :: proc(node_config: Node_Config, mesh: ^msh.Mesh(3), allocator: rt.Allocator) -> (mesh_node: ^Mesh_Node) {
	mesh_node = make_derived_node(Mesh_Node, node_config, render_mesh_node, nil, allocator)
	mesh_node.mesh = mesh
	return mesh_node }

render_mesh_node :: proc(graphics_context: ^gx.Graphics_Context, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	using gx.Mesh_Shader_Uniforms
	assert(graphics_context != nil)
	assert(node != nil)
	mesh_node := node_object(node, Mesh_Node, "node")
	assert(mesh_node.verts_handle != 0)
	gx.use_shader(&graphics_context.mesh_shader)
	translate_matrix, rotate_matrix, scale_matrix, transform_matrix := node_transforms(&mesh_node.node)
	gx.set_shader_param(NODE_MATRIX, &transform_matrix)
	gx.set_shader_param(CAMERA_POSITION_MATRIX, &camera_node.view_matrix)
	gx.set_shader_param(CAMERA_PROJECTION_MATRIX, &camera_node.projection_matrix)
	gx.set_shader_param(CAMERA_FAR_CLIP, camera_node.far_clip)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh_node.verts_handle)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(0)
	gx.polygon_mode(.Line)
	gl.Disable(gl.CULL_FACE)
	gx.draw_lines(cast(i32)(len(mesh_node.verts) * 3)) }
