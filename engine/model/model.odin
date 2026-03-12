#+feature using-stmt
package model
import rt "base:runtime"
import fmt "core:fmt"
import os "core:os"
import sl "core:slice"
import m "core:math"
import la "core:math/linalg"
import mem "core:mem"
import fp "core:path/filepath"
import gl "vendor:OpenGL"
import gltf "shared:gltf2"



Model :: struct {
	arena: mem.Arena,
	name: string,
	visible: bool,
	positions_handle: u32,
	normals_handle: u32,
	texcoords_handle: u32,
	lightmap_texcoords_handle: u32,
	positions: [dynamic]f32,
	normals: [dynamic]f32,
	texcoords: [dynamic]f32,
	lightmap_texcoords: [dynamic]f32,
	material: ^Material,
	triangles_map: Texture,
	thickness_map: Texture }



model_position :: proc(model: ^Model, point_index: int) -> (position: [3]f32) {
	STRIDE :: 3; return { model.positions[point_index * STRIDE + 0], model.positions[point_index * STRIDE + 1], model.positions[point_index * STRIDE + 2] } }


model_normal :: proc(model: ^Model, point_index: int) -> (normal: [3]f32) {
	STRIDE :: 3; return { model.normals[point_index * STRIDE + 0], model.normals[point_index * STRIDE + 1], model.normals[point_index * STRIDE + 2] } }


model_texcoord :: proc(model: ^Model, point_index: int) -> (texcoord: [2]f32) {
	STRIDE :: 2; return { model.texcoords[point_index * STRIDE + 0], model.texcoords[point_index * STRIDE + 1] } }


MODEL_MEMORY_CAP :: 16 * rt.Megabyte


new_model :: proc() -> Model {
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, MODEL_MEMORY_CAP))
	assert(len(arena.data) == MODEL_MEMORY_CAP)
	return Model{ arena = arena } }


