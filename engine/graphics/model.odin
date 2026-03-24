#+feature using-stmt
package graphics
import rt "base:runtime"
import rl "core:reflect"
import fmt "core:fmt"
import os "core:os"
import slc "core:slice"
import m "core:math"
import la "core:math/linalg"
import mem "core:mem"
import fp "core:path/filepath"
import gl "vendor:OpenGL"
import gltf "shared:gltf2"
import log "core:log"
import db "../database"
import t "core:time"
import b "core:bytes"



MODEL_MEMORY_CAP :: 16 * rt.Megabyte

Model :: struct {
	url: db.URL,
	arena: mem.Arena,
	positions_handle: u32,
	normals_handle: u32,
	texcoords_handle: u32,
	lightmap_texcoords_handle: u32,
	positions: [][3]f32,
	normals: [][3]f32,
	texcoords: [][2]f32,
	lightmap_texcoords: [][2]f32,
// 	material: ^Material,
// 	triangles_map: Texture,
// thickness_map: Texture
}

model_equiv :: proc(a: ^Model, b: ^Model) -> bool {
	return (a.url == b.url) &&
		slc.equal(a.positions, b.positions) &&
		slc.equal(a.normals, b.normals) &&
		slc.equal(a.texcoords, b.texcoords) &&
		slc.equal(a.lightmap_texcoords, b.lightmap_texcoords) }

// model_position :: proc(model: ^Model, point_index: int) -> (position: [3]f32) {
// 	STRIDE :: 3; return { model.positions[point_index * STRIDE + 0], model.positions[point_index * STRIDE + 1], model.positions[point_index * STRIDE + 2] } }


// model_normal :: proc(model: ^Model, point_index: int) -> (normal: [3]f32) {
// 	STRIDE :: 3; return { model.normals[point_index * STRIDE + 0], model.normals[point_index * STRIDE + 1], model.normals[point_index * STRIDE + 2] } }


// model_texcoord :: proc(model: ^Model, point_index: int) -> (texcoord: [2]f32) {
// 	STRIDE :: 2; return { model.texcoords[point_index * STRIDE + 0], model.texcoords[point_index * STRIDE + 1] } }

import_or_retreive_model :: proc(
    database: ^db.Database,
    url: db.URL,
    allocator: rt.Allocator) -> (model: Model, err: os.Error) {
	entry: ^db.Entry
	ok: bool
	path: string
	modification_time: t.Time
	bytes: []u8

	entry, ok = db.entry_from_url(database, url)
	if ok do if db.entry_was_modified(database, entry) || database.spec_modified do ok = false
	if ok do model = model_deserialize(entry.data, allocator) or_return
	else {
		log.infof("Reading model %s from source.", url)
		path = db.url_search_source(database, url, allocator) or_return
		model = load_model(path, url, allocator) or_return
		modification_time = os.modification_time_by_path(path) or_return
		bytes = model_serialize(&model, allocator) or_return
		db.add_or_update_entry(database, db.make_entry(url, bytes, modification_time), true) or_return }
	return model, os.General_Error.None }

model_serialize :: proc(
    model: ^Model,
    allocator: rt.Allocator) -> (bytes: []u8, err: os.Error) {
	buffer: b.Buffer

	b.buffer_init_allocator(&buffer, 0, MODEL_MEMORY_CAP, context.temp_allocator)
	b.buffer_write_ptr(&buffer, model, size_of(model^)) or_return
	b.buffer_write_slice(&buffer, model.positions[:]) or_return
	b.buffer_write_slice(&buffer, model.normals[:]) or_return
	b.buffer_write_slice(&buffer, model.texcoords[:]) or_return
	b.buffer_write_slice(&buffer, model.lightmap_texcoords[:]) or_return
	return slc.clone(b.buffer_to_bytes(&buffer), allocator), os.General_Error.None }

