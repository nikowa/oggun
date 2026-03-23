#+feature using-stmt
package graphics
import rt "base:runtime"
import mem "core:mem"
import sl "core:slice"
import gl "vendor:OpenGL"
import db "../database"
import msh "../mesh"



Effect_Config :: struct {
	url: db.URL,
	surface_res: [2]u32,
	surface_count: u32,
	shader_url: db.URL }

// Each surface is a normalized UV mesh, from which positions are computed by the vertex shader.
Effect :: struct {
	using config: Effect_Config,
	verts_handle: u32,
	verts: []f32 }

make_effect :: proc(config: Effect_Config, allocator: rt.Allocator) -> (effect: Effect) {
	effect.config = config
	verts := make([dynamic][2]f32, allocator = allocator)
	for _ in 0 ..< config.surface_count do msh.append_uv_square_grid(&verts, grid_size = config.surface_res)
	shrink(&verts)
	effect.verts = sl.reinterpret([]f32, verts[:])
	return effect }

upload_effect :: proc(effect: ^Effect) -> bool {
	if effect.verts_handle != 0 do download_effect(effect)
	gl.GenBuffers(1, &effect.verts_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.verts_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.verts) * size_of(f32), &effect.verts[0], gl.STATIC_DRAW)
	return true }

download_effect :: proc(effect: ^Effect) {
	gl.DeleteBuffers(1,&effect.verts_handle) }

render_effect_node :: proc(graphics_context: ^gx.Graphics_Context, scene: ^Scene, camera_node: ^Camera_Node, node: ^Node) {
	// TODO
}
