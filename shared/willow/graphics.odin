#+feature using-stmt
package willow
import "base:runtime"
import "base:intrinsics"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "core:strings"
import "core:os"
import "core:math/linalg"
import "core:time"
import "core:log"

// Rendering pipeline:
// (1) Enable emittance.
// (2) Bake 1st pass of global illumination maps.
// (3) Load all global illumination maps.
// What about shadows?

X :: 0
Y :: 1
Z :: 2
W :: 3

BLACK: [4]f32 : {0, 0, 0, 1}
WHITE: [4]f32 : {1, 1, 1, 1}
RED:   [4]f32 : {1, 0, 0, 1}
GREEN: [4]f32 : {0, 1, 0, 1}
BLUE:  [4]f32 : {0, 0, 1, 1}
CYAN:  [4]f32 : {0, 1, 1, 1}
GRAY:  [4]f32 : {0.5, 0.5, 0.5, 1}
DARK_GRAY: [4]f32 : {0.25, 0.25, 0.25, 1}

QUAD_VERTS_LEN :: 6

BACKEND: Graphics_Backend : #config(GRAPHICS_BACKEND, Graphics_Backend.OpenGL)

Graphics_Backend :: enum {
	WGPU,
	Vulkan,
	OpenGL }

Graphics_Config :: struct #all_or_none {
	window_manager: ^Window_Manager,
	clear_color: [4]f32 }

Graphics_Manager :: struct {
	using graphics_config: Graphics_Config,
	command_buffer: Command_Buffer,
	window_closed: bool,
// 	fullscreen:                      bool,
	active_resolution: [2]f32,
	stopwatch: time.Stopwatch,
	time: f32,
// 	resolution:                      [2]int,
// 	resolution_scale:                f32,
// 	last_models_write_time:          os.File_Time,
// 	models:                          [dynamic]Model,
// 	model_instances:                 [dynamic]Model_Instance,
	shaders: [dynamic]^Shader_Asset,
	// textures:                [dynamic]Texture,
	// textures_map:                    map[string]^Texture,
// 	materials:                       [dynamic]Material,
// 	models_map:                      map[string]^Model,
// 	fonts:                           [dynamic]Font,
// 	fonts_map:                       map[string]^Font,
	image_shader: Shader_Asset,
	bitmap_text_shader: Shader_Asset,
	buffer_shader: Shader_Asset,
// 	upscale_pass1_shader:            ^Upscale_Pass1_Shader,
// 	upscale_pass2_shader:            ^Upscale_Pass2_Shader,
// 	blend_shader:                    ^Blend_Shader,
// 	curvature_shader:                ^Curvature_Shader,
// 	font_shader:                     ^Font_Shader,
	rect_shader: Shader_Asset,
	line_shader: Shader_Asset,
// 	point_shader:                    ^Point_Shader,
// 	line_shader:                     ^Line_Shader,
// 	physics_shader:                  ^Physics_Shader,
	model_shader: Shader_Asset,
	mesh_shader: Shader_Asset,
// 	panel_shader:                    ^Panel_Shader,
// 	water_effect_shader:             ^Water_Effect_Shader,
// 	sdf_shader:                      ^SDF_Shader,
// 	chromatic_aberration_shader:     ^Chromatic_Aberration_Shader,
// 	physics_buffer_internal_formats: []i32,
// 	physics_buffer_formats:          []u32,
	canvas_rb: Render_Buffer,
// 	upscale_sb:                      Render_Buffer,
// 	physics_rb:                      Render_Buffer,
// 	draw_mask:                       Draw_Mask,
// 	random_colors:                   [][3]f32,
// 	glare_spots:                     [dynamic][2]int,
	frame_count: u32,
	vertex_array: u32,
	vertex_buffer: u32,
// 	cubemap:                         Cubemap
}

Compass :: enum u8 {
	East,
	West,
	North,
	South }

Render_Buffer :: struct {
	initialized: bool,
	frame_buffer_handle: u32,
	texture_handles: []u32,
	texture_formats: []u32,
	texture_internal_formats: []i32,
	render_buffer_handle: u32,
	size: [2]f32,
	n_frames: i16 }

// Render_Buffer_Data :: struct {
// 	initialized:              bool,
// 	size:                     [2]int,
// 	n_buffers:                u8,
// 	n_frames:                 i16,
// 	texture_internal_formats: []i32,
// 	depths:                   []u8,
// 	formats:                  []u8,
// 	buffers:                  [][]u8 }

graphics_init :: proc(
	graphics_manager: ^Graphics_Manager = nil,
	as_mngr: ^Asset_Manager = nil,
	graphics_config: Graphics_Config = {}) -> (err: os.Error) {
	graphics_manager.graphics_config = graphics_config
	when BACKEND == .OpenGL do init_opengl(graphics_manager)

// 	width:         i32
// 	height:        i32
// 	ok:            bool
// 	texture:       ^Texture
// 	random_colors: [dynamic][3]f32

// 	draw.window_size = settings.resolution
// 	switch settings.resolution_scale {
// 	case .PERCENT_25:  draw.resolution_scale = 0.25
// 	case .PERCENT_50:  draw.resolution_scale = 0.5
// 	case .PERCENT_100: draw.resolution_scale = 1.0
// 	case .PERCENT_200: draw.resolution_scale = 2.0
// 	case .PERCENT_400: draw.resolution_scale = 4.0 }
// 	draw.resolution = linalg.array_cast(draw.resolution_scale * linalg.array_cast(draw.window_size, f32), int)
// 	draw.active_resolution = draw.window_size
// 	draw.textures = make_dynamic_array_len_cap([dynamic]Texture, len=0, cap=64)
// 	draw.textures_map = make(map[string]^Texture)
// 	draw.materials = make_dynamic_array_len_cap([dynamic]Material, len=0, cap=32)
// 	draw.models = make_dynamic_array_len_cap([dynamic]Model, len=0, cap=32)
// 	draw.models_map = make(map[string]^Model)
// 	draw.fonts = make_dynamic_array_len_cap([dynamic]Font, len=0, cap=32)
// 	draw.fonts_map = make(map[string]^Font)
// 	draw.haze_color = { 181.0 / 255, 217.0 / 255, 255.0 / 255 }
// 	draw.draw_mask = { .MODELS, .EFFECTS }

	// DICK



	graphics_manager.active_resolution = graphics_manager.window_manager.size


// 	draw.default_sb, ok = make_scene_buffer_static(draw.resolution)
// 	assert(ok)
// 	draw.upscale_sb, ok = make_render_buffer_static(draw.window_size,1,{gl.RGBA8},{gl.RGBA})
// 	assert(ok)
// 	draw.physics_buffer_internal_formats=make([]i32,len(Physics_Buffer_Channel))
// 	draw.physics_buffer_internal_formats[int(Physics_Buffer_Channel.D_SURF)]           = gl.R32F
// 	draw.physics_buffer_internal_formats[int(Physics_Buffer_Channel.D_SURF_DISPLACED)] = gl.R32F
// 	draw.physics_buffer_internal_formats[int(Physics_Buffer_Channel.D_SURFER)]         = gl.R32F
// 	draw.physics_buffer_internal_formats[int(Physics_Buffer_Channel.N_SURF)]           = gl.RGB32F
// 	draw.physics_buffer_internal_formats[int(Physics_Buffer_Channel.N_SURF_DISPLACED)] = gl.RGB32F
// 	draw.physics_buffer_formats=make([]u32,len(Physics_Buffer_Channel))
// 	draw.physics_buffer_formats[int(Physics_Buffer_Channel.D_SURF)]           = gl.RED
// 	draw.physics_buffer_formats[int(Physics_Buffer_Channel.D_SURF_DISPLACED)] = gl.RED
// 	draw.physics_buffer_formats[int(Physics_Buffer_Channel.D_SURFER)]         = gl.RED
// 	draw.physics_buffer_formats[int(Physics_Buffer_Channel.N_SURF)]           = gl.RGB
// 	draw.physics_buffer_formats[int(Physics_Buffer_Channel.N_SURF_DISPLACED)] = gl.RGB
// 	draw.physics_rb, ok = make_physics_buffer(draw)
// 	assert(ok)
// 	new_generic_texture(draw, "dev-grid")
// 	new_generic_texture(draw, "dev-oriented-grid")
// 	new_generic_texture(draw, "skybox")
// 	new_generic_texture(draw, "sky-back")
// 	new_generic_texture(draw, "sky-front")
// 	new_generic_texture(draw, "sky-left")
// 	new_generic_texture(draw, "sky-right")
// 	new_generic_texture(draw, "sky-up")
// 	new_generic_texture(draw, "cover-static")
// 	new_generic_texture(draw, "cover_0000")
// 	new_generic_texture(draw, "cover_0001")
// 	new_generic_texture(draw, "cover_0002")
// 	new_generic_texture(draw, "cover_0003")
// 	new_generic_texture(draw, "cover_0004")
// 	new_generic_texture(draw, "cover_0005")
// 	new_generic_texture(draw, "cover_0006")
// 	new_generic_texture(draw, "cover_0007")
// 	new_generic_texture(draw, "cover_0008")
// 	new_generic_texture(draw, "cover_0009")
// 	new_generic_texture(draw, "cover_0010")
// 	new_generic_texture(draw, "cover_0011")
// 	new_generic_texture(draw, "cover_0012")
// 	new_generic_texture(draw, "cover_0013")
// 	new_generic_texture(draw, "cover_0014")
// 	new_generic_texture(draw, "cover_0015")
// 	new_generic_texture(draw, "normal-corner-pack")
// 	for _, i in draw.textures {
// 		texture = &draw.textures[i]
// 		init_texture_from_data(draw, texture, filepath.join({ working_directory_path, IMAGES_PATH_RELATIVE }), texture.name)
// 		load_texture(draw, texture) }
// 	textures_init_all_from_qoi_data(draw)
// 	load_font(draw, working_directory_path, "font")
// 	load_font(draw, working_directory_path, "terminus")
// 	load_font(draw, working_directory_path, "font-big")
// 	random_colors = make_dynamic_array_len_cap([dynamic][3]f32, 0, 32)
// 	for r in 0 ..= 4 do for g in 0 ..= 4 do for b in 0 ..= 4 {
// 		color: [3]f32 = { (cast(f32)r) / 4, (cast(f32)g) / 4, (cast(f32)b) / 4 }
// 		if linalg.length(color) > 0.1 do append(&random_colors, color) }
// 	draw.random_colors = random_colors[:]
// 	load_models_from_gltf(draw, working_directory_path, "beach")
// 	bake_models(draw, cache) // TEMP
// 	init_cubemap(&draw.cubemap, { 512, 512 })
	if as_mngr != nil {
		register_asset_kind(as_mngr, Shader_Asset, { command = shader_asset_command })
		graphics_manager.shaders = make([dynamic]^Shader_Asset, 0, 16)
		init_shader_asset(&graphics_manager.rect_shader, { "shader:rect", Shader_Asset }, { "string:vrect.glsl", "string:frect.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.line_shader, { "shader:line", Shader_Asset }, { "string:vline.glsl", "string:fline.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.image_shader, { "shader:image", Shader_Asset }, { "string:vrect.glsl", "string:fimage.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.bitmap_text_shader, { "shader:bitmap-text", Shader_Asset }, { "string:vbitmap-text.glsl", "string:fbitmap-text.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.model_shader, { "shader:model", Shader_Asset }, { "string:vmodel.glsl", "string:fmodel.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.mesh_shader, { "shader:mesh", Shader_Asset }, { "string:vmesh.glsl", "string:fmesh.glsl" }, graphics_manager, as_mngr) or_return
		init_shader_asset(&graphics_manager.buffer_shader, { "shader:buffer", Shader_Asset }, { "string:vfill.glsl", "string:fbuffer.glsl" }, graphics_manager, as_mngr) or_return
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.rect_shader.asset, .Import))
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.line_shader.asset, .Import))
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.image_shader.asset, .Import))
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.model_shader.asset, .Import))
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.mesh_shader.asset, .Import))
		assert(asset_command(as_mngr, Shader_Asset, &graphics_manager.buffer_shader.asset, .Import))
		// graphics_manager.model_shader                = make_shader_asset(draw, working_directory_path, "model",                Model_Shader,                "vmodel",   "fmodel")
		// graphics_manager.buffer_shader               = make_shader_asset(draw, working_directory_path, "buffer",               Buffer_Shader,               "vfill",    "fbuffer")
		// graphics_manager.upscale_pass1_shader        = make_shader_asset(draw, working_directory_path, "buffer",               Upscale_Pass1_Shader,        "vfill",    "fupscale-pass1")
		// graphics_manager.upscale_pass2_shader        = make_shader_asset(draw, working_directory_path, "buffer",               Upscale_Pass2_Shader,        "vfill",    "fupscale-pass2")
		// graphics_manager.blend_shader                = make_shader_asset(draw, working_directory_path, "blend",                Blend_Shader,                "vfill",    "fblend")
		// graphics_manager.curvature_shader            = make_shader_asset(draw, working_directory_path, "curvature",            Curvature_Shader,            "vfill",    "fcurvature")
		// graphics_manager.font_shader                 = make_shader_asset(draw, working_directory_path, "font",                 Font_Shader,                 "vfont",    "ffont")
		// graphics_manager.point_shader                = make_shader_asset(draw, working_directory_path, "point",                Point_Shader,                "vpoint",   "fpoint")
		// graphics_manager.line_shader                 = make_shader_asset(draw, working_directory_path, "line",                 Line_Shader,                 "vline",    "fline")
		// graphics_manager.physics_shader              = make_shader_asset(draw, working_directory_path, "physics",              Physics_Shader,              "vframe",   "fphysics")
		// graphics_manager.panel_shader                = make_shader_asset(draw, working_directory_path, "panel",                Panel_Shader,                "vrect",    "fpanel")
		// graphics_manager.water_effect_shader         = make_shader_asset(draw, working_directory_path, "effect-water",         Water_Effect_Shader,         "vframe",   "effect-water.f")
		// graphics_manager.sdf_shader                  = make_shader_asset(draw, working_directory_path, "sdf",                  SDF_Shader,                  "vframe",   "fsdf")
		// graphics_manager.chromatic_aberration_shader = make_shader_asset(draw, working_directory_path, "chromatic-aberration", Chromatic_Aberration_Shader, "vfill",    "fchromatic-aberration")
		// DICK
		graphics_manager.canvas_rb = make_render_buffer(graphics_manager.window_manager.size, { gl.RGBA8, gl.R32F, gl.R32UI }, { gl.RGBA, gl.RED, gl.RED_INTEGER }, { gl.UNSIGNED_BYTE, gl.UNSIGNED_BYTE, gl.UNSIGNED_INT }, samples = 1)
		register_asset_kind(as_mngr, Image_Asset, { command = image_asset_command })
		register_asset_kind(as_mngr, Material_Asset, { command = image_asset_command }) }
	else {
		log.warn("No asset manager.") }
	zero_stopwatch(&graphics_manager.stopwatch)
	return nil }