model_deserialize :: proc(
	bytes: []u8,
	allocator: rt.Allocator) -> (model: Model, err: os.Error) {
	reader: b.Reader

	b.reader_init(&reader, bytes)
	b.reader_read_ptr(&reader, &model, size_of(model)) or_return
	model.positions = make([][3]f32, len(model.positions), allocator) or_return
	model.normals = make([][3]f32, len(model.normals), allocator) or_return
	model.texcoords = make([][2]f32, len(model.texcoords), allocator) or_return
	model.lightmap_texcoords = make([][2]f32, len(model.lightmap_texcoords), allocator) or_return
	b.reader_read_slice(&reader, model.positions) or_return
	b.reader_read_slice(&reader, model.normals) or_return
	b.reader_read_slice(&reader, model.texcoords) or_return
	b.reader_read_slice(&reader, model.lightmap_texcoords) or_return
	return model, os.General_Error.None }

// (TODO): Standardize the load/save, import, read/write interface. Implement register.
load_model :: proc(
	path: string,
	url: db.URL,
	allocator: rt.Allocator) -> (model: Model, err: os.Error) {
	ext: string

	if ! os.exists(path) {
		log.errorf("File %s not found.", path)
		return {}, os.General_Error.Not_Exist }
	ext = os.ext(path)
	switch ext {
	case ".glb": return _load_model_gltf(path, url, allocator)
	case: log.errorf("Model path %s has unsupported extension.", path) }
	return {}, os.General_Error.Invalid_Path }

