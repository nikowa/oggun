package scene
import rt "base:runtime"
import log "core:log"
import la "core:math/linalg"
import gl "vendor:OpenGL"
import gx "../graphics"



Model_Node :: struct {
	node: Node,
	using model: ^gx.Model }

make_model_node :: proc(node_config: Node_Config, model: ^gx.Model, allocator: rt.Allocator) -> (model_node: ^Model_Node) {
	model_node = new(Model_Node, allocator)
	init_node(&model_node.node, node_config)
	model_node.node.render_proc = render_model_node
	model_node.model = model
	return model_node }

render_model_node :: proc(graphics_context: ^gx.Graphics_Context, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	model_node: ^Model_Node
	translate_matrix: matrix[4, 4]f32
	rotate_matrix: matrix[4, 4]f32
	scale_matrix: matrix[4, 4]f32
	transform_matrix: matrix[4, 4]f32

	assert(graphics_context != nil)
	assert(graphics_context.model_shader != nil)
	assert(node != nil)


	model_node = node_object(node, Model_Node, "node")
	shader := gx.use_shader(graphics_context.model_shader)
	translate_matrix = la.matrix4_translate_f32(model_node.node.translate)
	rotate_matrix = la.matrix4_rotate_f32(model_node.node.rotate.x, { 1, 0, 0 }) *
		la.matrix4_rotate_f32(model_node.node.rotate.y, { 0, 1, 0 }) *
		la.matrix4_rotate_f32(model_node.node.rotate.z, { 0, 0, 1 })
	scale_matrix = la.matrix4_scale_f32(model_node.node.scale)
	transform_matrix = translate_matrix * rotate_matrix * scale_matrix
	gx.set_shader_param(shader.model_matrix, &transform_matrix)
	gx.set_shader_param(shader.camera_position_matrix, &camera_node.view_matrix)
	gx.set_shader_param(shader.camera_projection_matrix, &camera_node.projection_matrix)
	gx.set_shader_param(shader.camera_far_clip, camera_node.far_clip)
	gx.set_shader_param(shader.camera_position, camera_node.node.translate)
	gx.set_shader_param(shader.haze_color, scene.haze_color)
	// gx.set_shader_param(shader.metallic_factor, model_node.material.metallic_factor)
	// gx.set_shader_param(shader.roughness_factor, model_node.material.roughness_factor)
	gl.BindBuffer(gl.ARRAY_BUFFER, model_node.positions_handle)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, model_node.texcoords_handle)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(1)
	gl.BindBuffer(gl.ARRAY_BUFFER, model_node.normals_handle)
	gl.VertexAttribPointer(2, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(2)
	gl.BindBuffer(gl.ARRAY_BUFFER, model_node.lightmap_texcoords_handle)
	gl.VertexAttribPointer(3, 2, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(3)
	gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL)
	// // bind_texture(0,draw.textures["dev-grid"].handle)
	// bind_texture(0, model_node.material.base_color_texture.handle)
	// // bind_texture(1, model_node.triangles_map.handle)
	// bind_texture(1, model_node.thickness_map.handle)
	// bind_texture(2, model_instance.world_position_map.handle)
	// bind_texture(3, draw.textures_map["skybox"].handle)
	gx.draw_triangles(cast(i32)(len(model_node.positions) * 3)) }