select_render_buffer :: proc(graphics_manager: ^Graphics_Manager, render_buffer: ^Render_Buffer) {
	if render_buffer == nil { select_frame_buffer(graphics_manager, 0) }
	graphics_manager.active_resolution = render_buffer.size
	gl.BindFramebuffer(gl.FRAMEBUFFER, cast(u32)render_buffer.frame_buffer_handle)
	gl.Viewport(0, 0, cast(i32)graphics_manager.active_resolution.x, cast(i32)graphics_manager.active_resolution.y) }

clear_render_buffer :: proc(render_buffer: ^Render_Buffer) {
	gl.BindFramebuffer(gl.FRAMEBUFFER, cast(u32)render_buffer.frame_buffer_handle)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	gl.Clear(gl.DEPTH_BUFFER_BIT) }

select_frame_buffer :: proc(graphics_manager: ^Graphics_Manager, frame_buffer_handle: u32) {
	graphics_manager.active_resolution = graphics_manager.window_manager.size
	gl.BindFramebuffer(gl.FRAMEBUFFER, frame_buffer_handle)
	gl.Viewport(0, 0, cast(i32)graphics_manager.window_manager.size.x, cast(i32)graphics_manager.window_manager.size.y) }

clear_frame_buffer :: proc(frame_buffer_handle: u32) {
	gl.BindFramebuffer(gl.FRAMEBUFFER, frame_buffer_handle)
	gl.Clear(gl.COLOR_BUFFER_BIT)
	gl.Clear(gl.DEPTH_BUFFER_BIT) }


// make_scene_buffer_static :: proc(res: [2]int) -> (Render_Buffer, bool) {
// 	return make_render_buffer_static(res, 5, { gl.RGBA8, AUX_BUF_FMT, AUX_BUF_FMT, gl.R8, gl.R8 }, {gl.RGBA, gl.RGB, gl.RGB, gl.RED, gl.RED }) }


// init_scene_buffer_static :: proc(scene_buffer: ^Render_Buffer, res: [2]int) -> bool {
// 	return init_render_buffer_static(scene_buffer, res, 5, { gl.RGBA8, AUX_BUF_FMT, AUX_BUF_FMT, gl.R8, gl.R8 }, { gl.RGBA, gl.RGB, gl.RGB, gl.RED, gl.RED }) }


// make_scene_buffer_data_static :: proc(res: [2]int) -> (Render_Buffer_Data, bool) {
// 	return make_render_buffer_data_static(res, 5, { 4, 3, 3, 1, 1 }, { gl.RGBA8, AUX_BUF_FMT, AUX_BUF_FMT, gl.R8, gl.R8 }) }


// init_scene_buffer_data_static :: proc(render_buffer_data: ^Render_Buffer_Data, res: [2]int) -> bool {
// 	return init_render_buffer_data_static(render_buffer_data, res, 5, { 4, 3, 3, 1, 1 }, { gl.RGBA8, AUX_BUF_FMT, AUX_BUF_FMT, gl.R8, gl.R8 }) }


make_render_buffer :: proc(size: [2]f32, internal_formats: []i32, formats: []u32, data_types: []u32, samples: int = 1, depth_component: bool = true) -> (render_buffer: Render_Buffer) {
	init_render_buffer(&render_buffer, size, internal_formats, formats, data_types, samples, depth_component)
	return render_buffer }


// make_physics_buffer :: proc(draw: ^Draw) -> (Render_Buffer, bool) {
// 	return make_render_buffer_static({ 1, 1 }, len(Physics_Buffer_Channel), draw.physics_buffer_internal_formats, draw.physics_buffer_formats) }


// read_physics_render_buffer :: proc(draw: ^Draw) -> (d_surf: f32, d_surf_displaced: f32, d_surfer: f32, n_surf: [3]f32, n_surf_displaced: [3]f32) {
// 	rb:     ^Render_Buffer
// 	buffer: [3]f32
// 	i:      int

// 	rb = &draw.physics_rb
// 	i = int(Physics_Buffer_Channel.D_SURF)
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, draw.physics_buffer_formats[i], gl.FLOAT, cast(rawptr)&buffer[0])
// 	d_surf = buffer[0]
// 	i = cast(int)Physics_Buffer_Channel.D_SURF_DISPLACED
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, draw.physics_buffer_formats[i], gl.FLOAT, cast(rawptr)&buffer[0])
// 	d_surf_displaced = buffer[0]
// 	i = cast(int)Physics_Buffer_Channel.D_SURFER
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, draw.physics_buffer_formats[i], gl.FLOAT, cast(rawptr)&buffer[0])
// 	d_surfer = buffer[0]
// 	i = cast(int)Physics_Buffer_Channel.N_SURF
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, draw.physics_buffer_formats[i], gl.FLOAT, cast(rawptr)&buffer[0])
// 	n_surf = [3]f32{ buffer[0], buffer[1], buffer[2] }
// 	i = cast(int)Physics_Buffer_Channel.N_SURF_DISPLACED
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, draw.physics_buffer_formats[i], gl.FLOAT, cast(rawptr)&buffer[0])
// 	n_surf_displaced = [3]f32{ buffer[0], buffer[1], buffer[2] }
// 	return d_surf, d_surf_displaced, d_surfer, n_surf, n_surf_displaced }


