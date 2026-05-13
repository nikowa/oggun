#+feature using-stmt
package willow



// TODO: Is this necessary? Should I just use a generic Tree node for this? Like the scene tree.

// Model_Instance :: struct {
// 	name: string,
// 	model: ^Model,
// 	world_position_map: Texture,
// 	transform_translate: matrix[4, 4]f32,
// 	transform_rotate: matrix[4, 4]f32,
// 	transform_scale: matrix[4, 4]f32,
// 	transform: matrix[4, 4]f32 }

// model_instance_position :: proc(model_instance: ^Model_Instance, point_index: int) -> (position: [3]f32) {
// 	STRIDE :: 3
// 	model := model_instance.model
// 	position = {
// 		model.positions[point_index * STRIDE + 0],
// 		model.positions[point_index * STRIDE + 1],
// 		model.positions[point_index * STRIDE + 2] }
// 	position = (model_instance.transform * [4]f32{ position.x, position.y, position.z, 1 }).xyz
// 	return position }

// model_instance_normal :: proc(model_instance: ^Model_Instance, point_index: int) -> (normal: [3]f32) {
// 	STRIDE :: 3
// 	model := model_instance.model
// 	normal = {
// 		model.normals[point_index * STRIDE + 0],
// 		model.normals[point_index * STRIDE + 1],
// 		model.normals[point_index * STRIDE + 2] }
// 	normal = (model_instance.transform_rotate * [4]f32{ normal.x, normal.y, normal.z, 1 }).xyz
// 	return normal }

// model_instance_texcoord :: proc(model_instance: ^Model_Instance, point_index: int) -> (texcoord: [2]f32) {
// 	STRIDE :: 2
// 	model := model_instance.model
// 	texcoord = {
// 		model.texcoords[point_index * STRIDE + 0],
// 		model.texcoords[point_index * STRIDE + 1] }
// 	return texcoord }

// render_all_model_instances :: proc(draw: ^Draw, camera: ^Camera) {
// 	for _, i in draw.model_instances do render_model_instance(draw, camera, &draw.model_instances[i]) }