// TODO: Add a version of this that load to scene tree, rather than a model.
_load_model_gltf :: proc(
    path: string,
    url: db.URL,
    allocator: rt.Allocator) -> (model: Model, err: os.Error) {
	mesh: gltf.Mesh
	data: ^gltf.Data
	gltf_err: gltf.Error
	mesh_name: string
	primitive: ^gltf.Mesh_Primitive
	ok: bool
	attributes: ^map[string]gltf.Integer
	mesh_accessor, indices_accessor, material_accessor, position_accessor, normal_accessor, texcoord_accessor, lightmap_texcoord_accessor: gltf.Integer
	n: int

	mem.arena_init(&model.arena, make([]u8, MODEL_MEMORY_CAP))
    err = os.General_Error.Invalid_File
	data, gltf_err = gltf.load_from_file(path)
	switch err in gltf_err {
	case gltf.JSON_Error: if err.type != .None do return
	case gltf.GLTF_Error: return }
	if len(data.nodes) != 1 do return
	node := data.nodes[0]
	mesh_accessor, ok = data.nodes[0].mesh.?; if ! ok do return
	mesh = data.meshes[mesh_accessor]
	mesh_name, ok = mesh.name.?; if ! ok do return
	log.infof("Importing mesh \"%s\".", mesh_name)
	context.allocator = mem.arena_allocator(&model.arena)
	model.url = url
	// model.url = db.url_join({ "model", cast(db.URL)mesh_name }, allocator)
	if (len(mesh.primitives) != 1) || mesh.primitives[0].mode != .Triangles do return
	primitive = &mesh.primitives[0]
	attributes = &primitive.attributes
	indices_accessor, ok = primitive.indices.?; if ! ok do return
	material_accessor, ok = primitive.material.?; if ! ok do return
	if ("POSITION" not_in attributes) || ("NORMAL" not_in attributes) || ("TEXCOORD_0" not_in attributes) do return
	position_accessor = attributes["POSITION"]
	normal_accessor = attributes["NORMAL"]
	texcoord_accessor = attributes["TEXCOORD_0"]
	lightmap_texcoord_accessor = attributes["TEXCOORD_1"]
	if (data.accessors[position_accessor].normalized) || (data.accessors[normal_accessor].normalized) || (data.accessors[texcoord_accessor].normalized) || (data.accessors[lightmap_texcoord_accessor].normalized) do return
	positions_data: [][3]f32
	normals_data: [][3]f32
	texcoords_data: [][2]f32
	lightmap_texcoords_data: [][2]f32
	indices_data: []u32
	positions_data, ok = gltf.buffer_slice(data,position_accessor).([][3]f32); if ! ok do return
	normals_data, ok = gltf.buffer_slice(data,normal_accessor).([][3]f32); if ! ok do return
	texcoords_data, ok = gltf.buffer_slice(data,texcoord_accessor).([][2]f32); if ! ok do return
	lightmap_texcoords_data, ok = gltf.buffer_slice(data, lightmap_texcoord_accessor).([][2]f32)
	if ! ok {
		log.errorf("Mesh %s has no lightmap texcoords.", mesh_name)
		return }
	// log.infof("Indices variant: %v.", rl.union_variant_type_info(gltf.buffer_slice(data, indices_accessor)))
	#partial switch variant in gltf.buffer_slice(data, indices_accessor) {
	case []u16:
		indices_data = make([]u32, len(variant))
		for index, i in variant do indices_data[i] = cast(u32)index
	case []u32:
		indices_data = variant
	case:
		log.errorf("Mesh %s has no indices.", mesh_name)
		return }
	translate_matrix := la.matrix4_translate_f32(node.translation)
	rotate_matrix := la.matrix4_from_quaternion_f32(cast(quaternion128)node.rotation)
	scale_matrix := la.matrix4_scale_f32(node.scale)
	transform_matrix := translate_matrix * rotate_matrix * scale_matrix
	n = len(indices_data)
	model.positions = make([][3]f32, n)
	model.normals = make([][3]f32, n)
	model.texcoords = make([][2]f32, n)
	model.lightmap_texcoords = make([][2]f32, n)
	for i, j in indices_data {
		model.positions[j] = (transform_matrix * [4]f32{positions_data[i].x, positions_data[i].y, positions_data[i].z, 1}).xyz
		model.normals[j] = normals_data[i]
		model.texcoords[j] = texcoords_data[i]
		model.lightmap_texcoords[j] = lightmap_texcoords_data[i] }
	// glb_material := &data.materials[material_accessor]
	// assert(glb_material.metallic_roughness != nil)
	// material_matellic_roughness := glb_material.metallic_roughness.?
	// material_name: string
	// material_name, ok = glb_material.name.?
	// assert(ok)
	// // append(&draw.materials, Material{ name = material_name })
	// // material := &draw.materials[len(draw.materials) - 1]
	// // material.metallic_factor = material_matellic_roughness.metallic_factor
	// // material.roughness_factor = material_matellic_roughness.roughness_factor
	// // assert(material_matellic_roughness.base_color_texture != nil)
	// // material_base_color_texture := &data.textures[material_matellic_roughness.base_color_texture.?.index]
	// // assert(material_base_color_texture.source != nil)
	// // material_base_color_texture_image := &data.images[material_base_color_texture.source.?]
	// // assert(material_base_color_texture_image.type == .PNG)
	// // assert(material_base_color_texture_image.buffer_view != nil)
	// // base_color_buffer_view := data.buffer_views[material_base_color_texture_image.buffer_view.?]
	// // base_color_buffer := data.buffers[base_color_buffer_view.buffer].uri.([]byte)
	// // base_color_bytes := base_color_buffer[base_color_buffer_view.byte_offset:base_color_buffer_view.byte_offset+base_color_buffer_view.byte_length]
	// // base_color_name := fmt.aprintf("%s-base-color", material_name)
	// // init_texture_from_png(draw, &material.base_color_texture, base_color_name, base_color_bytes)
	// // cache_write(fmt.aprintf("%s.qoi", material.base_color_texture.name), texture_to_qoi(&material.base_color_texture))
	// // assert(load_texture(draw, &material.base_color_texture))
	// // model.material = material
	// append(&draw.model_instances, Model_Instance{ })
	// model_instance := &draw.model_instances[len(draw.model_instances) - 1]
	// fmt.println(LOG, "Added instance with name", model_instance.name)
	// model_instance.model = model




	// model_instance.transform_translate = mesh_translation_matrix
	// model_instance.transform_rotate = mesh_rotation_matrix
	// model_instance.transform_scale = mesh_scale_matrix
	// model_instance.transform = mesh_translation_matrix * mesh_rotation_matrix * mesh_scale_matrix
	// resize_arena_to_content(&model.arena, MODEL_MEMORY_CAP)
	return model, os.General_Error.None }