init_render_buffer :: proc(render_buffer: ^Render_Buffer, size: [2]f32, internal_formats: []i32, formats: []u32, data_types: []u32, samples: int = 1, depth_component: bool = true) {
	assert(render_buffer != nil)
	assert(!((size.x == 0) || (size.y == 0) || (len(internal_formats) == 0) || (len(internal_formats) != len(formats))))
	n_buffers := len(internal_formats)
	render_buffer.size = size
	render_buffer.texture_formats = make([]u32, len(formats))
	render_buffer.n_frames = 1
	copy(render_buffer.texture_formats, formats)
	render_buffer.texture_internal_formats = make([]i32, len(internal_formats))
	copy(render_buffer.texture_internal_formats, internal_formats)
	gl.GenFramebuffers(1, cast(^u32)&render_buffer.frame_buffer_handle)
	gl.BindFramebuffer(gl.FRAMEBUFFER, cast(u32)render_buffer.frame_buffer_handle)
	render_buffer.texture_handles = make([]u32, n_buffers) // NOTE This is not freed. //
	for i in 0 ..< n_buffers {
		if samples > 1 {
			gl.GenTextures(cast(i32)n_buffers, cast(^u32)&render_buffer.texture_handles[i])
			gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, cast(u32)render_buffer.texture_handles[i])
			// gl.TexParameteri(gl.TEXTURE_2D_MULTISAMPLE, gl.TEXTURE_WRAP_S, gl.REPEAT)
			// gl.TexParameteri(gl.TEXTURE_2D_MULTISAMPLE, gl.TEXTURE_WRAP_T, gl.REPEAT)
			// gl.TexParameteri(gl.TEXTURE_2D_MULTISAMPLE, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
			// gl.TexParameteri(gl.TEXTURE_2D_MULTISAMPLE, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
			gl.TexImage2DMultisample(gl.TEXTURE_2D_MULTISAMPLE, cast(i32)samples, cast(u32)internal_formats[i], cast(i32)size.x, cast(i32)size.y, true)
			gl.FramebufferTexture2D(gl.FRAMEBUFFER, cast(u32)(gl.COLOR_ATTACHMENT0+i), gl.TEXTURE_2D_MULTISAMPLE, cast(u32)render_buffer.texture_handles[i], 0)
			gl.BindTexture(gl.TEXTURE_2D_MULTISAMPLE, 0) }
		else {
			gl.GenTextures(cast(i32)n_buffers, cast(^u32)&render_buffer.texture_handles[i])
			gl.BindTexture(gl.TEXTURE_2D, cast(u32)render_buffer.texture_handles[i])
			gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
			gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
			gl.TexImage2D(gl.TEXTURE_2D, 0, internal_formats[i], cast(i32)size.x, cast(i32)size.y, 0, formats[i], data_types[i], nil)
			texture_filtering(gl.NEAREST)
			gl.BindTexture(gl.TEXTURE_2D, 0)
			gl.FramebufferTexture2D(gl.FRAMEBUFFER, cast(u32)(gl.COLOR_ATTACHMENT0+i), gl.TEXTURE_2D, cast(u32)render_buffer.texture_handles[i], 0) } }
	status := gl.CheckFramebufferStatus(gl.FRAMEBUFFER)
	assert(status == gl.FRAMEBUFFER_COMPLETE)
	gl.GenRenderbuffers(1, cast(^u32)&render_buffer.render_buffer_handle)
	if depth_component {
		gl.BindRenderbuffer(gl.RENDERBUFFER, cast(u32)render_buffer.render_buffer_handle)
		if samples > 1 {
			gl.RenderbufferStorageMultisample(gl.RENDERBUFFER, 8, gl.DEPTH_COMPONENT32, cast(i32)size.x, cast(i32)size.y) }
		else {
			gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT32, cast(i32)size.x, cast(i32)size.y) }
		gl.FramebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, cast(u32)render_buffer.render_buffer_handle) }
	assert(gl.CheckFramebufferStatus(gl.FRAMEBUFFER) == gl.FRAMEBUFFER_COMPLETE)
	render_buffer.initialized = true }


// make_render_buffer_data_static :: proc(size: [2]int, n_buffers: int, depths: []u8, internal_formats: []i32) -> (Render_Buffer_Data, bool) {
// 	render_buffer_data: Render_Buffer_Data
// 	ok:                 bool

// 	ok = init_render_buffer_data_static(&render_buffer_data, size, n_buffers, depths, internal_formats)
// 	return render_buffer_data, ok }


// init_render_buffer_data_static :: proc(render_buffer_data: ^Render_Buffer_Data, size: [2]int, n_buffers: int, depths: []u8, internal_formats: []i32) -> bool {
// 	assert(render_buffer_data != nil); if render_buffer_data == nil { return false }
// 	render_buffer_data.buffers = make([][]u8, len(depths)) // NOTE This is not freed. //
// 	render_buffer_data.formats = make([]u8, n_buffers)
// 	render_buffer_data.texture_internal_formats = make([]i32, len(internal_formats)) // NOTE This is not freed. //
// 	render_buffer_data.depths = slice.clone(depths) // NOTE This not freed. //
// 	for i in 0 ..< n_buffers {
// 		render_buffer_data.buffers[i] = make([]u8, cast(int)size.x * cast(int)size.y * cast(int)depths[i]) // NOTE This is not freed. //
// 		render_buffer_data.texture_internal_formats[i] = internal_formats[i]
// 		render_buffer_data.formats[i] = RB_RAW }
// 	render_buffer_data.size = size
// 	render_buffer_data.n_buffers = cast(u8)n_buffers
// 	render_buffer_data.initialized = true
// 	return true }


// delete_render_buffer :: proc(render_buffer: ^Render_Buffer) {
// 	if render_buffer == nil { return }
// 	gl.DeleteFramebuffers(1, cast(^u32)&render_buffer.frame_buffer_handle)
// 	for i in 0 ..< len(render_buffer.texture_handles) {
// 		gl.DeleteTextures(1, cast(^u32)&render_buffer.texture_handles) }
// 	gl.DeleteRenderbuffers(1, cast(^u32)&render_buffer.render_buffer_handle) }


// buffer_to_texture :: proc(buffer: ^Render_Buffer, texture: rawptr, channel: int = 0) {
// 	gl.BindTexture(gl.TEXTURE_2D, cast(u32)buffer.texture_handles[channel])
// 	gl.GetTexImage(gl.TEXTURE_2D, 0, gl.RGBA, gl.UNSIGNED_BYTE, texture) }


get_shader_param_handle :: proc(shader_handle: u32, param_name: string) -> (handle: i32) {
	cstr: cstring

	cstr = strings.clone_to_cstring(param_name)
	handle = gl.GetUniformLocation(shader_handle, cstr)
	delete(cstr)
	return handle }


uniform_1f :: #force_inline proc(shader: u32, name: cstring, param: f32) {
	gl.Uniform1f(gl.GetUniformLocation(cast(u32)shader, name), cast(f32)param) }


set_shader_param_1f32 :: #force_inline proc(#any_int param_handle: i32, value: f32) {
	gl.Uniform1f(param_handle, value) }


uniform_2f :: #force_inline proc(shader: u32, name: cstring, param_x: f32, param_y: f32) {
	gl.Uniform2f(gl.GetUniformLocation(cast(u32)shader, name), cast(f32)param_x, cast(f32)param_y) }


set_shader_param_2f32 :: #force_inline proc(#any_int param_handle: i32, value: [2]f32) {
	gl.Uniform2f(param_handle, value.x, value.y) }


uniform_3f :: #force_inline proc(shader: u32, name: cstring, param_x: f32, param_y: f32, param_z: f32) {
	gl.Uniform3f(gl.GetUniformLocation(cast(u32)shader, name), cast(f32)param_x, cast(f32)param_y, cast(f32)param_z) }


set_shader_param_3f32 :: #force_inline proc(#any_int param_handle: i32, value: [3]f32) {
	gl.Uniform3f(param_handle, value.x, value.y, value.z) }


uniform_4f :: #force_inline proc(shader: u32, name: cstring, param_x: f32, param_y: f32, param_z: f32, param_w: f32) {
	gl.Uniform4f(gl.GetUniformLocation(cast(u32)shader, name), cast(f32)param_x, cast(f32)param_y, cast(f32)param_z, cast(f32)param_w) }


set_shader_param_4f32 :: #force_inline proc(#any_int param_handle: i32, value: [4]f32) {
	gl.Uniform4f(param_handle, cast(f32)value.x, cast(f32)value.y, cast(f32)value.z, cast(f32)value.w) }


uniform_1i :: #force_inline proc(shader: u32, name: cstring, #any_int param: int) {
	gl.Uniform1i(gl.GetUniformLocation(cast(u32)shader, name), cast(i32)param) }


set_shader_param_1i32 :: #force_inline proc(#any_int param_handle: i32, value: i32) {
	gl.Uniform1i(param_handle, value) }


set_shader_param_1i16 :: #force_inline proc(#any_int param_handle: i32, value: i16) {
	gl.Uniform1i(param_handle, cast(i32)value) }


set_shader_param_1i8 :: #force_inline proc(#any_int param_handle: i32, value: i8) {
	gl.Uniform1i(param_handle, cast(i32)value) }


set_shader_param_1u32 :: #force_inline proc(#any_int param_handle: i32, value: u32) {
	gl.Uniform1ui(param_handle, cast(u32)value) }


set_shader_param_1u16 :: #force_inline proc(#any_int param_handle: i32, value: u16) {
	gl.Uniform1ui(param_handle, cast(u32)value) }


set_shader_param_1u8 :: #force_inline proc(#any_int param_handle: i32, value: u8) {
	gl.Uniform1ui(param_handle, cast(u32)value) }


uniform_2i :: #force_inline proc(shader: u32, name: cstring, #any_int param_x: int, #any_int param_y: int) {
	gl.Uniform2i(gl.GetUniformLocation(cast(u32)shader, name), cast(i32)param_x, cast(i32)param_y) }


set_shader_param_2i32 :: #force_inline proc(#any_int param_handle: i32, value: [2]i32) {
	gl.Uniform2i(param_handle, value.x, value.y) }


set_shader_param_2i16 :: #force_inline proc(#any_int param_handle: i32, value: [2]i16) {
	gl.Uniform2i(param_handle, cast(i32)value.x, cast(i32)value.y) }