// Before QOI: 2.5 sec. //
load_models_from_gltf :: proc(draw: ^Draw, working_directory_path: string, name: string) {
	filename := fp.join({ working_directory_path, MODELS_PATH_RELATIVE, fmt.aprintf("%s.glb", name) })
	os_error: os.Error
	if ! os.exists(filename) { panic(fmt.tprintf("Couldn't find %s.", filename)) }
	draw.last_models_write_time, os_error = os.last_write_time_by_name(filename)
	assert(os_error == nil)
	data, error := gltf.load_from_file(filename)
	instances_counter: map[string]int = make_map(map[string]int, context.allocator)
	switch err in error {
	case gltf.JSON_Error: if err.type != .None do panic(fmt.aprint(err))
	case gltf.GLTF_Error: panic(fmt.aprint(err)) }
	for node in data.nodes {
		node_name := node.name.?
		mesh := data.meshes[node.mesh.?]
		mesh_name, ok := mesh.name.?
		assert(ok)
		fmt.println(LOG, "Loading mesh", mesh_name)
		model: ^Model
		if mesh_name in draw.models_map {
			fmt.println(LOG, "Mesh exists. Creating instance.")
			model = draw.models_map[mesh_name] }
		else {
			append(&draw.models, new_model())
			model = &draw.models[len(draw.models) - 1]
			model_allocator := mem.arena_allocator(&model.arena)
			model.name = mesh_name
			model.visible = true
			draw.models_map[model.name] = model
			assert((len(mesh.primitives) == 1) && mesh.primitives[0].mode == .Triangles)
			primitive := &mesh.primitives[0]
			assert(primitive.mode == .Triangles)
			assert("POSITION" in primitive.attributes)
			assert("NORMAL" in primitive.attributes)
			assert("TEXCOORD_0" in primitive.attributes)
			position_accessor := primitive.attributes["POSITION"] // VEC3 float
			normal_accessor := primitive.attributes["NORMAL"] // VEC3 float
			texcoord_accessor := primitive.attributes["TEXCOORD_0"] // VEC2 float
			lightmap_texcoord_accessor := primitive.attributes["TEXCOORD_1"] // VEC2 float
			// (TODO): Use TEXCOORD_1 for a lightmap UV-map.
			assert(data.accessors[position_accessor].normalized == false)
			assert(data.accessors[normal_accessor].normalized == false)
			assert(data.accessors[texcoord_accessor].normalized == false)
			assert(data.accessors[lightmap_texcoord_accessor].normalized == false)
			assert(primitive.indices != nil)
			indices_accessor := primitive.indices.?
			model.positions = make([dynamic]f32, allocator = model_allocator)
			model.normals = make([dynamic]f32, allocator = model_allocator)
			model.texcoords = make([dynamic]f32, allocator = model_allocator)
			model.lightmap_texcoords = make([dynamic]f32, allocator = model_allocator)
			positions_data: [][3]f32
			normals_data: [][3]f32
			texcoords_data: [][2]f32
			lightmap_texcoords_data: [][2]f32
			indices_data: []u16
			positions_data, ok = gltf.buffer_slice(data,position_accessor).([][3]f32); assert(ok)
			fmt.println(LOG, "Vertex data address:", cast(rawptr)&positions_data[0])
			normals_data, ok = gltf.buffer_slice(data,normal_accessor).([][3]f32); assert(ok)
			texcoords_data, ok = gltf.buffer_slice(data,texcoord_accessor).([][2]f32); assert(ok)
			lightmap_texcoords_data, ok = gltf.buffer_slice(data, lightmap_texcoord_accessor).([][2]f32); fmt.assertf(ok, "Mesh %s has no lightmap texcoords.", mesh_name)
			indices_data, ok = gltf.buffer_slice(data, indices_accessor).([]u16); fmt.assertf(ok, "Mesh %s has no indices.", mesh_name)
			for i in indices_data {
				append_elems(&model.positions, positions_data[i].x, positions_data[i].y, positions_data[i].z)
				append_elems(&model.normals, normals_data[i].x, normals_data[i].y, normals_data[i].z)
				append_elems(&model.texcoords, texcoords_data[i].x, texcoords_data[i].y)
				append_elems(&model.lightmap_texcoords, lightmap_texcoords_data[i].x, lightmap_texcoords_data[i].y) }
			gl.GenBuffers(1, &model.positions_handle)
			gl.GenBuffers(1, &model.normals_handle)
			gl.GenBuffers(1, &model.texcoords_handle)
			gl.GenBuffers(1, &model.lightmap_texcoords_handle)
			gl.BindBuffer(gl.ARRAY_BUFFER, model.positions_handle)
			gl.BufferData(gl.ARRAY_BUFFER, len(model.positions) * size_of(f32), &model.positions[0], gl.STATIC_DRAW)
			gl.BindBuffer(gl.ARRAY_BUFFER, model.normals_handle)
			gl.BufferData(gl.ARRAY_BUFFER, len(model.normals) * size_of(f32), &model.normals[0], gl.STATIC_DRAW)
			gl.BindBuffer(gl.ARRAY_BUFFER, model.texcoords_handle)
			gl.BufferData(gl.ARRAY_BUFFER, len(model.texcoords) * size_of(f32), &model.texcoords[0], gl.STATIC_DRAW)
			gl.BindBuffer(gl.ARRAY_BUFFER, model.lightmap_texcoords_handle)
			gl.BufferData(gl.ARRAY_BUFFER, len(model.lightmap_texcoords) * size_of(f32), &model.lightmap_texcoords[0], gl.STATIC_DRAW)
			glb_material := &data.materials[primitive.material.? or_else 0]
			assert(glb_material.metallic_roughness != nil)
			material_matellic_roughness := glb_material.metallic_roughness.?
			material_name: string
			material_name, ok = glb_material.name.?
			assert(ok)
			append(&draw.materials, Material{ name = material_name })
			material := &draw.materials[len(draw.materials) - 1]
			material.metallic_factor = material_matellic_roughness.metallic_factor
			material.roughness_factor = material_matellic_roughness.roughness_factor
			assert(material_matellic_roughness.base_color_texture != nil)
			material_base_color_texture := &data.textures[material_matellic_roughness.base_color_texture.?.index]
			assert(material_base_color_texture.source != nil)
			material_base_color_texture_image := &data.images[material_base_color_texture.source.?]
			assert(material_base_color_texture_image.type == .PNG)
			assert(material_base_color_texture_image.buffer_view != nil)
			base_color_buffer_view := data.buffer_views[material_base_color_texture_image.buffer_view.?]
			base_color_buffer := data.buffers[base_color_buffer_view.buffer].uri.([]byte)
			base_color_bytes := base_color_buffer[base_color_buffer_view.byte_offset:base_color_buffer_view.byte_offset+base_color_buffer_view.byte_length]
			base_color_name := fmt.aprintf("%s-base-color", material_name)
			// material.base_color_texture, ok = generic_texture_search_and_remove(draw, base_color_name)
			// if ! ok {
				init_texture_from_png(draw, &material.base_color_texture, base_color_name, base_color_bytes)
				cache_write(fmt.aprintf("%s.qoi", material.base_color_texture.name), texture_to_qoi(&material.base_color_texture))
			// }
			// else {
			// 	fmt.println(LOG, "Loaded base-color from QOI.") }
			assert(load_texture(draw, &material.base_color_texture))
			model.material = material }
		append(&draw.model_instances, Model_Instance{ })
		model_instance := &draw.model_instances[len(draw.model_instances) - 1]
		if model.name not_in instances_counter {
			instances_counter[model.name] = 1 }
		else do instances_counter[model.name] += 1
		model_instance.name = fmt.aprintf("%s-%d", model.name, instances_counter[model.name])
		fmt.println(LOG, "Added instance with name", model_instance.name)
		model_instance.model = model
		mesh_rotation: quaternion128 = cast(quaternion128)node.rotation
		mesh_scale: [3]f32 = node.scale
		mesh_translation: [3]f32 = node.translation
		mesh_rotation_matrix: matrix[4,4]f32 = la.matrix4_from_quaternion_f32(mesh_rotation)
		mesh_scale_matrix: matrix[4,4]f32 = la.matrix4_scale_f32(mesh_scale)
		mesh_translation_matrix: matrix[4,4]f32 = la.matrix4_translate_f32(mesh_translation)
		model_instance.transform_translate = mesh_translation_matrix
		model_instance.transform_rotate = mesh_rotation_matrix
		model_instance.transform_scale = mesh_scale_matrix
		model_instance.transform = mesh_translation_matrix * mesh_rotation_matrix * mesh_scale_matrix
		resize_arena_to_content(&model.arena, MODEL_MEMORY_CAP) } }


