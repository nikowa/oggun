layout(location = 0) in vec3 position;
layout(location = 1) in vec2 texcoord;
layout(location = 2) in vec3 normal;
layout(location = 3) in vec3 lightmap_texcoord;
layout(location = 0) uniform mat4 model_matrix;
layout(location = 1) uniform mat4 camera_position_matrix;
layout(location = 2) uniform mat4 camera_projection_matrix;
out vec3 position_interpolated;
out vec3 scr_position_interpolated;
out vec3 scr_normal_interpolated;
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
	// scr_normal_interpolated = normalize((inverse(position_matrix) * vec4(normal, 1)).xyz - (inverse(position_matrix) * vec4(0, 0, 0, 1)).xyz);
	scr_normal_interpolated = normalize(transpose(inverse(mat3x3(camera_position_matrix))) * normal);
	// gl_Position = vec4(position, 1);
	scr_position_interpolated = gl_Position.xyz; }
