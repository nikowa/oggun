#+feature using-stmt
package mesh
import rt "base:runtime"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"
import str "core:strings"
import os "core:os"
import la "core:math/linalg"
import fmt "core:fmt"
import log "core:log"
import base "../base"
import r "../container/rect"



Mesh :: struct($depth: int) {
	verts: [][depth]f32,
	surface_indexes: []i32,
	verts_handle: u32,
	surface_indexes_handle: u32,
	surface_count: u32 }

Mesh_Builder :: struct($depth: int) {
	verts: [dynamic][depth]f32,
	surface_indexes: [dynamic]i32,
	surface_count: u32 }

make_mesh_builder :: proc($depth: int, allocator: rt.Allocator) -> (mesh_builder: Mesh_Builder(depth)) {
	mesh_builder.verts = make_dynamic_array([dynamic][depth]f32, allocator)
	mesh_builder.surface_indexes = make_dynamic_array([dynamic]i32, allocator)
	mesh_builder.surface_count = 0
	return mesh_builder }

mesh_from_builder :: proc(mesh_builder: Mesh_Builder($depth)) -> (mesh: Mesh(depth)) {
	mesh_builder := mesh_builder
	shrink(&mesh_builder.verts)
	shrink(&mesh_builder.surface_indexes)
	mesh.verts = mesh_builder.verts[:]
	mesh.surface_indexes = mesh_builder.surface_indexes[:]
	mesh.surface_count = mesh_builder.surface_count
	return mesh }

upload_mesh :: proc(mesh: ^Mesh($depth)) -> bool {
	if mesh.verts_handle != 0 do download_mesh(mesh)
	gl.GenBuffers(1, &mesh.verts_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.verts_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(mesh.verts) * size_of(mesh.verts[0]), &mesh.verts[0], gl.STATIC_DRAW)
	return true }

download_mesh :: proc(mesh: ^Mesh($depth)) {
	gl.DeleteBuffers(1, &mesh.verts_handle) }

make_line_cube_mesh :: proc($depth: int, allocator: rt.Allocator) -> (mesh: Mesh(depth)) {
	mesh_builder := make_mesh_builder(depth, allocator)
	builder_append_line_cube(&mesh_builder)
	return mesh_from_builder(mesh_builder) }

//   3---5
// 0  \  |
// | \ \ |
// |  \  4
// 1---2
//
//  A---D
//  |   |
//  |   |
//  B---C
//
append_uv_rect :: proc(verts: ^[dynamic][2]f32, x: [2]f32 = { 0, 1 }, y: [2]f32 = { 0, 1 }) {
	a, b, c, d: [2]f32 = { x[0], y[1] }, { x[0], y[0] }, { x[1], y[0] }, { x[1], y[1] }
	append_elems(verts, a, b, c, a, c, d) }

builder_append_2d_square_grid :: proc(builder: ^Mesh_Builder(2), x: [2]f32 = { 0, 1 }, y: [2]f32 = { 0, 1 }, grid_size: [2]u32 = { 1, 1 }) {
	delta_x, delta_y: f32 = (x[1] - x[0]) / cast(f32)grid_size.x, (y[1] - y[0]) / cast(f32)grid_size.y
	count: u32 = 0
	for i in 0 ..< grid_size.x do for j in 0 ..< grid_size.y {
		append_uv_rect(&builder.verts,
			{ x[0] + cast(f32)i * delta_x, x[0] + cast(f32)(i + 1) * delta_x },
			{ y[0] + cast(f32)j * delta_y, y[0] + cast(f32)(j + 1) * delta_y })
		count += 6 }
	for _ in 0 ..< count do append_elem(&builder.surface_indexes, cast(i32)builder.surface_count)
	builder.surface_count += 1 }

//  Z
//  ^
//  |
//  |
//  E---H
//  |\  |\
//  | \ | \
//  |  F+--G
//  A--+D--|-> X
//   \ | \ |
//    \|  \|
//     B---C
//      \
//       v
//        Y
builder_append_line_cube :: proc(builder: ^Mesh_Builder(3)) {
	a, b, c, d, e, f, g, h: [3]f32 =
		{ -1, -1, -1 }, { -1, +1, -1 }, { +1, +1, -1 }, { +1, -1, -1 },
		{ -1, -1, +1 }, { -1, +1, +1 }, { +1, +1, +1 }, { +1, -1, +1 }
	append_elems(&builder.verts, a, b)
	append_elems(&builder.verts, b, c)
	append_elems(&builder.verts, c, d)
	append_elems(&builder.verts, d, a)
	append_elems(&builder.verts, e, f)
	append_elems(&builder.verts, f, g)
	append_elems(&builder.verts, g, h)
	append_elems(&builder.verts, h, e)
	append_elems(&builder.verts, a, e)
	append_elems(&builder.verts, b, f)
	append_elems(&builder.verts, c, g)
	append_elems(&builder.verts, d, h)
	for i in 0 ..< 12 * 2 do append_elem(&builder.surface_indexes, cast(i32)builder.surface_count)
	builder.surface_count += 1 }