upload_model :: proc(model: ^Model) -> bool {
	if model.positions_handle != 0 do download_model(model)
	gl.GenBuffers(1, &model.positions_handle)
	gl.GenBuffers(1, &model.normals_handle)
	gl.GenBuffers(1, &model.texcoords_handle)
	gl.GenBuffers(1, &model.lightmap_texcoords_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.positions_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(model.positions) * size_of(model.positions[0]), &model.positions[0], gl.STATIC_DRAW)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.normals_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(model.normals) * size_of(model.normals[0]), &model.normals[0], gl.STATIC_DRAW)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.texcoords_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(model.texcoords) * size_of(model.texcoords[0]), &model.texcoords[0], gl.STATIC_DRAW)
	gl.BindBuffer(gl.ARRAY_BUFFER, model.lightmap_texcoords_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(model.lightmap_texcoords) * size_of(model.lightmap_texcoords[0]), &model.lightmap_texcoords[0], gl.STATIC_DRAW)
	return true }

download_model :: proc(model: ^Model) {
	gl.DeleteBuffers(1,&model.positions_handle)
	gl.DeleteBuffers(1,&model.normals_handle)
	gl.DeleteBuffers(1,&model.texcoords_handle)
	gl.DeleteBuffers(1,&model.lightmap_texcoords_handle) }

// delete_model::proc(model:^Model) {
// 	mem.arena_free_all(&model.arena)
// 	delete(model.arena.data) }


// delete_all_models_and_materials::proc(draw: ^Draw) {
// 	for len(draw.models)>0 {
// 		delete_model(&draw.models[0])
// 		ordered_remove(&draw.models,0) }
// 	// for _,i in draw.materials do delete_material(&draw.materials[i])
// }


// matrix4_perspective_f32 :: proc(fovy, aspect, near, far: f32) -> (m: matrix[4, 4]f32) {
// 	X :: 0
// 	Y :: 1
// 	Z :: 2
// 	W :: 3
// 	tan_half_fovy := m.tan(0.5 * fovy)
// 	m[X, X] = 1 / (aspect * tan_half_fovy)
// 	m[Y, Z] = 1 / (tan_half_fovy)
// 	m[Z, Y] = + (far + near) / (far - near)
// 	m[W, Y] = + 1
// 	m[Z, W] = -2 * far * near / (far - near)
// 	m[Z] = m[Z]
// 	return }


// models_search_by_proc :: proc(models: ^[dynamic]Model, search_proc: proc(model_name: string) -> bool) -> ^Model {
// 	for _,i in models {
// 		model := &models[i]
// 		if search_proc(model.name) do return model }
// 	return nil }


// // TOOD: Fix this.
// watch_models :: proc(draw: ^Draw, name: string) {
// 	// filename: string = fmt.tprintf("./models/%s.glb", name)
// 	// new_models_write_time, os_error := os.last_write_time_by_name(filename)
// 	// assert(os_error == nil)
// 	// if new_models_write_time > draw.last_models_write_time {
// 	// 	delete_all_models_and_materials(draw)
// 	// 	context.allocator = main_allocator
// 	// 	load_models_from_gltf(draw, "beach")
// 	// 	context.allocator = temp_allocator
// 	// 	draw.last_models_write_time = new_models_write_time }
// }


