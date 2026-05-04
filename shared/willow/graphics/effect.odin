#+feature using-stmt
package graphics
import rt "base:runtime"
import mem "core:mem"
import os "core:os"
import sl "core:slice"
import gl "vendor:OpenGL"
import "../asset_manager"
import msh "../mesh"



Effect_Config :: struct {
	url: asset_manager.URL,
	surface_res: [][2]u32 }

// Each surface is a normalized UV mesh, from which positions are computed by the vertex shader.
Effect :: struct {
	using config: Effect_Config,
	shader: Shader_Asset,
	mesh: msh.Mesh(2) }

init_effect :: proc(effect: ^Effect, config: Effect_Config, graphics_manager: ^Graphics_Manager, as_mngr: ^asset_manager.Asset_Manager, vert_url, frag_url: asset_manager.URL, allocator: rt.Allocator) {
	err: os.Error
	mesh_builder: msh.Mesh_Builder(2)
	effect.config = config
	mesh_builder = msh.make_mesh_builder(2, allocator)
	for res, i in config.surface_res do msh.builder_append_2d_square_grid(&mesh_builder, grid_size = res)
	effect.mesh = msh.mesh_from_builder(mesh_builder)
	init_shader_asset(&effect.shader, { config.url, Shader_Asset }, { vert_url, frag_url }, graphics_manager, as_mngr)
	asset_manager.asset_commands(as_mngr, Shader_Asset, &effect.shader.asset, { .Import, .Load, .Upload }) }

upload_effect :: proc(effect: ^Effect) -> bool {
	if effect.mesh.verts_handle != 0 do download_effect(effect)
	gl.GenBuffers(1, &effect.mesh.verts_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.mesh.verts_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.mesh.verts) * size_of(effect.mesh.verts[0]), &effect.mesh.verts[0], gl.STATIC_DRAW)
	gl.GenBuffers(1, &effect.mesh.surface_indexes_handle)
	gl.BindBuffer(gl.ARRAY_BUFFER, effect.mesh.surface_indexes_handle)
	gl.BufferData(gl.ARRAY_BUFFER, len(effect.mesh.surface_indexes) * size_of(effect.mesh.surface_indexes[0]), &effect.mesh.surface_indexes[0], gl.STATIC_DRAW)
	return true }

init_and_upload_effect :: proc(effect: ^Effect, config: Effect_Config, graphics_manager: ^Graphics_Manager, as_mngr: ^asset_manager.Asset_Manager, vert_url, frag_url: asset_manager.URL, allocator: rt.Allocator) {
	init_effect(effect, config, graphics_manager, as_mngr, vert_url, frag_url, allocator)
	upload_effect(effect) }

effect_is_uploaded :: proc(effect: ^Effect) -> bool {
	return effect.mesh.verts_handle != 0 }

download_effect :: proc(effect: ^Effect) {
	gl.DeleteBuffers(1, &effect.mesh.verts_handle)
	gl.DeleteBuffers(1, &effect.mesh.surface_indexes_handle) }