set_shader_param_2i8 :: #force_inline proc(#any_int param_handle: i32, value: [2]i8) {
	gl.Uniform2i(param_handle, cast(i32)value.x, cast(i32)value.y) }


set_shader_param_2u32 :: #force_inline proc(#any_int param_handle: i32, value: [2]u32) {
	gl.Uniform2i(param_handle, cast(i32)value.x, cast(i32)value.y) }


set_shader_param_2u16 :: #force_inline proc(#any_int param_handle: i32, value: [2]u16) {
	gl.Uniform2i(param_handle, cast(i32)value.x, cast(i32)value.y) }


set_shader_param_2u8 :: #force_inline proc(#any_int param_handle: i32, value: [2]u8) {
	gl.Uniform2i(param_handle, cast(i32)value.x, cast(i32)value.y) }


uniform_3i :: #force_inline proc(shader: u32, name: cstring, #any_int param_x: int, #any_int param_y: int, #any_int param_z: int) {
	gl.Uniform3i(gl.GetUniformLocation(cast(u32)shader, name), cast(i32)param_x, cast(i32)param_y, cast(i32)param_z) }


set_shader_param_3i32 :: #force_inline proc(#any_int param_handle: i32, value: [3]i32) {
	gl.Uniform3i(param_handle, value.x, value.y, value.z) }


set_shader_param_3i16 :: #force_inline proc(#any_int param_handle: i32, value: [3]i16) {
	gl.Uniform3i(param_handle, cast(i32)value.x, cast(i32)value.y, cast(i32)value.z) }


set_shader_param_3i8 :: #force_inline proc(#any_int param_handle: i32, value: [3]i8) {
	gl.Uniform3i(param_handle, cast(i32)value.x, cast(i32)value.y, cast(i32)value.z) }


set_shader_param_3u32 :: #force_inline proc(#any_int param_handle: i32, value: [3]u32) {
	gl.Uniform3i(param_handle, cast(i32)value.x, cast(i32)value.y, cast(i32)value.z) }


set_shader_param_3u16 :: #force_inline proc(#any_int param_handle: i32, value: [3]u16) {
	gl.Uniform3i(param_handle, cast(i32)value.x, cast(i32)value.y, cast(i32)value.z) }


set_shader_param_3u8 :: #force_inline proc(#any_int param_handle: i32, value: [3]u8) {
	gl.Uniform3i(param_handle, cast(i32)value.x, cast(i32)value.y, cast(i32)value.z) }


uniform_4i :: #force_inline proc(shader: u32, name: cstring, #any_int param_x: int, #any_int param_y: int, #any_int param_z: int, #any_int param_w: int) {
	gl.Uniform4i(gl.GetUniformLocation(cast(u32)shader, name), cast(i32)param_x, cast(i32)param_y, cast(i32)param_z, cast(i32)param_w) }


uniform_matrix_4f :: #force_inline proc(shader: u32, name: cstring, value: [^]f32) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(cast(u32)shader, name), 1, false, value) }


set_shader_param_matrix_4f :: #force_inline proc(#any_int param_handle: i32, value: ^matrix[4, 4]f32) {
	gl.UniformMatrix4fv(param_handle, 1, false, &value[0][0]) }


set_shader_param :: proc {
	set_shader_param_1f32,
	set_shader_param_2f32,
	set_shader_param_3f32,
	set_shader_param_4f32,
	set_shader_param_1i32,
	set_shader_param_1i16,
	set_shader_param_1i8,
	set_shader_param_1u32,
	set_shader_param_1u16,
	set_shader_param_1u8,
	set_shader_param_2i32,
	set_shader_param_2i16,
	set_shader_param_2i8,
	set_shader_param_2u32,
	set_shader_param_2u16,
	set_shader_param_2u8,
	set_shader_param_3i32,
	set_shader_param_3i16,
	set_shader_param_3i8,
	set_shader_param_3u32,
	set_shader_param_3u16,
	set_shader_param_3u8,
	set_shader_param_matrix_4f }


bind_texture :: proc(binding_index: u32, handle: u32) {
	gl.ActiveTexture(gl.TEXTURE0 + binding_index)
	gl.BindTexture(gl.TEXTURE_2D, cast(u32)handle) }

// (TODO): Make count be the number of triangles. //
draw_triangles :: proc(count: i32) {
    gl.DrawArrays(gl.TRIANGLES, 0, count) }

// (TODO): Make count be the number of lines. //
draw_lines :: proc(count: i32) {
    gl.DrawArrays(gl.LINES, 0, count) }

draw_points :: proc(count: i32) {
    gl.DrawArrays(gl.POINTS, 0, count) }

use_shader :: proc(shader: ^Shader_Asset, loc := #caller_location) {
	assert(shader.handle != 0, loc = loc)
	gl.UseProgram(shader.handle) }

// set_blend :: proc(value: bool) {
// 	if value { gl.Enable(gl.BLEND) } else { gl.Disable(gl.BLEND) } }


set_depth_test :: proc(value: bool) {
	if value { gl.Enable(gl.DEPTH_TEST) } else { gl.Disable(gl.DEPTH_TEST) } }

upload_vertex_buffer_data :: proc(attribute_index: u32, buffer: u32, components: i32, type: u32, data: []$T) {
	gl.BindBuffer(gl.ARRAY_BUFFER, buffer)
	gl.BufferData(gl.ARRAY_BUFFER, len(data) * size_of(T), &data[0], gl.DYNAMIC_DRAW)
	switch type {
	case gl.INT, gl.UNSIGNED_INT:
		gl.VertexAttribIPointer(attribute_index, components, type, 0, 0)
	case:
		gl.VertexAttribPointer(attribute_index, components, type, false, 0, 0) }
	gl.EnableVertexAttribArray(attribute_index) }

new_buffer :: proc() -> (buffer: u32) {
	gl.GenBuffers(1, &buffer)
	return buffer }

delete_buffer :: proc(buffer: u32) {
	buffer := buffer
	gl.DeleteBuffers(1, &buffer) }

make_buffers :: proc($count: int) -> (buffers: [count]u32) {
	gl.GenBuffers(cast(i32)count, &buffers[0])
	return buffers }

delete_buffers :: proc(buffers: [$N]u32) {
	buffers := buffers
	gl.DeleteBuffers(cast(i32)N, &buffers[0]) }

// Plot :: struct {
// 	x0: f32,
// 	y0: f32,
// 	x1: f32,
// 	y1: f32 }


// render_plot_begin :: proc(draw: ^Draw, x0, y0, x1, y1: f32) -> Plot {
// 	render_rect_hollow(draw, pos = { (x0 + x1) / 2, (y0 + y1) / 2 }, size = { x1 - x0, y1 - y0 }, color = CYAN)
// 	return Plot {
// 		x0 = x0,
// 		y0 = y0,
// 		x1 = x1,
// 		y1 = y1 } }


// render_plot_point :: proc(draw: ^Draw, plot: Plot, x: f32, y: f32) {
// 	render_rect(draw, pos = {plot.x0 + (plot.x1 - plot.x0) * x, plot.y0 + (plot.y1 - plot.y0) * y }, size = { 2, 2 }, fill_color = BLUE) }


// render_crosshair :: proc(draw: ^Draw, pos: [2]f32) {
// 	crosshair_gap:       f32 = 4
// 	crosshair_thickness: f32 = 2
// 	crosshair_length:    f32 = 5
// 	crosshair_color:     [4]f32 = {0,1,0,1}
// 	offset:              f32 = crosshair_gap + crosshair_length / 2

// 	render_rect_outlined(draw, pos = pos + { offset, 0 }, size = { crosshair_length, crosshair_thickness }, fill_color = crosshair_color, outline_color = BLACK)
// 	render_rect_outlined(draw, pos = pos + { -offset, 0 }, size = { crosshair_length, crosshair_thickness }, fill_color = crosshair_color, outline_color = BLACK)
// 	render_rect_outlined(draw, pos = pos + { 0, offset }, size = { crosshair_thickness, crosshair_length }, fill_color = crosshair_color, outline_color = BLACK)
// 	render_rect_outlined(draw, pos = pos + { 0, -offset }, size = { crosshair_thickness, crosshair_length }, fill_color = crosshair_color, outline_color = BLACK) }

Render_Rect_Command :: struct {
	using params: Render_Rect_Params,
	using group_params: Render_Rect_Group_Params }

Render_Rect_Params :: struct {
	rect: Rect,
	fill_color: [4]f32,
	rounding: f32,
	depth: f32 }

Render_Rect_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer) }

// layout(location = 0) in vec4 rect;
// layout(location = 1) in float depth;
// layout(location = 2) in vec4 fill_color;
// layout(location = 3) in float rounding;

render_rect :: proc(graphics_man: ^Graphics_Manager, rect: Rect, fill_color: [4]f32 = BLACK, rounding: f32 = 0.0, depth: f32 = 0.0, render_buffer: Maybe(^Render_Buffer) = nil) {
	command: Render_Rect_Command = {
		render_buffer = render_buffer,
		rect = rect,
		fill_color = fill_color,
		rounding = rounding,
		depth = depth }
	command_buffer_record(&graphics_man.command_buffer, { variant = command }) }

submit_render_rect :: proc(graphics_man: ^Graphics_Manager, _command: Command, index: int) {
	using Rect_Shader_Uniforms

	command := _command.variant.(Render_Rect_Command)

	use_shader(&graphics_man.rect_shader)
	set_shader_param(RES, graphics_man.active_resolution)

	commands := command_buffer_get_group(&graphics_man.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Render_Rect_Command, _command_0, _command_1) })

	buffers := make_buffers(4)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	fill_color := make([][4]f32, n)
	rounding := make([]f32, n)
	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.variant.(Render_Rect_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth
		fill_color[k] = command.fill_color
		rounding[k] = command.rounding }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)
	upload_vertex_buffer_data(2, buffers[2], 4, gl.FLOAT, fill_color)
	upload_vertex_buffer_data(3, buffers[3], 1, gl.FLOAT, rounding)

	polygon_mode(.Fill)
	draw_triangles(cast(i32)n) }

