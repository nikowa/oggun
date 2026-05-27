#+feature using-stmt
package willow
import "core:log"
import "base:runtime"
import gl "vendor:OpenGL"
import "core:fmt"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:time"
import "core:io"

GLSL_VERSION_STRING: string : "#version 460 core"

Shader_Config :: struct #all_or_none {
	vert_url, frag_url: URL }
	// definitions: []Definition }

DEFAULT_SHADER_CONFIG: Shader_Config : {
	vert_url = DEFAULT_URL,
	frag_url = DEFAULT_URL }

Definition :: struct {
	identifier: string,
	replacement: string }

Shader_Asset :: struct {
	using asset: Asset,
	using shader_config: Shader_Config,
	vert_asset, frag_asset: String_Asset,
	handle: u32,
	last_modification_time: time.Time,
	compiled: bool }

// Font_Shader :: struct {
// 	using shader:    Shader,
// 	symbol:          i32,
// 	position:        i32,
// 	this_buffer_res: i32,
// 	symbol_size:     i32,
// 	text_color:      i32 }

Rect_Shader_Uniforms :: enum {
	RES        = 0,
	DEPTH      = 1,
	FILL_COLOR = 2,
	ROUNDING   = 3 }

Line_Shader_Uniforms :: enum {
	RES = 0 }

Model_Shader_Uniforms :: enum {
	MODEL_MATRIX             = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	CAMERA_POSITION          = 3,
	CAMERA_FAR_CLIP          = 4,
	HAZE_COLOR               = 5,
	METALLIC_FACTOR          = 6,
	ROUGHNESS_FACTOR         = 7 }

Effect_Shader_Uniforms :: enum {
	NODE_MATRIX              = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	TIME                     = 3,
	CAMERA_FAR_CLIP          = 4,
	CAMERA_POSITION          = 5,
	ID                       = 6 }

Mesh_Shader_Uniforms :: enum {
	NODE_MATRIX              = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	CAMERA_FAR_CLIP          = 3 }

Buffer_Shader_Uniforms :: enum {
	RES = 0 }

// Panel_Shader :: struct {
// 	using shader: Shader,
// 	position:     i32,
// 	res:          i32,
// 	size:         i32 }

// Point_Shader :: struct {
// 	using shader:    Shader,
// 	position:        i32,
// 	size:            i32,
// 	fill_color:      i32,
// 	this_buffer_res: i32 }

Image_Shader_Uniforms :: enum {
	RES = 0 }

Text_Uniforms :: enum {
	RES = 0,
	SYMBOL_SIZE = 1,
	TIME = 2 }

// Chromatic_Aberration_Shader :: struct {
// 	using shader: Shader }


// Buffer_Shader :: struct {
// 	using shader: Shader }


// Upscale_Pass1_Shader :: struct {
// 	using shader: Shader,
// 	resolution:   i32,
// 	window_size:  i32 }


// Upscale_Pass2_Shader :: struct {
// 	using shader: Shader,
// 	window_size:  i32 }


// Blend_Shader :: struct {
// 	using shader: Shader }


// Curvature_Shader :: struct {
// 	using shader: Shader,
// 	time:         i32,
// 	image_res:    i32 }


// Physics_Shader :: struct {
// 	using shader:        Shader,
// 	time:                i32,
// 	surf_position:       i32,
// 	surf_direction:      i32,
// 	surf_up_direction:   i32,
// 	surf_side_direction: i32,
// 	surfer_position:     i32 }


// SDF_Shader :: struct {
// 	using _:       Effect_Shader,
// 	surface_color: i32,
// 	offset:        i32,
// 	normal:        i32,
// 	height:        i32,
// 	radius:        i32,
// 	point_a:       i32,
// 	point_b:       i32,
// 	point_c:       i32,
// 	sdf_id:        i32 }