delete_model::proc(model:^Model) {
	gl.DeleteBuffers(1,&model.positions_handle)
	gl.DeleteBuffers(1,&model.normals_handle)
	gl.DeleteBuffers(1,&model.texcoords_handle)
	gl.DeleteBuffers(1,&model.lightmap_texcoords_handle)
	mem.arena_free_all(&model.arena)
	delete(model.arena.data) }


delete_all_models_and_materials::proc(draw: ^Draw) {
	for len(draw.models)>0 {
		delete_model(&draw.models[0])
		ordered_remove(&draw.models,0) }
	// for _,i in draw.materials do delete_material(&draw.materials[i])
}


matrix4_perspective_f32 :: proc(fovy, aspect, near, far: f32) -> (m: matrix[4, 4]f32) {
	X :: 0
	Y :: 1
	Z :: 2
	W :: 3
	tan_half_fovy := m.tan(0.5 * fovy)
	m[X, X] = 1 / (aspect * tan_half_fovy)
	m[Y, Z] = 1 / (tan_half_fovy)
	m[Z, Y] = + (far + near) / (far - near)
	m[W, Y] = + 1
	m[Z, W] = -2 * far * near / (far - near)
	m[Z] = m[Z]
	return }


models_search_by_proc :: proc(models: ^[dynamic]Model, search_proc: proc(model_name: string) -> bool) -> ^Model {
	for _,i in models {
		model := &models[i]
		if search_proc(model.name) do return model }
	return nil }


