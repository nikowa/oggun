#+feature using-stmt
package graphics
import rt "base:runtime"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"
import b "core:bytes"
import l "core:container/intrusive/list"
import q "core:container/queue"
import fmt "core:fmt"
import img "core:image"
import qoi "core:image/qoi"
import os "core:os"
import m "core:math"
import la "core:math/linalg"
import rnd "core:math/rand"
import mem "core:mem"
import fp "core:path/filepath"
import rl "core:reflect"
import sl "core:slice"
import str "core:strings"
import sc "core:strconv"
import tr "core:thread"
import tm "core:time"
import io "core:io"
import db "../database"
import base "../base"



GLSL_VERSION_STRING:    string : "#version 460 core"



Shader_Config :: struct #all_or_none {
	name: string,
	vert_url, frag_url: string }


Shader :: struct {
	using config: Shader_Config,
	handle: u32,
	last_compile_time: tm.Time,
	compiled: bool }


// Font_Shader :: struct {
// 	using shader:    Shader,
// 	symbol:          i32,
// 	pos:             i32,
// 	this_buffer_res: i32,
// 	symbol_size:     i32,
// 	text_color:      i32 }


Rect_Shader :: struct {
	using shader: Shader,
	pos: i32,
	size: i32,
	fill_color: i32,
	res: i32,
	rounding: i32 }


// Panel_Shader :: struct {
// 	using shader: Shader,
// 	pos:          i32,
// 	res:          i32,
// 	size:         i32 }


// Model_Shader :: struct {
// 	using shader:             Shader,
// 	model_matrix:             i32,
// 	camera_position_matrix:   i32,
// 	camera_projection_matrix: i32,
// 	camera_far_clip:          i32,
// 	camera_position:          i32,
// 	haze_color:               i32,
// 	metallic_factor:          i32,
// 	roughness_factor:         i32 }


// Point_Shader :: struct {
// 	using shader:    Shader,
// 	pos:             i32,
// 	size:            i32,
// 	fill_color:      i32,
// 	this_buffer_res: i32 }


// Line_Shader :: struct {
// 	using shader:    Shader,
// 	line:            i32,
// 	this_buffer_res: i32,
// 	line_color:      i32,
// 	dashed:          i32,
// 	animate:         i32,
// 	time:            i32,
// 	mask:            i32 }


// Texture_Shader :: struct {
// 	using shader: Shader,
// 	pos:          i32,
// 	size:         i32,
// 	res:          i32 }


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
	string_builder:    str.Builder,
	includes:          [dynamic]string,
	uniform_variables: [dynamic][2]string,
	macros:            [dynamic]string,
	global_variables:  [dynamic][2]string }

make_shader :: make_shader_from_disk

make_shader_from_disk :: proc(graphics_context: ^Graphics_Context, database: ^db.Database, $Type: typeid, config: Shader_Config) -> (shader: ^Type, err: os.Error) {
	// 1. Is it in the database?
	// 2. If it is, load from database.
	// 3. If it isn't, create anew and add to database.

	shader = new(Type)
	shader.config = config
	append(&graphics_context.shaders, &shader.shader) or_return
	compile_shader(graphics_context, database, shader) or_return
	init_shader_params(Type, shader)
	return shader, nil }

