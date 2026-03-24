#+feature using-stmt
package mesh
import rt "base:runtime"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"
import str "core:strings"
import os "core:os"
import db "../database"
import la "core:math/linalg"
import fmt "core:fmt"
import log "core:log"
import base "../base"
import r "../container/rect"



Mesh :: struct {
	verts: [][3]f32,
	handle: u32 }

upload_mesh :: proc(mesh: ^Mesh) -> bool {
	if mesh.handle != 0 do download_mesh(mesh)
	gl.GenBuffers(1, &mesh.handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, mesh.handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(mesh.verts) * size_of(mesh.verts[0]), &mesh.verts[0], gl.STATIC_DRAW)
	return true }

download_mesh :: proc(mesh: ^Mesh) {
	gl.DeleteBuffers(1, &mesh.handle) }

make_line_cube_mesh :: proc(allocator: rt.Allocator) -> (mesh: Mesh) {
	verts := make_dynamic_array([dynamic][3]f32, allocator)
	append_line_cube(&verts)
	shrink(&verts)
	mesh.verts = verts[:]
	return mesh }

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

append_uv_square_grid :: proc(verts: ^[dynamic][2]f32, x: [2]f32 = { 0, 1 }, y: [2]f32 = { 0, 1 }, grid_size: [2]u32 = { 1, 1 }) {
	delta_x, delta_y: f32 = (x[1] - x[0]) / cast(f32)grid_size.x, (y[1] - y[0]) / cast(f32)grid_size.y
	for i in 0 ..< grid_size.x do for j in 0 ..< grid_size.y {
		append_uv_rect(verts,
			{ x[0] + cast(f32)i * delta_x, x[0] + cast(f32)(i + 1) * delta_x },
			{ y[0] + cast(f32)j * delta_y, y[0] + cast(f32)(j + 1) * delta_y }) } }

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
append_line_cube :: proc(verts: ^[dynamic][3]f32) {
	a, b, c, d, e, f, g, h: [3]f32 =
		{ 0, 0, 0 }, { 0, 1, 0 }, { 1, 1, 0 }, { 1, 0, 0 },
		{ 0, 0, 1 }, { 0, 1, 1 }, { 1, 1, 1 }, { 1, 0, 1 }
	append_elems(verts, a, b)
	append_elems(verts, b, c)
	append_elems(verts, c, d)
	append_elems(verts, d, a)
	append_elems(verts, e, f)
	append_elems(verts, f, g)
	append_elems(verts, g, h)
	append_elems(verts, h, e)
	append_elems(verts, a, e)
	append_elems(verts, b, f)
	append_elems(verts, c, g)
	append_elems(verts, d, h) }