// print_models :: proc(draw: ^Draw) {
// 	for model in draw.models do fmt.printfln("")
// }


// uv_triangle_area :: proc(triangle: UV_Triangle) -> (area: f32) {
// 	a, b, c := la.distance(triangle.x, triangle.y), la.distance(triangle.y, triangle.z), la.distance(triangle.z, triangle.x)
// 	s := (a + b + c) / 2
// 	return m.sqrt_f32(s * (s - a) * (s - b) * (s - c)) }


// // (DESC): Find the nearest UV-triangle to the given point in UV-space. //
// texcoords_nearest_uv_triangle :: proc(texcoords: []f32, point: [2]f32) -> (nearest_triangle: UV_Triangle, nearest_index: int) {
// 	uv_triangles := slc.reinterpret([][3][2]f32, texcoords)
// 	nearest_distance: f32 = m.F32_MAX
// 	nearest_index = -1
// 	for triangle, index in uv_triangles {
// 		bary: Bary = bary_from_point2(point, triangle)
// 		if bary_inside(bary) do return triangle, index
// 		distance := la.max(la.abs(bary - { 0.5, 0.5, 0.5 }) - { 0.5, 0.5, 0.5 })
// 		if distance < nearest_distance {
// 			nearest_distance = distance
// 			nearest_triangle = triangle
// 			nearest_index = index } }
// 	return nearest_triangle, nearest_index }


// // (NOTE): Should be "thickness" instead of "thinness" because then we can add them up.
// two_point_thickness :: proc(points: [2][3]f32, normals: [2][3]f32, offset: f32) -> f32 {
// 	return clamp(- la.dot(normals[0], normals[1]), 0, 1) }
// 	// if points[0] == points[1] do return 0
// 	// return la.distance(points[0] + normals[0] * offset, points[1] + normals[1] * offset) / (la.distance(points[0], points[1]) * offset) }


// model_bake_scattered_light_map :: proc(draw: ^Draw, model: ^Model, override: bool = false) {
// 	// filename := fmt.aprintf("cache/%s-scattered-light.qoi")
// 	// if data_exists(filename)

// 	// load_texture(draw, &model.thickness_map)
// }


// // (TODO): Check in the cache first. //
// model_bake_triangles_map :: proc(draw: ^Draw, model: ^Model, size: [2]int) {
// 	init_texture_from_description(draw, &model.triangles_map, fmt.aprintf("%s-%s", model.name, "triangles"), size, 3, 8)
// 	iterator: Texture_Pixel_Iterator([3]u8) = make_texture_pixel_iterator(&model.triangles_map, { model.triangles_map.width, model.triangles_map.height }, [3]u8)
// 	for pixel, pixel_position in texture_pixel_iterate_next(&iterator) {
// 		triangle_iterator: UV_Triangle_Iterator = make_uv_triangle_iterator(model)
// 		pixel^ = { 0, 0, 0 }
// 		for triangle in uv_triangle_iterate_next(&triangle_iterator) {
// 			if point2_inside_triangle(texture_space_to_normal_space(pixel_position, iterator.size), triangle) {
// 				n := len(draw.random_colors)
// 				pixel^ = la.array_cast(draw.random_colors[triangle_iterator.index % n] * 255, u8)
// 				break } } }
// 	load_texture(draw, &model.triangles_map) }


