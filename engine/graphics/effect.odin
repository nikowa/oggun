#+feature using-stmt
package graphics
import rt "base:runtime"
import mem "core:mem"
import os "core:os"
import sl "core:slice"
import gl "vendor:OpenGL"
import as "../asset_manager"
import msh "../mesh"



Effect_Config :: struct {
	url: as.URL,
	surface_res: [][2]u32 }

// Each surface is a normalized UV mesh, from which positions are computed by the vertex shader.
Effect :: struct {
	using config: Effect_Config,
	shader: Shader_Asset,
	mesh: msh.Mesh(2) }

// verts: [][3]f32
// surface_indexes: []i32

make_effect :: proc(config: Effect_Config, gx_mngr: ^Graphics_Context, as_mngr: ^as.Asset_Manager, vert_url, frag_url: as.URL, allocator: rt.Allocator) -> (effect: Effect) {
	err: os.Error
	mesh_builder: msh.Mesh_Builder(2)

	effect.config = config
	mesh_builder = msh.make_mesh_builder(2, allocator)
	for res, i in config.surface_res do msh.builder_append_2d_square_grid(&mesh_builder, grid_size = res)
	effect.mesh = msh.mesh_from_builder(mesh_builder)
	init_shader_asset(&effect.shader, { config.url, Shader_Asset }, { vert_url, frag_url }, gx_mngr, as_mngr)
	// if err != nil do log.errorf("Failed to make shader %s, %s: %v", vert_url, frag_url, err)
	return effect }

upload_effect :: proc(effect: ^Effect) -> bool {
	if effect.mesh.verts_handle != 0 do download_effect(effect)
	gl.GenBuffers(1, &effect.mesh.verts_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.mesh.verts_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.mesh.verts) * size_of(effect.mesh.verts[0]), &effect.mesh.verts[0], gl.STATIC_DRAW)
	gl.GenBuffers(1, &effect.mesh.surface_indexes_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.mesh.surface_indexes_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.mesh.surface_indexes) * size_of(effect.mesh.surface_indexes[0]), &effect.mesh.surface_indexes[0], gl.STATIC_DRAW)
	return true }

effect_is_uploaded :: proc(effect: ^Effect) -> bool {
	return effect.mesh.verts_handle != 0 }

download_effect :: proc(effect: ^Effect) {
	gl.DeleteBuffers(1, &effect.mesh.verts_handle)
	gl.DeleteBuffers(1, &effect.mesh.surface_indexes_handle) }
