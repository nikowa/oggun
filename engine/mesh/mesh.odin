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
	log.info("Appending rect", x, y)
	a, b, c, d: [2]f32 = { x[0], y[1] }, { x[0], y[0] }, { x[1], y[0] }, { x[1], y[1] }
	append_elems(verts, a, b, c, a, c, d) }

append_uv_square_grid :: proc(verts: ^[dynamic][2]f32, x: [2]f32 = { 0, 1 }, y: [2]f32 = { 0, 1 }, grid_size: [2]u32 = { 1, 1 }) {
	delta_x, delta_y: f32 = (x[1] - x[0]) / cast(f32)grid_size.x, (y[1] - y[0]) / cast(f32)grid_size.y
	for i in 0 ..< grid_size.x do for j in 0 ..< grid_size.y {
		append_uv_rect(verts,
			{ x[0] + cast(f32)i * delta_x, x[0] + cast(f32)(i + 1) * delta_x },
			{ y[0] + cast(f32)j * delta_y, y[0] + cast(f32)(j + 1) * delta_y }) } }