// Effect_Shader :: struct {
// 	using shader:          Shader,
// 	time:                  i32,
// 	res:                   i32,
// 	camera_far_clip:       i32,
// 	camera_position:       i32,
// 	camera_direction:      i32,
// 	camera_up_direction:   i32,
// 	camera_side_direction: i32,
// 	camera_focal_length:   i32,
// 	camera_sensor_size:    i32,
// 	sun_dir:               i32,
// 	camera_zoom:           i32,
// 	haze_color:            i32 }


// Water_Effect_Shader :: struct {
// 	using _:             Effect_Shader,
// 	sun_p:               i32,
// 	sun_n:               i32,
// 	zoom:                i32,
// 	hovered_index:       i32,
// 	high_contrast:       i32,
// 	surf_position:       i32,
// 	surf_direction:      i32,
// 	surf_up_direction:   i32,
// 	surf_side_direction: i32,
// 	surfer_position:     i32,
// 	swimming:            i32,
// 	paddling:            i32,
// 	surfing:             i32 }


GLSL_Builder :: struct {
	string_builder: strings.Builder,
	includes: [dynamic]string,
	uniform_variables: [dynamic][2]string,
	macros: [dynamic]string,
	global_variables: [dynamic][2]string }

init_shader_asset :: proc(shader: ^Shader_Asset, asset_config: Asset_Config, config: Shader_Config) -> (err: os.Error) {
	init_asset(Shader_Asset, &shader.asset, asset_config)
	defer if err != nil do log.errorf("Failed to make shader %s, %s: %v", config.vert_url, config.frag_url, err)
	shader.shader_config = config
	init_string_asset(&shader.vert_asset, { config.vert_url, String_Asset })
	init_string_asset(&shader.frag_asset, { config.frag_url, String_Asset })
	append(&engine.graphics_manager.shaders, shader) or_return
	assert(asset_commands(Shader_Asset, shader, { .Import, .Load }))
	return os.General_Error.None }

// Shader :: struct {
// 	using config: Shader_Config,
// 	handle: u32,
// 	last_compile_time: time.Time,
// 	compiled: bool }

// watch_shaders :: proc() {
// 		append(&graphics_context.shaders, &shader.shader) or_return
// 	compile_shader(graphics_context, database, shader) or_return

// }

compile_shader :: proc(shader_asset: ^Shader_Asset, allocator := context.allocator) -> (err: os.Error) {
	vert_path, frag_path: string
	entry: ^Entry
	ok: bool
	path: string
	source: string
	compile_message: string
	compile_message_type: gl.Shader_Type
	link_message: string
	link_message_type: gl.Shader_Type
	bytes: []u8
	builder: GLSL_Builder
	working_directory_path: string
	loc: runtime.Source_Code_Location
	handle: u32

	working_directory_path, _ = os.get_working_directory(allocator = allocator)
	sources: [2]string = { shader_asset.vert_asset.str, shader_asset.frag_asset.str }
	// log.infof("Vertex source:\n%s\n", sources[0])
	// log.infof("Fragment source:\n%s\n", sources[1])
	for source, i in sources {
		init_glsl_builder(&builder) or_return
		fmt.sbprintln(&builder.string_builder, GLSL_VERSION_STRING)
		loc = preprocess_glsl(working_directory_path, &builder, sources[i]) or_return
		sources[i] = strings.clone(glsl_builder_to_string(&builder))
		destroy_glsl_builder(&builder) }
	handle, ok = gl.load_shaders_source(sources[0], sources[1])
	if ok do shader_asset.handle = handle
	compile_message, compile_message_type, link_message, link_message_type = gl.get_last_error_messages()
	if (compile_message_type != .NONE) && (len(compile_message) > 0) do print_glsl_error(compile_message, compile_message_type, shader_asset, sources[0], sources[1])
	if len(link_message) > 0 do print_glsl_error(link_message, compile_message_type, shader_asset, sources[0], sources[1])
	if ! ok do return io.Error.No_Progress
	shader_asset.last_modification_time = time_max(get_entry(shader_asset.vert_asset.url).modification_time, get_entry(shader_asset.frag_asset.url).modification_time)
	return os.General_Error.None }