// render_rect :: proc(graphics_manager: ^Graphics_Manager, rect: Rect, fill_color: [4]f32 = BLACK, rounding: f32 = 0.0, depth: f32 = 0.0) {
// 	using Rect_Shader_Uniforms
// 	use_shader(&graphics_manager.rect_shader)
// 	set_shader_param(FILL_COLOR, fill_color)
// 	set_shader_param(ROUNDING, rounding)
// 	set_shader_param(DEPTH, depth)
// 	set_shader_param(RES, graphics_manager.active_resolution)
// 	draw_triangles(6) }

render_rect_hollow :: proc(graphics_manager: ^Graphics_Manager, rect: Rect, color: [4]f32 = BLACK, depth: f32 = 0.0) {
	a: [2]f32 = { rect.pos.x - rect.size.x / 2, rect.pos.y - rect.size.y / 2 }
	b: [2]f32 = { rect.pos.x + rect.size.x / 2, rect.pos.y - rect.size.y / 2 }
	c: [2]f32 = { rect.pos.x - rect.size.x / 2, rect.pos.y + rect.size.y / 2 }
	d: [2]f32 = { rect.pos.x + rect.size.x / 2, rect.pos.y + rect.size.y / 2 }
	render_line(graphics_manager, { a, b }, color, depth)
	render_line(graphics_manager, { b, d }, color, depth)
	render_line(graphics_manager, { d, c }, color, depth)
	render_line(graphics_manager, { c, a }, color, depth) }

render_line :: proc(graphics_manager: ^Graphics_Manager, points: [2][2]f32, color: [4]f32 = BLACK, depth: f32 = 0.0) {
	using Line_Shader_Uniforms
	use_shader(&graphics_manager.line_shader)
	set_shader_param(POINTS, [4]f32{ points[0].x, points[0].y, points[1].x, points[1].y })
	set_shader_param(RES, graphics_manager.active_resolution)
	set_shader_param(COLOR, color)
	set_shader_param(DEPTH, depth)
	polygon_mode(.Line)
	draw_lines(2) }

Render_Image_Command :: struct {
	using params: Render_Image_Params,
	using group_params: Render_Image_Group_Params }

Render_Image_Params :: struct {
	rect: Rect,
	depth: f32 }

Render_Image_Group_Params :: struct {
	render_buffer: Maybe(^Render_Buffer),
	image: ^Image_Asset }

render_image :: proc(graphics_man: ^Graphics_Manager, image: ^Image_Asset, rect: Rect, depth: f32 = 0.0, render_buffer: Maybe(^Render_Buffer) = nil) {
	command: Render_Image_Command = {
		render_buffer = render_buffer,
		image = image,
		rect = rect,
		depth = depth }
	command_buffer_record(&graphics_man.command_buffer, { variant = command }) }

// (NOTE): This will do the batching. //
submit_render_image :: proc(graphics_man: ^Graphics_Manager, _command: Command, index: int) {
	// using Image_Uniforms
	// assert(image_loaded(command.image))
	// use_shader(&graphics_man.image_shader)
	// gl.BindVertexArray(graphics_man.vertex_array)
	// gl.BindBuffer(gl.ARRAY_BUFFER, graphics_man.vertex_buffer)
	// set_shader_param(POS, command.rect.pos)
	// set_shader_param(SIZE, command.rect.size)
	// bind_texture(0, command.image.handle)
	// texture_filtering(gl.NEAREST)
	// draw_triangles(6)

	using Image_Shader_Uniforms

	command := _command.variant.(Render_Image_Command)

	assert(image_loaded(command.image))
	use_shader(&graphics_man.image_shader)
	set_shader_param(RES, linalg.array_cast(graphics_man.active_resolution, f32))

	commands := command_buffer_get_group(&graphics_man.command_buffer, index, proc(_command_0, _command_1: Command) -> (ok: bool) { return commands_compare_params(Render_Image_Command, _command_0, _command_1) })

	buffers := make_buffers(2)
	defer delete_buffers(buffers)

	n: int = QUAD_VERTS_LEN * len(commands)
	rect := make([]Rect, n)
	depth := make([]f32, n)
	for _command, i in commands do for j in 0 ..< QUAD_VERTS_LEN {
		command := _command.variant.(Render_Image_Command)
		k := QUAD_VERTS_LEN * i + j
		rect[k] = command.rect
		depth[k] = command.depth }
	upload_vertex_buffer_data(0, buffers[0], 4, gl.FLOAT, rect)
	upload_vertex_buffer_data(1, buffers[1], 1, gl.FLOAT, depth)

	bind_texture(0, command.image.handle)
	polygon_mode(.Fill)
	texture_filtering(gl.NEAREST)
	draw_triangles(cast(i32)n) }

// render_image :: proc(graphics_manager: ^Graphics_Manager, image: ^Image_Asset, rect: Rect, depth: f32 = 0.0) {
// 	using Image_Uniforms
// 	assert(image_loaded(image))
// 	use_shader(&graphics_manager.image_shader)
// 	gl.BindVertexArray(graphics_manager.vertex_array)
// 	gl.BindBuffer(gl.ARRAY_BUFFER, graphics_manager.vertex_buffer)
// 	set_shader_param(POS, rect.pos)
// 	set_shader_param(SIZE, rect.size)
// 	set_shader_param(RES, linalg.array_cast(graphics_manager.active_resolution, f32))
// 	bind_texture(0, image.handle)
// 	texture_filtering(gl.NEAREST)
// 	draw_triangles(6) }

render_render_buffer :: proc(graphics_manager: ^Graphics_Manager, render_buffer: ^Render_Buffer, channel: u32) {
	using Buffer_Shader_Uniforms
	use_shader(&graphics_manager.buffer_shader)
	set_shader_param(RES, linalg.array_cast(graphics_manager.active_resolution, f32))
	bind_texture(0, render_buffer.texture_handles[cast(int)channel])
	texture_filtering(gl.LINEAR)
	polygon_mode(.Fill)
	draw_triangles(6) }

// render_panel :: proc(draw: ^Draw, background: ^Render_Buffer, pos: [2]f32, size: [2]f32) {
// 	shader := use_shader(draw.panel_shader)
// 	set_shader_param(shader.pos, pos)
// 	set_shader_param(shader.size, size)
// 	set_shader_param(shader.res, linalg.array_cast(draw.active_resolution, f32))
// 	bind_texture(0, background.texture_handles[0])
// 	texture_filtering(gl.LINEAR)
// 	bind_texture(1, draw.textures_map["normal-corner-pack"].handle)
// 	draw_triangles(6) }

// render_rect_wireframe :: proc(draw: ^Draw, pos: [2]f32, size: [2]f32, fill_color: [4]f32 = BLACK) {
// 	shader := use_shader(draw.rect_shader)
// 	set_shader_param(shader.pos, pos)
// 	set_shader_param(shader.size, size)
// 	set_shader_param(shader.fill_color, fill_color)
// 	set_shader_param(shader.res, linalg.array_cast(draw.active_resolution, f32))
// 	polygon_mode(.Line)
// 	draw_triangles(6) }

// render_rect_outlined :: proc(draw: ^Draw, pos: [2]f32, size: [2]f32, fill_color: [4]f32 = BLACK, outline_color: [4]f32 = WHITE) {
// 	shader := use_shader(draw.rect_shader)
// 	set_shader_param(shader.pos, pos)
// 	set_shader_param(shader.size, size + { 2, 2 })
// 	set_shader_param(shader.fill_color, outline_color)
// 	set_shader_param(shader.res, linalg.array_cast(draw.active_resolution, f32))
// 	draw_triangles(6)
// 	set_shader_param(shader.fill_color, fill_color)
// 	set_shader_param(shader.size, size)
// 	draw_triangles(6) }

// render_triangle :: proc(draw: ^Draw, points: [3][2]f32, color: [4]f32 = BLACK, dashed: bool = false, thickness: f32 = 1) {
// 	render_line(draw, points[0], points[1], color, dashed, thickness)
// 	render_line(draw, points[1], points[2], color, dashed, thickness)
// 	render_line(draw, points[2], points[0], color, dashed, thickness) }


// render_line :: proc(draw: ^Draw, source: [2]f32, target: [2]f32, color: [4]f32 = WHITE, dashed: bool = false, thickness: f32 = 1) {
// 	shader := use_shader(draw.line_shader)
// 	gl.LineWidth(thickness)
// 	set_shader_param(shader.line, [4]f32{ source.x, source.y, target.x, target.y})
// 	set_shader_param(shader.this_buffer_res, linalg.array_cast(draw.active_resolution, f32))
// 	set_shader_param(shader.line_color, color)
// 	set_shader_param(shader.dashed, cast(i32)dashed)
// 	polygon_mode(gl.Line)
// 	draw_lines(2) }


// render_texture :: proc {
// 	render_texture_by_name,
// 	render_texture_by_ptr,
// 	render_texture_by_handle }


// render_texture_by_name :: proc(draw: ^Draw, name: string, pos: [2]f32, size_override: [2]f32 = {-1,-1}, depth: f32 = 0.0) {
// 	render_texture_by_ptr(draw, draw.textures_map[name], pos, size_override, depth) }


// render_texture_by_ptr :: proc(draw: ^Draw, texture: ^Texture, pos: [2]f32, size_override: [2]f32 = {-1,-1}, depth: f32 = 0.0) {
// 	render_texture_by_handle(
// 		draw,
// 		handle = texture.handle,
// 		pos = pos,
// 		size = size_override != { -1, -1 } ? size_override : [2]f32{ cast(f32)texture.width, cast(f32)texture.height },
// 		depth = depth) }


// render_chromatic_aberration :: proc(draw: ^Draw, texture_handle: u32) {
// 	shader := use_shader(draw.chromatic_aberration_shader)
// 	bind_texture(0, texture_handle)
// 	texture_filtering(gl.LINEAR)
// 	draw_triangles(6) }