compile_shader :: proc(graphics_context: ^Graphics_Context, database: ^db.Database, shader: ^Shader, allocator := context.allocator) -> (err: os.Error) {
	vert_path, frag_path: string
	modification_time: tm.Time
	entry: ^db.Entry
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
	// vert_source: string; frag_source: string;
	// extended_vert_name: string
	// extended_frag_name: string
	// path: string
	// file_handle: os.File
	loc: rt.Source_Code_Location
	// vert_string: string
	// temp_filepath: string
	// frag_string: string
	// handle: u32
	// success: bool

	// Entry :: struct {
	// 	url: string,
	// 	modification_time: t.Time,
	// 	compressed: b8,
	// 	data: []u8 }
	// vert_path = path_from_url(shader.vert_url, allocator)
	// frag_path = path_from_url(shader.frag_url, allocator)

	working_directory_path, _ = os.get_working_directory(allocator = allocator)
	urls: [2]string = { shader.vert_url, shader.frag_url }
	sources: [2]string = { "", "" }
	for url, i in urls {
		entry, ok = db.entry_from_url(database, urls[i])
		if db.entry_outdated(database, entry) {
			fmt.println(base.LOG, "Updating entry.")
			if ! ok do entry = db.add_entry(database, db.make_entry(urls[i], {}))
			path = db.path_from_url(database, urls[i], allocator)
			bytes, err = os.read_entire_file_from_path(path, context.allocator)
			sources[i] = cast(string)bytes
			init_glsl_builder(&builder) or_return
			fmt.sbprintln(&builder.string_builder, GLSL_VERSION_STRING)
			loc = preprocess_glsl(database, working_directory_path, &builder, sources[i]) or_return
			sources[i] = str.clone(glsl_builder_to_string(&builder))
			destroy_glsl_builder(&builder)
			modification_time = os.modification_time_by_path(path) or_return
			db.entry_update(entry, transmute([]u8)sources[i], modification_time) }
		else {
			fmt.println(base.LOG, "Reading shader source from database.")
			sources[i] = cast(string)entry.data } }
	fmt.println(base.LOG, "Sources:", sources[0], sources[1])
	shader.handle, ok = gl.load_shaders_source(sources[0], sources[1])
	compile_message, compile_message_type, link_message, link_message_type = gl.get_last_error_messages()
	if (compile_message_type != .NONE) && (len(compile_message) > 0) {
		print_glsl_error(compile_message, compile_message_type, shader, sources[0], sources[1]) }
	if len(link_message) > 0 {
		print_glsl_error(link_message, compile_message_type, shader, sources[0], sources[1]) }
	if ! ok do return io.Error.No_Progress
	return nil }

init_shader_params :: proc($Type: typeid, shader: ^Type) {
// 	fields: #soa[]reflect.Struct_Field

// 	fields = reflect.struct_fields_zipped(Type)
// 	for _, i in fields {
// 		if fields[i].name == "shader" do continue
// 		#partial switch v in fields[i].type.variant {
// 		case rt.Type_Info_Integer:
// 			(cast(^i32)(cast(uintptr)shader + fields[i].offset))^ = get_shader_param_handle(cast(u32)shader.handle, fields[i].name)
// 		case rt.Type_Info_Named:
// 			using_struct := v.base.variant.(rt.Type_Info_Struct)
// 			for j in 0 ..< using_struct.field_count {
// 				(cast(^i32)(cast(uintptr)shader + fields[i].offset + using_struct.offsets[j]))^ = get_shader_param_handle(cast(u32)shader.handle, using_struct.names[j]) }
// 		case: continue } }
}

print_glsl_error :: proc(message: string, message_type: gl.Shader_Type, shader: ^Shader, vert_string: string, frag_string: string) {
	content: string
	bl:      int
	br:      int
	line_n:  int
	line:    string

	#partial switch message_type {
	case gl.Shader_Type.VERTEX_SHADER: content=vert_string
	case gl.Shader_Type.FRAGMENT_SHADER: content=frag_string
	case: fmt.println(base.BAD, "Shader compilation error:", shader.name, ": ", message_type, ": ", message, ": ?", sep = "") }
	bl = str.index_rune(message, '(')
	br = str.index_rune(message, ')')
	line_n = sc.parse_int(message[bl + 1 : br]) or_else -1
	line = base.nth_line(content, line_n - 1)
	fmt.println(base.BAD, "Shader linking error:", message_type, "/", shader.name, "(", line_n, ")", ": ", ":\n", message, ": \n", line, sep = "") }