print_glsl_error :: proc(message: string, message_type: gl.Shader_Type, shader: ^Shader_Asset, vert_string: string, frag_string: string) {
	content: string
	bl:      int
	br:      int
	line_n:  int
	line:    string

	#partial switch message_type {
	case gl.Shader_Type.VERTEX_SHADER: content=vert_string
	case gl.Shader_Type.FRAGMENT_SHADER: content=frag_string
	case: log.error("Shader compilation error:", shader.url, ": ", message_type, ": ", message, ": ?", sep = "") }
	bl = strings.index_rune(message, '(')
	br = strings.index_rune(message, ')')
	line_n = strconv.parse_int(message[bl + 1 : br]) or_else -1
	line = nth_line(content, line_n - 1)
	log.error("Shader linking error:", message_type, "/", shader.url, "(", line_n, ")", ": ", ":\n", message, ": \n", line, sep = "") }

init_glsl_builder :: proc(glsl_builder: ^GLSL_Builder) -> (res: ^strings.Builder, err: runtime.Allocator_Error) {
	res, err = strings.builder_init(&glsl_builder.string_builder)
	glsl_builder.uniform_variables = make([dynamic][2]string, 0, 64)
	glsl_builder.macros = make([dynamic]string, 0, 64)
	glsl_builder.global_variables = make([dynamic][2]string, 0, 64)
	return res, err }

destroy_glsl_builder :: proc(glsl_builder: ^GLSL_Builder) {
	strings.builder_destroy(&glsl_builder.string_builder)
	delete(glsl_builder.uniform_variables) }

glsl_builder_to_string :: proc(glsl_builder: ^GLSL_Builder) -> string {
	return strings.to_string(glsl_builder.string_builder) }