// upscale_texture :: proc(draw: ^Draw, render_buffer: ^Render_Buffer, channel: int) {
// 	select_render_buffer(draw, &draw.upscale_sb)
// 	gl.Viewport(0, 0, cast(i32)draw.window_size.x, cast(i32)draw.window_size.y)
// 	shader := use_shader(draw.upscale_pass1_shader)
// 	set_shader_param(shader.resolution, linalg.array_cast(draw.resolution, f32))
// 	set_shader_param(shader.window_size, linalg.array_cast(draw.window_size, f32))
// 	bind_texture(0, render_buffer.texture_handles[channel])
// 	texture_filtering(gl.NEAREST)
// 	draw_triangles(6)
// 	select_frame_buffer(draw,0)
// 	//render_buffer_texture(draw.upscale_sb,0)
// 	gl.Viewport(0, 0, cast(i32)draw.window_size.x, cast(i32)draw.window_size.y)
// 	use_shader(draw.upscale_pass2_shader)
// 	//gl.Viewport(0,0,i32(draw.window_size.x),i32(draw.window_size.y))
// 	set_shader_param(draw.upscale_pass2_shader.window_size, linalg.array_cast(draw.window_size, f32))
// 	bind_texture(0, draw.upscale_sb.texture_handles[0])
// 	texture_filtering(gl.NEAREST)
// 	draw_triangles(6) }


// set_effect_shader_params :: proc(draw: ^Draw, camera: ^Camera, net_time: f32, shader: $T) {
// 	set_shader_param(shader.time, net_time)
// 	set_shader_param(shader.res,  linalg.array_cast(draw.resolution, f32))
// 	set_shader_param(shader.camera_far_clip, camera.far_clip)
// 	set_shader_param(shader.camera_position, camera.position)
// 	set_shader_param(shader.camera_direction, camera.direction)
// 	set_shader_param(shader.camera_up_direction, camera.up_direction)
// 	set_shader_param(shader.camera_side_direction, camera.side_direction)
// 	set_shader_param(shader.camera_focal_length, camera.focal_length)
// 	set_shader_param(shader.camera_sensor_size, camera.sensor_size)
// 	set_shader_param(shader.sun_dir, linalg.normalize([3]f32{3,-2,3}))
// 	set_shader_param(shader.camera_zoom, camera.zoom)
// 	set_shader_param(shader.haze_color, draw.haze_color) }


// // TODO: Are these parameters ever used? //
// render_water_effect :: proc(draw: ^Draw, camera: ^Camera, net_time: f32, frame: u8 = 0, zoom: f32 = 1.0, high_contrast: bool = false) {
// 	shader := use_shader(draw.water_effect_shader)
// 	bufs: [5]u32 = { gl.COLOR_ATTACHMENT0, gl.COLOR_ATTACHMENT1, gl.COLOR_ATTACHMENT2, gl.COLOR_ATTACHMENT3, gl.COLOR_ATTACHMENT4 }
// 	gl.DrawBuffers(5, &bufs[0])
// 	// EFFECT PARAMS //
// 	set_effect_shader_params(draw,camera, net_time, shader)
// 	set_shader_param(shader.zoom, zoom)
// 	set_shader_param(shader.high_contrast, cast(i32)high_contrast)
// 	// set_shader_param(shader.surfer_position,surfer_position)
// 	// set_shader_param(shader.surf_position,surf_position)
// 	// set_shader_param(shader.surf_direction,surf_direction)
// 	// set_shader_param(shader.surf_up_direction,surf_up_direction)
// 	// set_shader_param(shader.surf_side_direction,surf_side_direction)
// 	// set_shader_param(shader.hovered_index,i32(hovered_index))
// 	// set_shader_param(shader.swimming,i32(swimming))
// 	// set_shader_param(shader.paddling,i32(surfer_state==.PADDLING))
// 	// set_shader_param(shader.surfing,i32(surfer_state==.STANDING))
// 	// bind_texture(0,textures_map["dev-grid"].handle)
// 	// bind_texture(1,textures_map["dev-grid"].handle)
// 	// bind_texture(2,textures_map["dev-grid"].handle)
// 	// bind_texture(3,textures_map["dev-grid"].handle)
// 	// bind_texture(4,textures_map["dev-grid"].handle)
// 	bind_texture(0, draw.textures_map["sky-back"].handle)
// 	bind_texture(1, draw.textures_map["sky-front"].handle)
// 	bind_texture(2, draw.textures_map["sky-left"].handle)
// 	bind_texture(3, draw.textures_map["sky-right"].handle)
// 	bind_texture(4, draw.textures_map["sky-up"].handle)
// 	bind_texture(5, draw.textures_map["skybox"].handle)
// 	bind_texture(6, draw.textures_map["dev-grid"].handle)
// 	bind_texture(7, draw.textures_map["dev-oriented-grid"].handle)
// 	bind_texture(8, draw.default_sb.texture_handles[0])
// 	draw_triangles(6) }


// render_sdf_surface :: proc(draw: ^Draw, camera: ^Camera, net_time: f32, surface: SDF_Surface, color: [3]f32) {
// 	shader := use_shader(draw.sdf_shader)
// 	set_effect_shader_params(draw, camera, net_time, shader)
// 	set_shader_param(shader.surface_color, color)
// 	switch variant in surface {
// 	case SDF_Plane:
// 		plane := variant
// 		set_shader_param(shader.offset, plane.c)
// 		set_shader_param(shader.normal, plane.n)
// 		set_shader_param(shader.height, plane.h)
// 		set_shader_param(shader.sdf_id, cast(i32)SDF_ID.PLANE)
// 	case SDF_Sphere:
// 		sphere := variant
// 		set_shader_param(shader.offset, sphere.c)
// 		set_shader_param(shader.radius, sphere.r)
// 		set_shader_param(shader.sdf_id, cast(i32)SDF_ID.SPHERE)
// 	case SDF_Capsule_Z:
// 		capsule := variant
// 		set_shader_param(shader.offset, capsule.c)
// 		set_shader_param(shader.radius, capsule.r)
// 		set_shader_param(shader.height, capsule.l)
// 		set_shader_param(shader.sdf_id, cast(i32)SDF_ID.CAPSULE_Z)
// 	case SDF_Triangle:
// 		ground_triangle := variant
// 		set_shader_param(shader.point_a, ground_triangle.a)
// 		set_shader_param(shader.point_b, ground_triangle.b)
// 		set_shader_param(shader.point_c, ground_triangle.c)
// 		set_shader_param(shader.sdf_id, cast(i32)SDF_ID.GROUND_TRIANGLE)
// 	case SDF_Triangle_Mesh:
// 		ground := variant
// 		panic("SDF_Triangle_Mesh renderer unimplemented.")
// 	case SDF_Plane_Mesh:
// 		mesh := variant
// 		panic("SDF_Plane_Mesh renderer unimplemented.") }
// 	draw_triangles(6) }


// render_physics :: proc(draw: ^Draw, physics: ^Physics) {
// 	shader := use_shader(draw.physics_shader)
// 	N :: 5
// 	bufs: [N]u32 = { gl.COLOR_ATTACHMENT0, gl.COLOR_ATTACHMENT1, gl.COLOR_ATTACHMENT2, gl.COLOR_ATTACHMENT3, gl.COLOR_ATTACHMENT4 }
// 	#assert(N == len(Physics_Buffer_Channel))
// 	gl.DrawBuffers(N, &bufs[0])
// 	// TODO Do I need res? //
// 	set_shader_param(shader.surfer_position, physics.surfer_position)
// 	set_shader_param(shader.surf_position, physics.surf_position)
// 	draw_triangles(6) }


// DICK
// get_hovered_id :: proc(graphics_manager: ^Graphics_Manager, mouse_pos: [2]f32) -> u32 {
// 	result: u8
// 	pos:    [2]f32

// 	select_render_buffer(graphics_manager, &graphics_manager.canvas_rb)
// 	gl.ReadBuffer(gl.COLOR_ATTACHMENT2) // (NOTE): This is bad. //
// 	pos = linalg.array_cast(draw.resolution, f32) / 2 + input.cursor
// 	gl.ReadPixels(
// 		x = cast(i32)pos.x,
// 		y = cast(i32)pos.y,
//  		width = 1,
//  		height = 1,
//  		format = gl.RED,
//  		type = gl.UNSIGNED_BYTE,
//  		pixels = &result)
// 	ui.hovered_index = cast(int)result
// 	return cast(int)result }


// read_pixel_rgba :: proc(draw: ^Draw, pos: [2]int) -> (pixel: [4]f32) {
// 	pixel_bytes: [4]u8

// 	gl.ReadBuffer(gl.COLOR_ATTACHMENT0)
// 	gl.ReadPixels(
// 		x = cast(i32)pos.x,
// 		y = cast(i32)pos.y,
//  		width = 1,
//  		height = 1,
//  		format = gl.RGBA,
//  		type = gl.UNSIGNED_BYTE,
//  		pixels = &pixel_bytes)
// 	return { u8_normalize(pixel_bytes.x), u8_normalize(pixel_bytes.y), u8_normalize(pixel_bytes.z), u8_normalize(pixel_bytes.w) } }


// read_pixels_rgba :: proc(draw: ^Draw, pos: [2]int) -> (pixels: [][4]f32) {
// 	n :          int
// 	pixel_bytes: [][4]u8

// 	n = cast(int)draw.window_size.x * cast(int)draw.window_size.y
// 	pixel_bytes = make([][4]u8, n)
// 	gl.ReadBuffer(gl.COLOR_ATTACHMENT0)
// 	gl.ReadPixels(
// 		x = cast(i32)pos.x,
// 		y = cast(i32)pos.y,
//  		width = cast(i32)draw.window_size.x,
//  		height = cast(i32)draw.window_size.y,
//  		format = gl.RGBA,
//  		type = gl.UNSIGNED_BYTE,
//  		pixels = &pixel_bytes)
//  	pixels = make([][4]f32, n)
//  	for pixel_byte, i in pixel_bytes do pixels[i] = rgba_normalize(pixel_byte)
// 	return pixels }


// init_shader_from_memory :: proc(name: string, $Type: typeid, vert_source: string, frag_source: string) -> ^Type {
// 	shader:  ^Type
// 	err:     runtime.Allocator_Error
// 	ok:      bool
// 	err_loc: runtime.Source_Code_Location

// 	shader = new(Type)
// 	shader.name = strings.clone(name)
// 	shader.vert_source, shader.frag_source = vert_source, frag_source
// 	_, err = append(&shaders,&shader.shader)
// 	if err != .None { return nil }
// 	ok, err_loc = compile_shader(shader)
// 	if ! ok { return nil }
// 	init_shader_params(Type, shader)
// 	return shader }