init_glsl_builder :: proc(glsl_builder: ^GLSL_Builder) -> (res: ^str.Builder, err: rt.Allocator_Error) {
	res, err = str.builder_init(&glsl_builder.string_builder)
	glsl_builder.uniform_variables = make([dynamic][2]string, 0, 64)
	glsl_builder.macros = make([dynamic]string, 0, 64)
	glsl_builder.global_variables = make([dynamic][2]string, 0, 64)
	return res, err }

destroy_glsl_builder :: proc(glsl_builder: ^GLSL_Builder) {
	str.builder_destroy(&glsl_builder.string_builder)
	delete(glsl_builder.uniform_variables) }

glsl_builder_to_string :: proc(glsl_builder: ^GLSL_Builder) -> string {
	return str.to_string(glsl_builder.string_builder) }

preprocess_glsl :: proc(database: ^db.Database, working_directory_path: string, builder: ^GLSL_Builder, source: string) -> (loc: rt.Source_Code_Location, err: os.Error) {
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
	lines = str.split_lines(source)
	for line in lines {
		line := line
		if str.starts_with(line,"    ") || str.starts_with(line,"\t") {
			fmt.sbprintln(&builder.string_builder, line)
			continue }
		line = str.trim_left_space(line)
		if str.starts_with(line,"//") do continue
		if str.starts_with(line,"#include") {
			fields = str.fields(line); assert(len(fields) == 2)
			open = fields[1][0]
			close = fields[1][len(fields[1]) - 1]
			if ((open == '\"') && (close == '\"')) || ((open == '<') && (close == '>')) {
				relpath: string = fields[1][1:len(fields[1]) - 1]
				path := db.relpath_to_source_path(database, relpath, context.temp_allocator)
				bytes: []u8
				bytes, err = os.read_entire_file_from_path(path, context.allocator)
				incl_source = cast(string)bytes }
			else {
				return #location(), os.General_Error.None }
			if sl.contains(builder.includes[:], incl_source) {
				continue }
			preprocess_glsl(database, working_directory_path, builder, incl_source) or_return }
		else if str.starts_with(line, "uniform") {
			already_defined :: proc(builder: ^GLSL_Builder, type: string, name: string) -> (yes: bool, previous_type: string) {
				for i in 0 ..< len(builder.uniform_variables) {
					if builder.uniform_variables[i][1] == name {
						return true, builder.uniform_variables[i][0] } }
				return false, "" }
			fields = str.fields(line); assert(len(fields) >= 2)
			assert((len(fields) == 3) || ((len(fields) > 4) && fields[3] == "="))
			defined, previous_type = already_defined(builder, fields[1], fields[2])
			if defined {
				assert(previous_type == fields[1]) }
			else {
				fmt.sbprintln(&builder.string_builder, line)
				append(&builder.uniform_variables, [2]string{ str.clone(fields[1]), str.clone(fields[2]) }) } }
		else if base.starts_with_any(line, data_types) {
			already_defined :: proc(builder: ^GLSL_Builder, type: string, name: string) -> (yes: bool, previous_type: string) {
				for i in 0 ..< len(builder.global_variables) {
					if builder.global_variables[i][1] == name {
						return true, builder.global_variables[i][0] } }
				return false, "" }
			fields = str.fields(line); assert(len(fields) >= 2)
			if str.contains_rune(fields[1], '(') {
				fmt.sbprintln(&builder.string_builder, line)
				continue }
			type = fields[0]
			name = fields[1]
			defined, previous_type = already_defined(builder, fields[0], fields[1])
			if defined {
				assert(previous_type == fields[0]) }
			else {
				fmt.sbprintln(&builder.string_builder, line)
				append(&builder.global_variables, [2]string{ str.clone(fields[0]), str.clone(fields[1]) }) } }
		else do fmt.sbprintln(&builder.string_builder, line) }
	return {}, os.General_Error.None }
