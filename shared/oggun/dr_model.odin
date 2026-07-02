#+feature using-stmt
package oggun
import "base:runtime"
import "base:intrinsics"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:strings"
import "core:os"
import "core:math/linalg"
import "core:time"
import "core:log"
import "core:fmt"
import "core:math"
import "core:mem"
import "core:slice"

// "Element" is the general term for an object that contains the state of an element that complies with the multi-modal state pattern.

Scene_Element :: struct {
	camera: Camera,
	haze_color: Color,
	transformer: Transformer,
	transform: Transform,
	visible: bool }

// DEFAULT_SCENE_ELEMENT: Scene_Element : { } // (TODO)

Scene_Element_Param :: struct {
	id: enum {
		CAMERA,
		HAZE_COLOR,
		TRANSFORMER,
		TRANSFORM,
		VISIBLE },
	value: struct #raw_union {
		camera: Camera,
		haze_color: Color,
		transformer: Transformer,
		transform: Transform,
		visible: bool } }

// (TODO): This will cache the last node, to save itseslf some work.
scene_element_from_node :: proc(node: ^Tree_Node(Scene_Element_Param, u16)) -> (scene_element: Scene_Element) {
	// scene_element = DEFAULT_SCENE_ELEMENT
	// curr := node
	// for {
	// 	// curr = tree_node_parent(node) or_break
	// 	// camera := curr.(camera) or_continue
	// 	// scene_element.camera = camera
	// }
	// curr = node
	return {}
}

dr_model_trm :: proc(node: ^Tree_Node(Scene_Element_Param, u16), model: ^Model) {
	_dr_model_im(scene_element_from_node(node), model) }

// (TODO): This should have a nice API with only the necessary parameters. //
dr_model_im :: proc(element: Scene_Element, model: ^Model) {
	_dr_model_im(element, model) }

_dr_model_im :: proc(element: Scene_Element, model: ^Model) {
	using Model_Shader_Uniforms
	element := element
	use_shader(&engine.graphics_manager.model_shader)
	set_shader_param(MODEL_MATRIX, &element.transformer.total)
	set_shader_param(CAMERA_POSITION_MATRIX, &element.camera.view_matrix)
	set_shader_param(CAMERA_PROJECTION_MATRIX, &element.camera.projection_matrix)
	set_shader_param(CAMERA_FAR_CLIP, element.camera.far_clip)
	set_shader_param(CAMERA_POSITION, [3]f32{ 0, 0, 0 })
	set_shader_param(HAZE_COLOR, element.haze_color)
	// set_shader_param(shader.metallic_factor, element.material.metallic_factor)
	// set_shader_param(shader.roughness_factor, element.material.roughness_factor)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.positions_handle)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.texcoords_handle)
	gl.VertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(1)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.normals_handle)
	gl.VertexAttribPointer(2, 3, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(2)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.lightmap_texcoords_handle)
	gl.VertexAttribPointer(3, 2, gl.FLOAT, gl.FALSE, 0, 0)
	gl.EnableVertexAttribArray(3)
	polygon_mode(.Fill)
	gl.Enable(gl.CULL_FACE)
	// // bind_texture(0,draw.textures["dev-grid"].handle)
	// bind_texture(0, element.material.base_color_texture.handle)
	// // bind_texture(1, element.triangles_map.handle)
	// bind_texture(1, element.thickness_map.handle)
	// bind_texture(2, model_instance.world_position_map.handle)
	// bind_texture(3, draw.textures_map["skybox"].handle)
	render_triangles(cast(i32)(len(model.positions) * 3)) }