// recompile_shader :: proc(draw: ^Draw, working_directory_path: string, shader: ^Shader, allocator: runtime.Allocator = context.allocator) {
// 	fmt.println("Recompiling shaders")
// 	new_shader: Shader
// 	ok:         bool

// 	new_shader = shader^
// 	ok, _ = compile_shader(draw, working_directory_path, &new_shader, allocator = allocator)
// 	if ok {
// 		gl.DeleteProgram(cast(u32)shader.handle)
// 		shader ^= new_shader } }

// compile_shaders :: proc(draw: ^Draw, working_directory_path: string) {
// 	ok:  bool
// 	loc: runtime.Source_Code_Location

// 	for _, i in draw.shaders {
// 		if draw.shaders[i].compiled { continue }
// 		ok, loc = compile_shader(draw, working_directory_path, draw.shaders[i])
// 		assert(ok)
// 		draw.shaders[i].compiled = true } }


// recompile_shaders :: proc(draw: ^Draw, working_directory_path: string, names: []string = {}) {
// 	if len(names) == 0 {
// 		for _, i in draw.shaders {
// 			recompile_shader(draw, working_directory_path, draw.shaders[i]) } }
// 	else {
// 		for name in names {
// 			for _, i in draw.shaders {
// 				if draw.shaders[i].name == name {
// 					recompile_shader(draw, working_directory_path, draw.shaders[i]) } } } } }

Polygon_Mode :: enum {
	Point = gl.POINT,
	Line = gl.LINE,
	Fill = gl.FILL }

polygon_mode :: proc(mode: Polygon_Mode) {
	gl.PolygonMode(gl.FRONT_AND_BACK, cast(u32)mode) }

// (TODO): Use this on the function below:
Texture_Filtering :: enum {
	Linear = gl.LINEAR,
	Nearest = gl.NEAREST }

texture_filtering :: proc(mode: i32) {
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, mode)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, mode) }

texture_wrapping :: proc(mode: i32) {
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, mode)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, mode) }


// resolution_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
// // NOTE: Resizing the window manually is not allowed. You can only do it through settings.
// 	// resolution = [2]f32{ cast(f32)width, cast(f32)height }
// }


// render_symbol :: proc(draw: ^Draw, font: ^Font, symbol: rune, pos: [2]f32, depth: f32, color: [4]f32 = WHITE) {
// 	texture: ^Texture
// 	shader:  ^Font_Shader

// 	texture = draw.textures_map[font.name]
// 	shader = use_shader(draw.font_shader)
// 	set_shader_param(shader.symbol, cast(i32)symbol)
// 	set_shader_param(shader.pos, [3]f32{ pos.x, pos.y, depth })
// 	bind_texture(0, texture.handle)
// 	draw_triangles(6) }


// get_render_buffer_image :: proc(rb: ^Render_Buffer, rb_data: ^Render_Buffer_Data) {
// 	for i in 0 ..< len(rb.texture_handles) {
// 		gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 		gl.GetTexImage(gl.TEXTURE_2D, 0, rb.texture_formats[i], gl.UNSIGNED_BYTE, cast(rawptr)&rb_data.buffers[i][0]) }
// 	rb_data.size = rb.size }


// set_render_buffer_image :: proc(rb: ^Render_Buffer, rb_data: ^Render_Buffer_Data) {
// 	for i in 0 ..< len(rb.texture_handles) {
// 		gl.BindTexture(gl.TEXTURE_2D, cast(u32)rb.texture_handles[i])
// 		gl.TexImage2D(gl.TEXTURE_2D, 0, rb.texture_internal_formats[i], cast(i32)rb.size.x, cast(i32)rb.size.y, 0, rb.texture_formats[i], gl.UNSIGNED_BYTE, cast(rawptr)&rb_data.buffers[i][0]) }
// 	rb.size = rb_data.size }

// internal_format_size :: proc(internal_format: i32) -> (size: int) {
// 	switch internal_format {
// 	case gl.RED, gl.R8, gl.R8_SNORM: return 1
// 	case gl.RG, gl.R16, gl.R16_SNORM, gl.RG8, gl.RG8_SNORM: return 2
// 	case gl.RGB, gl.RGB8, gl.RGB8_SNORM: return 3
// 	case gl.RGBA, gl.R32F, gl.R32I, gl.R32UI, gl.RGBA8, gl.RGBA8_SNORM: return 4
// 	case: return -1 } }


error_callback :: proc "c" (source: u32, type: u32, id: u32, severity: u32, length: i32, message: cstring, userParam: rawptr) {
	if severity == gl.DEBUG_SEVERITY_NOTIFICATION do return
	context = runtime.default_context()
	log.error("OpenGL error:", source, type, id, severity, length, message) }


// render_text :: proc(draw: ^Draw, args: ..any, sep: string = "", pos: [2]f32 = { 0, 0 }, color: [4]f32 = WHITE, pivot: bit_set[Compass] = {}, font: ^Font = nil, shadow: bool = false, spacing: f32 = 1.0) {
// 	text:    string
// 	texture: ^Texture
// 	width:   f32
// 	height:  f32
// 	shader:  ^Font_Shader
// 	sym_pos: [2]f32

// 	pos := pos
// 	font := font
// 	text = fmt.aprint(..args, sep = sep)
// 	font = (font == nil) ? draw.fonts_map["font"] : font
// 	if font == nil do return
// 	texture = draw.textures_map[font.name]
// 	if texture == nil do return
// 	width = cast(f32)len(text) * (cast(f32)font.symbol_size.x) * spacing
// 	height = cast(f32)font.symbol_size.y
// 	pos = pos - 0.5 * { width, height } + 0.5 * font.symbol_size
// 	if .EAST in pivot do pos.x -= 0.5 * width
// 	if .WEST in pivot do pos.x += 0.5 * width
// 	if .NORTH in pivot do pos.y -= 0.5 * height
// 	if .SOUTH in pivot do pos.y += 0.5 * height
// 	shader = use_shader(draw.font_shader)
// 	set_shader_param(shader.this_buffer_res, linalg.array_cast(draw.resolution, f32))
// 	set_shader_param(shader.symbol_size, font.symbol_size)
// 	sym_pos = pos
// 	for c, i in text {
// 		bind_texture(0, texture.handle)
// 		texture_filtering(gl.NEAREST)
// 		set_shader_param(shader.symbol, cast(i32)c)
// 		if shadow {
// 			set_shader_param(shader.text_color, [4]f32{ 0, 0, 0, color.w })
// 			set_shader_param(shader.pos, [3]f32{ sym_pos.x + 1, sym_pos.y - 1, 0.5 })
// 			draw_triangles(6) }
// 		set_shader_param(shader.text_color, color)
// 		set_shader_param(shader.pos, [3]f32{ sym_pos.x, sym_pos.y, 0.5 })
// 		draw_triangles(6)
// 		texture_filtering(gl.NEAREST)
// 		draw_triangles(6)
// 		sym_pos.x += spacing * cast(f32)font.symbol_size.x } }


// render_cursor :: proc(draw: ^Draw, pos: [2]f32) {
// 	render_line(draw, pos + { -8, 0 }, pos + { 8, 0 }, WHITE, thickness = 4.0)
// 	render_line(draw, pos + { 0, -8 }, pos + { 0, 8 }, WHITE, thickness = 4.0) }


// glfw_error_callback :: proc "c" (error: i32, description: cstring) {
// 	context = runtime.default_context()
// 	print_bad("glfw error", error, description) }

// draw_destroy :: proc(draw: ^Draw) {
// 	glfw.DestroyWindow(draw.window)
// 	glfw.Terminate() }


// // cap_fps::proc() {
// // 	// TODO: Implement proper FPS capping with input gathering at a higher tick-rate. This techniques is insane.
// // 	desired_time:time.Time=time.from_nanoseconds(PERIOD_240FPS_NSEC)
// // 	elapsed_time:time.Time=time.from_nanoseconds(i64(time.stopwatch_duration(frame_timer)))
// // 	time.accurate_sleep(time.diff(elapsed_time,desired_time)) }


// render_cover :: proc(draw: ^Draw, net_time: f32) {
// 	t:    f32
// 	i:    int
// 	name: string

// 	COVER_RATIO :: 440.0 / 568.0
// 	N_FRAMES :: 16
// 	SPEED :: 10.0
// 	t = linalg.fract(net_time/f32(N_FRAMES)*SPEED)
// 	i = min(int(t*16),15)
// 	name = fmt.tprintf("cover_%4d",i)
// 	render_texture(draw, name = name, pos = { 0, 0 }, size_override = { COVER_RATIO * 180, 180 }) }

// load_font :: proc(draw: ^Draw, working_directory_path: string, path: string) -> (ptr: ^Font) {
// 	font: Font
// 	texture: ^Texture

// 	texture = new_generic_texture(draw, path)
// 	init_texture_from_data(draw, texture, filepath.join({ working_directory_path, IMAGES_PATH_RELATIVE }), texture.name)
// 	load_texture(draw, texture)
// 	font.name = strings.clone(name_from_path(path))
// 	font.symbol_size = { cast(f32)(texture.width / 16), cast(f32)(texture.height / 16) }
// 	append(&draw.fonts,font)
// 	ptr = &draw.fonts[len(draw.fonts) - 1]
// 	draw.fonts_map[font.name] = ptr
// 	return ptr }

@(deferred_in=tick_end)
tick :: proc(graphics_manager: ^Graphics_Manager) {
	tick_begin(graphics_manager) }

// // TODO: Make sure that whenever this job is created, these filters are applied. //
// // TODO: Create "Draw_Tick_Args" cast to "rawptr" as argument instead of array of "any"s.
// Draw_Tick_Data :: struct {
// 	draw:                   ^Locked_Struct(Draw),
// 	camera:                 ^Locked_Struct(Camera),
// 	physics:                ^Locked_Struct(Physics),
// 	clock:                  ^Locked_Struct(Clock),
// 	sync:                   ^Locked_Struct(Sync),
// 	input:                  ^Locked_Struct(Input),
// 	working_directory_path: string }
// draw_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag = "job")
tick_begin :: proc(graphics_manager: ^Graphics_Manager) {
// 	render_cubemap(draw, &draw.cubemap, camera.position)
	glfw.PollEvents()
	clear_frame_buffer(0)
	graphics_manager.time = read_stopwatch(&graphics_manager.stopwatch)
	select_render_buffer(graphics_manager, &graphics_manager.canvas_rb)
	clear_render_buffer(&graphics_manager.canvas_rb)
	set_depth_test(true) }

