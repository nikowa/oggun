#+feature using-stmt
package model
import "core:fmt"
import "core:math/linalg"


Model_Iterator :: struct {
	model: ^Model }


// (DESC): Iterate through the positions in a texture-space, which correspond to points on the model. //
// (TODO): This should inherit from Model_Instance_Iterator. //
Texel_Iterator :: struct {
	using _: Model_Iterator,
	transform: matrix[4, 4]f32,
	texture_position_iterator: Texture_Position_Iterator,
	texture_size: [2]int,
	curr: [2]int }


Texel :: struct {
	position: [2]int,
	triangle_index: int,
	point: [3]f32,
	normal: [3]f32,
	uv_point: [2]f32,
	triangle: [3][3]f32,
	bary: Bary }


make_texel_iterator :: proc(model: ^Model, transform: matrix[4, 4]f32, texture_size: [2]int) -> Texel_Iterator {
	return { transform = transform, texture_position_iterator = make_texture_position_iterator(texture_size), model = model, texture_size = texture_size, curr = { 0, 0 } } }


texel_iterate_next :: proc(iterator: ^Texel_Iterator) -> (Texel, bool) {
	texel:           Texel
	ok:              bool
	uv_point:        [2]f32
	uv_triangle:     UV_Triangle
	triangle:        [3][3]f32
	normal_triangle: [3][3]f32

	texel.position, ok = texture_position_iterate_next(&iterator.texture_position_iterator)
	if ! ok do return {}, false
	uv_point = texture_space_to_normal_space(texel.position, iterator.texture_position_iterator.size)
	uv_triangle, texel.triangle_index = texcoords_nearest_uv_triangle(iterator.model.lightmap_texcoords[:], uv_point)
	texel.bary = bary_from_point2(uv_point, uv_triangle)
	// if bary_inside(texel.bary) {
	// 	fmt.println(texel.bary.r + texel.bary.g + texel.bary.b) }
	triangle = model_triangle_positions(iterator.model, texel.triangle_index)
	normal_triangle = model_triangle_normals(iterator.model, texel.triangle_index)
	// texel.point = bary_to_point(texel.bary, triangle)
	texel.point = bary_to_point(texel.bary, [3][3]f32{ apply_transform(triangle[0], iterator.transform), apply_transform(triangle[1], iterator.transform), apply_transform(triangle[2], iterator.transform) })
	// texel.point = apply_transform(bary_to_point(texel.bary, triangle), iterator.transform)
	texel.normal = bary_to_point(texel.bary, normal_triangle)
	texel.uv_point = uv_point
	texel.triangle = triangle
	return texel, true }


// (DESC): Iterates through the triangles in the UV-space of a model. //
// (TODO): Deprecate this!
UV_Triangle_Iterator :: struct {
	using _: Model_Iterator,
	index:   int }


UV_Triangle :: [3][2]f32


make_uv_triangle_iterator :: proc(model: ^Model) -> UV_Triangle_Iterator {
	return { model = model, index = 0 } }


uv_triangle_iterate_next :: proc(iterator: ^UV_Triangle_Iterator) -> (uv_triangle: UV_Triangle, index: int, ok: bool) {
	STRIDE :: 6
	offset := iterator.index * STRIDE
	texcoords := iterator.model.texcoords[:]
	if len(texcoords) <= offset + 5 do return {}, 0, false
	uv_triangle = {
		{ texcoords[offset + 0], texcoords[offset + 1] },
		{ texcoords[offset + 2], texcoords[offset + 3] },
		{ texcoords[offset + 4], texcoords[offset + 5] } }
	iterator.index += 1
	return uv_triangle, iterator.index, true }


// (DESC): Iterates through the model-space points on a model, with an optional filter. //
Model_Points_Iterator :: struct {
	using _:   Model_Iterator,
	index:     int,
	filter:    proc(point: [3]f32, data: rawptr) -> bool,
	data:      rawptr,
	transform: matrix[4, 4]f32 }


make_model_points_iterator :: proc(model: ^Model, filter: proc(point: [3]f32, data: rawptr) -> bool = nil, data: rawptr = nil, transform: matrix[4, 4]f32 = linalg.MATRIX4F32_IDENTITY) -> Model_Points_Iterator {
	return { model = model, index = 0, filter = filter, data = data, transform = transform } }


// (TODO): Rename "point" to "position"
model_points_iterate_next :: proc(iterator: ^Model_Points_Iterator) -> (point: [3]f32, normal: [3]f32, index: int, ok: bool) {
	for {
		STRIDE :: 3
		model := iterator.model
		index = iterator.index
		if index * STRIDE + 2 >= len(model.positions) do return {}, {}, iterator.index, false
		point = {
			model.positions[index * STRIDE + 0],
			model.positions[index * STRIDE + 1],
			model.positions[index * STRIDE + 2] }
		normal = {
			model.normals[index * STRIDE + 0],
			model.normals[index * STRIDE + 1],
			model.normals[index * STRIDE + 2] }
		point = (iterator.transform * [4]f32{ point.x, point.y, point.z, 1 }).xyz
		iterator.index += 1
		if iterator.filter == nil do return point, normal, index, true
		if iterator.filter(point, iterator.data) do return point, normal, index, true } }