// // (TODO): Thickness should be baked per model rather than per instance, but this must ensure the models are scaled beforehand. //
// model_bake_thickness_map_point_method :: proc(draw: ^Draw, model: ^Model, size: [2]int) {
// 	init_texture_from_description(draw, &model.thickness_map, fmt.aprintf("%s-%s", model.name, "thickness"), size, 1, 8)
// 	iterator := make_texel_iterator(model, la.MATRIX4F32_IDENTITY, { model.thickness_map.width, model.thickness_map.height })
// 	for texel in texel_iterate_next(&iterator) {
// 		// Texel :: struct {
// 		// 	position: [2]int,
// 		// 	triangle_index: int,
// 		// 	point: [3]f32,
// 		// 	bary:  Bary }
// 		filter_data := Point_Radius_Filter_Data{ radius = 1.0, center = texel.point }
// 		points_iterator := make_model_points_iterator(model, point_radius_filter, &filter_data)
// 		pixel : ^u8 = texture_pixel_from_position(&model.thickness_map, texel.position, u8)
// 		for point, normal, index in model_points_iterate_next(&points_iterator) {
// 			points: [2][3]f32 = {
// 				texel.point,
// 				point }
// 			normals: [2][3]f32 = {
// 				texel.normal,
// 				normal }
// 			pixel^ = u8_denormalize(u8_normalize(pixel^) + two_point_thickness(points, normals, 1.0)) } }
// 	load_texture(draw, &model.thickness_map) }

// // (NOTE): An alternative method is an intersection method where you check to see.

// bake_models :: proc(draw: ^Draw, cache: ^Cache) {
// 	TRIANGLES_MAP_SIZE: [2]int : { 32, 32 }
// 	THICKNESS_MAP_SIZE: [2]int : { 32, 32 }
// 	WORLD_POSITION_MAP_SIZE: [2]int : { 512, 512 }
// 	// for _, i in draw.models do model_bake_triangles_map(draw, &draw.models[i], TRIANGLES_MAP_SIZE)
// 	for _, i in draw.model_instances do model_instance_bake_world_position_map(draw, cache, &draw.model_instances[i], WORLD_POSITION_MAP_SIZE)
// 	// for _, i in draw.models do model_bake_thickness_map_point_method(draw, &draw.models[i], THICKNESS_MAP_SIZE)
// 	}

// render_model_uv :: proc(draw: ^Draw, model: ^Model, rect: Rect = { pos = { 0, 0 }, size = { 256, 256 } }) {
// 	// (TODO):
// 	// iterator: UV_Triangle_Iterator = make_uv_triangle_iterator(model)
// 	// @(static) triangles: map[string][dynamic]UV_Triangle = { }
// 	// if len(triangles) == 0 do for triangle in uv_triangle_iterate_next(&iterator) do append(&triangles, triangle)
// 	// render_rect_hollow(draw, rect.pos, rect.size, color = RED, thickness = 2)
// 	// for triangle in triangles do render_triangle(draw, points = { normal_space_to_rect_space(triangle[0], rect), normal_space_to_rect_space(triangle[1], rect), normal_space_to_rect_space(triangle[2], rect) }, color = RED)
// }

// model_triangle_positions :: proc(model: ^Model, triangle_index: int) -> (triangle_positions: [3][3]f32) {
// 	triangles := slc.reinterpret([][3][3]f32, model.positions[:])
// 	if triangle_index < len(triangles) do return triangles[triangle_index]
// 	else do return {} }


// model_triangle_normals :: proc(model: ^Model, triangle_index: int) -> (triangle_normals: [3][3]f32) {
// 	triangles := slc.reinterpret([][3][3]f32, model.normals[:])
// 	if triangle_index < len(triangles) do return triangles[triangle_index]
// 	else do return {} }


// model_triangle_texcoords :: proc(model: ^Model, triangle_index: int) -> (triangle_texcoords: [3][2]f32) {
// 	triangles := slc.reinterpret([][3][2]f32, model.texcoords[:])
// 	if triangle_index < len(triangles) do return triangles[triangle_index]
// 	else do return {} }


// Point_Radius_Filter_Data :: struct {
// 	radius: f32,
// 	center: [3]f32 }


// point_radius_filter :: proc(point: [3]f32, data: rawptr) -> bool {
// 	filter_data := cast(^Point_Radius_Filter_Data)data
// 	return la.distance(filter_data.center, point) <= filter_data.radius }



