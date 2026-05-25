#+feature using-stmt
package willow
import "base:runtime"
import gl "vendor:OpenGL"

Model_Node :: struct {
	node: Node,
	using model: ^Model }

make_model_node :: proc(node_config: Node_Config, model: ^Model, allocator: runtime.Allocator) -> (model_node: ^Model_Node) {
	model_node = make_derived_node(Model_Node, node_config, render_model_node, nil, allocator)
	model_node.model = model
	return model_node }

render_model_node :: proc(graphics_context: ^Graphics_Manager, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	using Model_Shader_Uniforms
	assert(graphics_context != nil)
	assert(node != nil)
	model_node := node_object(node, Model_Node, "node")
	use_shader(&graphics_context.model_shader)
	translate_matrix, rotate_matrix, scale_matrix, node_matrix := node_transforms(&model_node.node)
	set_shader_param(MODEL_MATRIX, &node_matrix)
	set_shader_param(CAMERA_POSITION_MATRIX, &camera_node.view_matrix)
	set_shader_param(CAMERA_PROJECTION_MATRIX, &camera_node.projection_matrix)
	set_shader_param(CAMERA_FAR_CLIP, camera_node.far_clip)
	set_shader_param(CAMERA_POSITION, camera_node.node.translate)
	set_shader_param(HAZE_COLOR, scene.haze_color)
	// set_shader_param(shader.metallic_factor, model_node.material.metallic_factor)
	// set_shader_param(shader.roughness_factor, model_node.material.roughness_factor)
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
	polygon_mode(.Fill)
	gl.Enable(gl.CULL_FACE)
	// // bind_texture(0,draw.textures["dev-grid"].handle)
	// bind_texture(0, model_node.material.base_color_texture.handle)
	// // bind_texture(1, model_node.triangles_map.handle)
	// bind_texture(1, model_node.thickness_map.handle)
	// bind_texture(2, model_instance.world_position_map.handle)
	// bind_texture(3, draw.textures_map["skybox"].handle)
	render_triangles(cast(i32)(len(model_node.positions) * 3)) }

// model_node_bake_position :: proc(graphics_manager: ^Graphics_Manager, node: ^Model_Node, size: [2]int) {
// 	texture_size:     [2]int
// 	iterator:         Texel_Iterator
// 	texture_name:     string
// 	texture_filename: string
// 	ok:               bool
// 	bytes:            []u8
// 	error:            os.Error
// 	filepath:         string

// 	fmt.println(LOG, "Baking world-position-map for instance of model", node.name)
// 	texture = &model_instance.world_position_map
// 	texture_name = fmt.aprintf("%s-%s", model_instance.name, "world-position")
// 	texture^, ok = generic_texture_search_and_remove(draw, texture_name)
// 	texture_filename = fmt.aprintf("%s.qoi", texture_name)

// 	init_texture_from_description(draw, texture, texture_name, size, 3, 8)
// 	texture_size = { model_instance.world_position_map.width, model_instance.world_position_map.height }
// 	iterator = make_texel_iterator(model, model_instance.transform, texture_size)
// 	for texel in texel_iterate_next(&iterator) {
// 		pixel: ^[3]u8 = texture_pixel_from_position(texture, texel.position, [3]u8)
// 		// /*if bary_inside(texel.bary) do*/ pixel^ = rgb_denormalize(0.02 * texel.point)
// 		/*if bary_inside(texel.bary) do*/ pixel^ = rgb_denormalize(0.5 * (texel.normal + 1))
// 		// if bary_inside(texel.bary) do pixel^ = rgb_denormalize(texel.bary)
// 		// if bary_inside(texel.bary) do pixel^ = rgb_denormalize({ texel.uv_point.x, texel.uv_point.y, 0 })
// 		// if bary_inside(texel.bary) do pixel^ = rgb_denormalize(texel.triangle[2])
// 		// pixel^.x = u8_denormalize(cast(f32)(texel.triangle_index % 8) / 8)
// 	}
// 	cache_write(fmt.aprintf("%s.qoi", texture_name), texture_to_qoi(texture))
// 	load_texture(draw, texture) }