// TOOD: Fix this.
watch_models :: proc(draw: ^Draw, name: string) {
	// filename: string = fmt.tprintf("./models/%s.glb", name)
	// new_models_write_time, os_error := os.last_write_time_by_name(filename)
	// assert(os_error == nil)
	// if new_models_write_time > draw.last_models_write_time {
	// 	delete_all_models_and_materials(draw)
	// 	context.allocator = main_allocator
	// 	load_models_from_gltf(draw, "beach")
	// 	context.allocator = temp_allocator
	// 	draw.last_models_write_time = new_models_write_time }
}


print_models :: proc(draw: ^Draw) {
	for model in draw.models do fmt.printfln("")
}


uv_triangle_area :: proc(triangle: UV_Triangle) -> (area: f32) {
	a, b, c := la.distance(triangle.x, triangle.y), la.distance(triangle.y, triangle.z), la.distance(triangle.z, triangle.x)
	s := (a + b + c) / 2
	return m.sqrt_f32(s * (s - a) * (s - b) * (s - c)) }


// (DESC): Find the nearest UV-triangle to the given point in UV-space. //
texcoords_nearest_uv_triangle :: proc(texcoords: []f32, point: [2]f32) -> (nearest_triangle: UV_Triangle, nearest_index: int) {
	uv_triangles := sl.reinterpret([][3][2]f32, texcoords)
	nearest_distance: f32 = m.F32_MAX
	nearest_index = -1
	for triangle, index in uv_triangles {
		bary: Bary = bary_from_point2(point, triangle)
		if bary_inside(bary) do return triangle, index
		distance := la.max(la.abs(bary - { 0.5, 0.5, 0.5 }) - { 0.5, 0.5, 0.5 })
		if distance < nearest_distance {
			nearest_distance = distance
			nearest_triangle = triangle
			nearest_index = index } }
	return nearest_triangle, nearest_index }


// (NOTE): Should be "thickness" instead of "thinness" because then we can add them up.
two_point_thickness :: proc(points: [2][3]f32, normals: [2][3]f32, offset: f32) -> f32 {
	return clamp(- la.dot(normals[0], normals[1]), 0, 1) }
	// if points[0] == points[1] do return 0
	// return la.distance(points[0] + normals[0] * offset, points[1] + normals[1] * offset) / (la.distance(points[0], points[1]) * offset) }


model_bake_scattered_light_map :: proc(draw: ^Draw, model: ^Model, override: bool = false) {
	// filename := fmt.aprintf("cache/%s-scattered-light.qoi")
	// if data_exists(filename)

	// load_texture(draw, &model.thickness_map)
}


// (TODO): Check in the cache first. //
model_bake_triangles_map :: proc(draw: ^Draw, model: ^Model, size: [2]int) {
	init_texture_from_description(draw, &model.triangles_map, fmt.aprintf("%s-%s", model.name, "triangles"), size, 3, 8)
	iterator: Texture_Pixel_Iterator([3]u8) = make_texture_pixel_iterator(&model.triangles_map, { model.triangles_map.width, model.triangles_map.height }, [3]u8)
	for pixel, pixel_position in texture_pixel_iterate_next(&iterator) {
		triangle_iterator: UV_Triangle_Iterator = make_uv_triangle_iterator(model)
		pixel^ = { 0, 0, 0 }
		for triangle in uv_triangle_iterate_next(&triangle_iterator) {
			if point2_inside_triangle(texture_space_to_normal_space(pixel_position, iterator.size), triangle) {
				n := len(draw.random_colors)
				pixel^ = la.array_cast(draw.random_colors[triangle_iterator.index % n] * 255, u8)
				break } } }
	load_texture(draw, &model.triangles_map) }