tick_end :: proc(graphics_man: ^Graphics_Manager) {
	command_buffer_submit(graphics_man, &graphics_man.command_buffer)
	set_depth_test(false)
	select_frame_buffer(graphics_man, 0)
	if graphics_man.buffer_shader.handle != 0 do render_render_buffer(graphics_man, &graphics_man.canvas_rb, 0)

// 	if .MODELS in draw.draw_mask do render_all_model_instances(draw, camera)
// 	if .EFFECTS in draw.draw_mask {
// 		// TODO: Separate skybox renderer from water effect renderer.
// 		// TEMP
// 		// set_depth_test(false)
// 		render_water_effect(draw, camera, clock.net_time)
// 		// c:[3]f32=physics.surfer_position
// 		// render_sdf_surface(draw, camera, clock.net_time, SDF_Sphere{ c=c,r=0.2 },color=physics.collision_distance>0?{0,0,1}:{1,0,1})
// 		// for surface in physics.collision_surfaces do render_sdf_surface(draw, camera, clock.net_time, surface,color={1,0,0})
// 		// render_sdf_surface(draw, camera, clock.net_time, SDF_Triangle{ a={8,0,0}, b={0,8,2}, c={0,0,4} },color={0,1,0})
// 	}
// 	set_depth_test(false)
// 	// render_cover()
// 	// if ui.screen==.TITLE do render_cover()
// 	// select_render_buffer(&draw.physics_rb)
// 	// render_physics()
// 	@(static) n: int = 0; n += 1
// 	render_chromatic_aberration(draw, draw.default_sb.texture_handles[0])
// 	flare_pos = { 0, 0.1, 0 }
// 	// @(static) flare_pos: [3]f32
// 	// if n == 1 do flare_pos = camera_inverse_project(camera, { 0, 0 })
// 	flare_pos = apply_transform(flare_pos, camera.local_matrix)
// 	flare_pos.xy = flare_pos.xy * linalg.array_cast(draw.window_size, f32) / 2
// 	if flare_pos.z >= 0 do render_line(draw, flare_pos.xy - { 4, 0 }, flare_pos.xy + { 4, 0 }, RED, false, 4)
// 	// render_rect(draw, flare_pos, { 32, 32 }, RED)
// 	// if draw.frame_count == 0 do find_glare_spots(draw)

// 	set_depth_test(false)
// 	set_blend(true)
// 	select_frame_buffer(draw, 0)
// 	render_buffer_texture(draw, &draw.default_sb, COLOR_CHANNEL)

// 	// render_panel(draw.default_sb,pos={-200,40},size={16 * 16, 16 * 8})
// 	pos = { -(cast(f32)draw.window_size.x) / 2, (cast(f32)draw.window_size.y) / 2 - 8 }
// 	render_text(draw, physics.collision_distance, pos = pos, pivot = { .WEST }); pos.y -= 16
// 	render_text(draw, physics.collision_normal, pos = pos, pivot = { .WEST }); pos.y -= 16
// 	// render_text("POSITION:",pos=pos,pivot={.WEST}); pos.y-=16
// 	// render_text(camera.position.x,pos=pos,pivot={.WEST},color=RED); pos.y-=16
// 	// render_text(camera.position.y,pos=pos,pivot={.WEST},color=GREEN); pos.y-=16
// 	// render_text(camera.position.z,pos=pos,pivot={.WEST},color={0,0.5,1,1}); pos.y-=32
// 	render_text(draw, "FORWARD:", pos = pos, pivot = { .WEST }); pos.y -= 16
// 	render_text(draw, camera.direction.x, pos = pos, pivot = { .WEST }, color = RED); pos.y -= 16
// 	render_text(draw, camera.direction.y, pos = pos, pivot = { .WEST }, color = GREEN); pos.y -= 16
// 	render_text(draw, camera.direction.z, pos = pos, pivot = { .WEST }, color = { 0, 0.5, 1, 1 }); pos.y -= 32

// 	set_blend(false)
// 	render_cubemap_preview(draw, &draw.cubemap, { - auto_cast draw.window_size.x / 2 + 400, + auto_cast draw.window_size.y / 2 - 300 }, { 800, 600 })

// 	// render_text("SIDEWARD:",pos=pos,pivot={.WEST}); pos.y-=16
// 	// render_text(camera.side_direction.x,pos=pos,pivot={.WEST},color=RED); pos.y-=16
// 	// render_text(camera.side_direction.y,pos=pos,pivot={.WEST},color=GREEN); pos.y-=16
// 	// render_text(camera.side_direction.z,pos=pos,pivot={.WEST},color={0,0.5,1,1}); pos.y-=32
// 	// render_text("UPWARD:",pos=pos,pivot={.WEST}); pos.y-=16
// 	// render_text(camera.up_direction.x,pos=pos,pivot={.WEST},color=RED); pos.y-=16
// 	// render_text(camera.up_direction.y,pos=pos,pivot={.WEST},color=GREEN); pos.y-=16
// 	// render_text(camera.up_direction.z,pos=pos,pivot={.WEST},color={0,0.5,1,1})

// 	// render_plots()
// 	// crosshair_pos:[2]f32=cursor+{bumps(),0}
// 	// render_rect_hollow(pos={0,0},size={100,100},color=RED,dashed=true,animate=false,thickness=2)
// 	// render_crosshair(crosshair_pos)
// 	// set_blend(true)
// 	// render_prompts()
// 	// set_blend(false)
// 	// get_hovered_index()
// 	// cap_fps()
	glfw.SwapBuffers(cast(glfw.WindowHandle)graphics_man.window_manager.handle)
	if glfw.WindowShouldClose(cast(glfw.WindowHandle)graphics_man.window_manager.handle) do graphics_man.window_closed = true

// 	// TODO: Add a draw_util_tick, where non-draw graphics procedures are executed on the OpenGL thread. //
// 	watch_models(draw, "beach")
// 	{ lock_guard(&physics.lock); physics.d_surf, physics.d_surf_displaced, physics.d_surfer, physics.n_surf, physics.n_surf_displaced = read_physics_render_buffer(draw) }
// 	{ lock_guard(&input.lock); if key_was_pressed(input, .J) do recompile_shaders(unwrap(draw), working_directory_path) }
	graphics_man.frame_count += 1 }
	// DICK


// render_prompts :: proc(draw: ^Draw, prompts: bit_set[Prompts], net_time: f32) {
// 	res: [2]int
// 	dx: f32

// 	res = draw.default_sb.size
// 	dx = 0
// 	if .START in prompts {
// 		render_text(
// 			draw,
// 			"Press ENTER to staruntime.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*net_time)+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .EXIT in prompts {
// 		render_text(
// 			draw,
// 			"Press ESC to exit.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*net_time)+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .RESPAWN in prompts {
// 		render_text(
// 			draw,
// 			"Press R to respawn.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*net_time)+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .SWIM_FORWARD in prompts {
// 		render_text(
// 			draw,
// 			"Hold W to swim forward.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*(net_time-1))+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .GET_ON_THE_SURF in prompts {
// 		render_text(
// 			draw,
// 			"Press E to get on the surf.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*(net_time-2))+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .PADDLE in prompts {
// 		render_text(
// 			draw,
// 			"Press E to paddle.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*(net_time-2))+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 }
// 	if .STAND_UP in prompts {
// 		render_text(
// 			draw,
// 			"Press E to stand up.",
// 			pos={-f32(res.x)/2+8,-f32(res.y)/2+8+math.pow((math.sin(4*(net_time-2))+1)/2,16)*4+dx},
// 			color={0,0,0,1}, pivot={.WEST,.SOUTH}, font=nil, shadow=false, spacing=0.5)
// 		dx+=24 } }


// normal_space_to_rect_space :: proc(point: [2]f32, rect: Rect) -> [2]f32 {
// 	return (rect.pos - rect.size / 2) + point * rect.size
// 	// return {
// 	// 	(rect.pos.x - rect.size.x / 2) + point.x * rect.size.x,
// 	// 	(rect.pos.y - rect.size.y / 2) + point.y * rect.size.y }
// 	}


// texture_space_to_normal_space :: proc(pixel_index: [2]int, texture_size: [2]int) -> (normal: [2]f32) {
// 	pixel_size: [2]f32

// 	pixel_size = [2]f32{ 1.0, 1.0 } / linalg.array_cast(texture_size, f32)
// 	normal = pixel_size / 2 + pixel_size * linalg.array_cast(pixel_index, f32)
// 	return { normal.x, 1 - normal.y } }


// pixel_contains_point :: proc(pixel: [2]int, point: [2]f32, texture_size: [2]int) -> bool {
// 	pixel_rect: Rect

// 	pixel_rect.size = [2]f32{ 1.0, 1.0 } / linalg.array_cast(texture_size, f32)
// 	pixel_rect.pos = linalg.array_cast(pixel, f32) * pixel_rect.size + pixel_rect.size / 2
// 	return rect_contains_point(pixel_rect, point) }


// find_glare_spots :: proc(draw: ^Draw) {
// 	THRESHOLD :: 0.95
// 	brightness :: proc(color: [3]f32) -> f32 { return (color.r + color.g + color.b) / 3 }
// 	delete(draw.glare_spots)
// 	draw.glare_spots = make_dynamic_array_len_cap([dynamic][2]int, 0, 64)
// 	for i in 0 ..< cast(int)draw.window_size.x do for j in 0 ..< cast(int)draw.window_size.y {
// 		pixel := read_pixel_rgba(draw, [2]int{ cast(int)draw.window_size.x, cast(int)draw.window_size.y } / 2).rgb
// 		br := brightness(pixel)
// 		if br > THRESHOLD do append_elem(&draw.glare_spots, [2]int{ i, j } - linalg.array_cast(draw.window_size, int) / 2) } }