preprocess_glsl :: proc(working_directory_path: string, builder: ^GLSL_Builder, source: string) -> (loc: runtime.Source_Code_Location, err: os.Error) {
	lines:         []string
	line:          string
	fields:        []string
	open:          u8
	close:         u8
	incl_source:   string
	found:         bool
	lib_path:      string
	param:         string
	defined:       bool
	previous_type: string
	type:          string
	name:          string

	@(static)data_types: []string = {
		"bool",
		"int",
		"uint",
		"float",
		"double",
		"ivec2",
		"ivec3",
		"ivec4",
		"uvec2",
		"uvec3",
		"uvec4",
		"vec2",
		"vec3",
		"vec4",
		"dvec2",
		"dvec3",
		"dvec4",
		"mat2",
		"mat3",
		"mat4",
		"mat2x3",
		"mat2x4",
		"mat3x2",
		"mat3x4",
		"mat4x2",
		"mat4x3",
		"mat4x4" }
	append(&builder.includes, source)
	lines = strings.split_lines(source)
	for line in lines {
		line := line
		if strings.starts_with(line,"    ") || strings.starts_with(line,"\t") {
			fmt.sbprintln(&builder.string_builder, line)
			continue }
		line = strings.trim_left_space(line)
		if strings.starts_with(line,"//") do continue
		if strings.starts_with(line,"#include") {
			fields = strings.fields(line); assert(len(fields) == 2)
			open = fields[1][0]
			close = fields[1][len(fields[1]) - 1]
			if ((open == '\"') && (close == '\"')) || ((open == '<') && (close == '>')) {
				relpath: string
				relpath, err = os.join_filename(fields[1][1:len(fields[1]) - 1], "lib.glsl", context.temp_allocator)
				path := relpath_to_source_path(relpath, context.temp_allocator)
				// log.infof("Including shader library \"%s\".", path)
				bytes: []u8
				bytes, err = os.read_entire_file_from_path(path, context.allocator)
				if err != nil {
					log.errorf("Shader library \"%s\" not found.", path)
					return }
				incl_source = cast(string)bytes }
			else {
				return #location(), os.General_Error.None }
			if slice.contains(builder.includes[:], incl_source) {
				continue }
			preprocess_glsl(working_directory_path, builder, incl_source) or_return }
		else if strings.starts_with(line, "uniform") {
			already_defined :: proc(builder: ^GLSL_Builder, type: string, name: string) -> (yes: bool, previous_type: string) {
				for i in 0 ..< len(builder.uniform_variables) {
					if builder.uniform_variables[i][1] == name {
						return true, builder.uniform_variables[i][0] } }
				return false, "" }
			fields = strings.fields(line); assert(len(fields) >= 2)
			assert((len(fields) == 3) || ((len(fields) > 4) && fields[3] == "="))
			defined, previous_type = already_defined(builder, fields[1], fields[2])
			if defined {
				assert(previous_type == fields[1]) }
			else {
				fmt.sbprintln(&builder.string_builder, line)
				append(&builder.uniform_variables, [2]string{ strings.clone(fields[1]), strings.clone(fields[2]) }) } }
		else if starts_with_any(line, data_types) {
			already_defined :: proc(builder: ^GLSL_Builder, type: string, name: string) -> (yes: bool, previous_type: string) {
				for i in 0 ..< len(builder.global_variables) {
					if builder.global_variables[i][1] == name {
						return true, builder.global_variables[i][0] } }
				return false, "" }
			fields = strings.fields(line); assert(len(fields) >= 2)
			if strings.contains_rune(fields[1], '(') {
				fmt.sbprintln(&builder.string_builder, line)
				continue }
			type = fields[0]
			name = fields[1]
			defined, previous_type = already_defined(builder, fields[0], fields[1])
			if defined {
				assert(previous_type == fields[0]) }
			else {
				fmt.sbprintln(&builder.string_builder, line)
				append(&builder.global_variables, [2]string{ strings.clone(fields[0]), strings.clone(fields[1]) }) } }
		else do fmt.sbprintln(&builder.string_builder, line) }
	return {}, os.General_Error.None }

shader_outdated :: proc(shader_asset: ^Shader_Asset) -> (outdated: bool) {
	outdated = true
	vert_entry := get_entry(shader_asset.vert_asset.url)
	frag_entry := get_entry(shader_asset.frag_asset.url)
	latest_modification_time: time.Time = time_max(vert_entry.modification_time, frag_entry.modification_time)
	return time.diff(shader_asset.last_modification_time, latest_modification_time) > 0 }

shader_asset_command :: proc(asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	shader_asset := asset_object(asset, Shader_Asset, "asset")
	switch command {
	case .Validate:
		return true
	case .Query_Location:
		assert(asset_command(String_Asset, &shader_asset.vert_asset, .Query_Location))
		assert(asset_command(String_Asset, &shader_asset.frag_asset, .Query_Location))
		assert(.Source_Directory in shader_asset.vert_asset.location)
		assert(.Source_Directory in shader_asset.frag_asset.location)
	case .Import:
		// TEMP
		// context.allocator = engine.backing_allocator
		if watch {
			if ! shader_outdated(shader_asset) do return
			// If one of the strings' modification times are newer than the shader's modification time, update the shader with
			// the new strings.
		}
		assert(asset_command(String_Asset, &shader_asset.vert_asset, .Import))
		assert(asset_command(String_Asset, &shader_asset.frag_asset, .Import))
		asset.location += { .Database }
		return true
	case .Load:
		// TEMP
		// context.allocator = engine.backing_allocator
		assert(asset_command(String_Asset, &shader_asset.vert_asset, .Load))
		assert(asset_command(String_Asset, &shader_asset.frag_asset, .Load))
		err := compile_shader(shader_asset)
		return err == nil
	case .Export, .Save, .Upload, .Download:
		if ! watch do log.errorf("Command %v not implemented for \"Shader_Asset\".", command)
		return false }
	return false }
