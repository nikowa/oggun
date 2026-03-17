#+feature using-stmt
package graphics
import fmt "core:fmt"
import os "core:os"
import gl "vendor:OpenGL"



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


// model_instance_bake_world_position_map :: proc(draw: ^Draw, cache: ^Cache, model_instance: ^Model_Instance, size: [2]int) {
// 	model:            ^Model
// 	texture:          ^Texture
// 	texture_size:     [2]int
// 	iterator:         Texel_Iterator
// 	texture_name:     string
// 	texture_filename: string
// 	ok:               bool
// 	bytes:            []u8
// 	error:            os.Error
// 	filepath:         string

// 	fmt.println(LOG, "Baking world-position-map for instance of model", model_instance.name)
// 	model = model_instance.model
// 	texture = &model_instance.world_position_map
// 	texture_name = fmt.aprintf("%s-%s", model_instance.name, "world-position")
// 	texture^, ok = generic_texture_search_and_remove(draw, texture_name)
// 	texture_filename = fmt.aprintf("%s.qoi", texture_name)

// 	if texture_filename in cache.files {
// 		fmt.printfln("%s World-position-map for instance %s is already baked. Loading from cache.", model_instance.name)
// 		filepath, error = os.join_path({ working_directory_path, "data", "cache", texture_filename }, context.allocator); assert(error == nil)
// 		bytes, error = os.read_entire_file_from_path(filepath, context.allocator); assert(error == nil)
// 		ok = init_texture_from_qoi(draw, texture, texture_name, bytes); assert(ok) }
// 	else {
// 		init_texture_from_description(draw, texture, texture_name, size, 3, 8)
// 		texture_size = { model_instance.world_position_map.width, model_instance.world_position_map.height }
// 		iterator = make_texel_iterator(model, model_instance.transform, texture_size)
// 		for texel in texel_iterate_next(&iterator) {
// 			pixel: ^[3]u8 = texture_pixel_from_position(texture, texel.position, [3]u8)
// 			// /*if bary_inside(texel.bary) do*/ pixel^ = rgb_denormalize(0.02 * texel.point)
// 			/*if bary_inside(texel.bary) do*/ pixel^ = rgb_denormalize(0.5 * (texel.normal + 1))
// 			// if bary_inside(texel.bary) do pixel^ = rgb_denormalize(texel.bary)
// 			// if bary_inside(texel.bary) do pixel^ = rgb_denormalize({ texel.uv_point.x, texel.uv_point.y, 0 })
// 			// if bary_inside(texel.bary) do pixel^ = rgb_denormalize(texel.triangle[2])
// 			// pixel^.x = u8_denormalize(cast(f32)(texel.triangle_index % 8) / 8)
// 	} }
// 	cache_write(fmt.aprintf("%s.qoi", texture_name), texture_to_qoi(texture))
// 	load_texture(draw, texture) }

