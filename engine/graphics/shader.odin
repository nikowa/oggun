#+feature using-stmt
package graphics
import "base:runtime"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:bytes"
import "core:container/intrusive/list"
import "core:container/queue"
import "core:fmt"
import "core:image"
import "core:image/qoi"
import "core:os"
import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "core:mem"
import "core:path/filepath"
import "core:reflect"
import "core:slice"
import "core:strings"
import "core:strconv"
import "core:thread"
import "core:time"


Shader :: struct {
	name:                    string,
	handle:                  u32,
	vert_name,frag_name:     string,
	vert_source,frag_source: string,
	last_compile_time:       time.Time,
	compiled:                bool }


Font_Shader :: struct {
	using shader:    Shader,
	symbol:          i32,
	pos:             i32,
	this_buffer_res: i32,
	symbol_size:     i32,
	text_color:      i32 }


Rect_Shader :: struct {
	using shader: Shader,
	pos:          i32,
	size:         i32,
	fill_color:   i32,
	res:          i32,
	rounding:     i32 }


Panel_Shader :: struct {
	using shader: Shader,
	pos:          i32,
	res:          i32,
	size:         i32 }


Model_Shader :: struct {
	using shader:             Shader,
	model_matrix:             i32,
	camera_position_matrix:   i32,
	camera_projection_matrix: i32,
	camera_far_clip:          i32,
	camera_position:          i32,
	haze_color:               i32,
	metallic_factor:          i32,
	roughness_factor:         i32 }


Point_Shader :: struct {
	using shader:    Shader,
	pos:             i32,
	size:            i32,
	fill_color:      i32,
	this_buffer_res: i32 }


Line_Shader :: struct {
	using shader:    Shader,
	line:            i32,
	this_buffer_res: i32,
	line_color:      i32,
	dashed:          i32,
	animate:         i32,
	time:            i32,
	mask:            i32 }


Texture_Shader :: struct {
	using shader: Shader,
	pos:          i32,
	size:         i32,
	res:          i32 }


Chromatic_Aberration_Shader :: struct {
	using shader: Shader }


Buffer_Shader :: struct {
	using shader: Shader }


Upscale_Pass1_Shader :: struct {
	using shader: Shader,
	resolution:   i32,
	window_size:  i32 }


Upscale_Pass2_Shader :: struct {
	using shader: Shader,
	window_size:  i32 }


Blend_Shader :: struct {
	using shader: Shader }


Curvature_Shader :: struct {
	using shader: Shader,
	time:         i32,
	image_res:    i32 }


Physics_Shader :: struct {
	using shader:        Shader,
	time:                i32,
	surf_position:       i32,
	surf_direction:      i32,
	surf_up_direction:   i32,
	surf_side_direction: i32,
	surfer_position:     i32 }


SDF_Shader :: struct {
	using _:       Effect_Shader,
	surface_color: i32,
	offset:        i32,
	normal:        i32,
	height:        i32,
	radius:        i32,
	point_a:       i32,
	point_b:       i32,
	point_c:       i32,
	sdf_id:        i32 }


Effect_Shader :: struct {
	using shader:          Shader,
	time:                  i32,
	res:                   i32,
	camera_far_clip:       i32,
	camera_position:       i32,
	camera_direction:      i32,
	camera_up_direction:   i32,
	camera_side_direction: i32,
	camera_focal_length:   i32,
	camera_sensor_size:    i32,
	sun_dir:               i32,
	camera_zoom:           i32,
	haze_color:            i32 }


Water_Effect_Shader :: struct {
	using _:             Effect_Shader,
	sun_p:               i32,
	sun_n:               i32,
	zoom:                i32,
	hovered_index:       i32,
	high_contrast:       i32,
	surf_position:       i32,
	surf_direction:      i32,
	surf_up_direction:   i32,
	surf_side_direction: i32,
	surfer_position:     i32,
	swimming:            i32,
	paddling:            i32,
	surfing:             i32 }


GLSL_Builder :: struct {
	string_builder:    strings.Builder,
	includes:          [dynamic]string,
	uniform_variables: [dynamic][2]string,
	macros:            [dynamic]string,
	global_variables:  [dynamic][2]string }

