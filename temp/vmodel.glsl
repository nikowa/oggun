#version 460 core
layout(location=0) in vec3 position;
layout(location=1) in vec2 texcoord;
layout(location=2) in vec3 normal;
layout(location=3) in vec3 lightmap_texcoord;
uniform mat4 model_matrix;
uniform mat4 camera_position_matrix;
uniform mat4 camera_projection_matrix;
out vec3 position_interpolated;
out vec3 scr_position_interpolated;
out vec2 texcoord_interpolated;
out vec3 normal_interpolated;
out vec2 lightmap_texcoord_interpolated;


void main(void) {
	mat4 position_matrix = camera_position_matrix * model_matrix;
	position_interpolated = (model_matrix * vec4(position, 1)).xyz;
	normal_interpolated = normalize((model_matrix * vec4(normal, 1)).xyz - (model_matrix * vec4(0, 0, 0, 1)).xyz);
	// (TODO): Why are we inverting the Y-value?
	texcoord_interpolated = vec2(texcoord.x, 1 - texcoord.y);
	lightmap_texcoord_interpolated = vec2(lightmap_texcoord.x, 1 - lightmap_texcoord.y);
	gl_Position = (camera_projection_matrix * position_matrix) * vec4(position, 1);
	scr_position_interpolated = gl_Position.xyz; }