// (TODO): Thickness should be baked per model rather than per instance, but this must ensure the models are scaled beforehand. //
model_bake_thickness_map_point_method :: proc(draw: ^Draw, model: ^Model, size: [2]int) {
	init_texture_from_description(draw, &model.thickness_map, fmt.aprintf("%s-%s", model.name, "thickness"), size, 1, 8)
	iterator := make_texel_iterator(model, la.MATRIX4F32_IDENTITY, { model.thickness_map.width, model.thickness_map.height })
	for texel in texel_iterate_next(&iterator) {
		// Texel :: struct {
		// 	position: [2]int,
		// 	triangle_index: int,
		// 	point: [3]f32,
		// 	bary:  Bary }
		filter_data := Point_Radius_Filter_Data{ radius = 1.0, center = texel.point }
		points_iterator := make_model_points_iterator(model, point_radius_filter, &filter_data)
		pixel : ^u8 = texture_pixel_from_position(&model.thickness_map, texel.position, u8)
		for point, normal, index in model_points_iterate_next(&points_iterator) {
			points: [2][3]f32 = {
				texel.point,
				point }
			normals: [2][3]f32 = {
				texel.normal,
				normal }
			pixel^ = u8_denormalize(u8_normalize(pixel^) + two_point_thickness(points, normals, 1.0)) } }
	load_texture(draw, &model.thickness_map) }


// (NOTE): An alternative method is an intersection method where you check to see.


bake_models :: proc(draw: ^Draw, cache: ^Cache) {
	TRIANGLES_MAP_SIZE: [2]int : { 32, 32 }
	THICKNESS_MAP_SIZE: [2]int : { 32, 32 }
	WORLD_POSITION_MAP_SIZE: [2]int : { 512, 512 }
	// for _, i in draw.models do model_bake_triangles_map(draw, &draw.models[i], TRIANGLES_MAP_SIZE)
	for _, i in draw.model_instances do model_instance_bake_world_position_map(draw, cache, &draw.model_instances[i], WORLD_POSITION_MAP_SIZE)
	// for _, i in draw.models do model_bake_thickness_map_point_method(draw, &draw.models[i], THICKNESS_MAP_SIZE)
	}


render_model_uv :: proc(draw: ^Draw, model: ^Model, rect: Rect = { pos = { 0, 0 }, size = { 256, 256 } }) {
	// (TODO):
	// iterator: UV_Triangle_Iterator = make_uv_triangle_iterator(model)
	// @(static) triangles: map[string][dynamic]UV_Triangle = { }
	// if len(triangles) == 0 do for triangle in uv_triangle_iterate_next(&iterator) do append(&triangles, triangle)
	// render_rect_hollow(draw, rect.pos, rect.size, color = RED, thickness = 2)
	// for triangle in triangles do render_triangle(draw, points = { normal_space_to_rect_space(triangle[0], rect), normal_space_to_rect_space(triangle[1], rect), normal_space_to_rect_space(triangle[2], rect) }, color = RED)
}


model_triangle_positions :: proc(model: ^Model, triangle_index: int) -> (triangle_positions: [3][3]f32) {
	triangles := sl.reinterpret([][3][3]f32, model.positions[:])
	if triangle_index < len(triangles) do return triangles[triangle_index]
	else do return {} }


model_triangle_normals :: proc(model: ^Model, triangle_index: int) -> (triangle_normals: [3][3]f32) {
	triangles := sl.reinterpret([][3][3]f32, model.normals[:])
	if triangle_index < len(triangles) do return triangles[triangle_index]
	else do return {} }


model_triangle_texcoords :: proc(model: ^Model, triangle_index: int) -> (triangle_texcoords: [3][2]f32) {
	triangles := sl.reinterpret([][3][2]f32, model.texcoords[:])
	if triangle_index < len(triangles) do return triangles[triangle_index]
	else do return {} }


Point_Radius_Filter_Data :: struct {
	radius: f32,
	center: [3]f32 }


point_radius_filter :: proc(point: [3]f32, data: rawptr) -> bool {
	filter_data := cast(^Point_Radius_Filter_Data)data
	return la.distance(filter_data.center, point) <= filter_data.radius }



