#+feature using-stmt
package graphics
import rt "base:runtime"
import mem "core:mem"
import os "core:os"
import sl "core:slice"
import gl "vendor:OpenGL"
import db "../database"
import msh "../mesh"



Effect_Config :: struct {
	url: db.URL,
	surface_res: [2]u32,
	surface_count: u32 }

// Each surface is a normalized UV mesh, from which positions are computed by the vertex shader.
Effect :: struct {
	using config: Effect_Config,
	shader: ^Effect_Shader,
	verts_handle: u32,
	verts: []f32 }

make_effect :: proc(config: Effect_Config, graphics_context: ^Graphics_Context, database: ^db.Database, vert_url, frag_url: db.URL, allocator: rt.Allocator) -> (effect: Effect) {
	err: os.Error

	effect.config = config
	verts := make([dynamic][2]f32, allocator = allocator)
	for _ in 0 ..< config.surface_count do msh.append_uv_square_grid(&verts, grid_size = config.surface_res)
	shrink(&verts)
	effect.verts = sl.reinterpret([]f32, verts[:])
	effect.shader, err = make_shader(graphics_context, database, Effect_Shader, { name = cast(string)config.url, vert_url = vert_url, frag_url = frag_url })
	assert(err == nil)
	return effect }

upload_effect :: proc(effect: ^Effect) -> bool {
	if effect.verts_handle != 0 do download_effect(effect)
	gl.GenBuffers(1, &effect.verts_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.verts_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.verts) * size_of(f32), &effect.verts[0], gl.STATIC_DRAW)
	return true }

effect_is_uploaded :: proc(effect: ^Effect) -> bool {
	return effect.verts_handle != 0 }

download_effect :: proc(effect: ^Effect) {
	gl.DeleteBuffers(1,&effect.verts_handle) }
