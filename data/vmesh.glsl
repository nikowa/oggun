layout(location = 0) in vec3 position;
uniform mat4 node_matrix;
uniform mat4 camera_position_matrix;
uniform mat4 camera_projection_matrix;
out vec3 scr_position_interpolated;

void main(void) {
	mat4 position_matrix = camera_position_matrix * node_matrix;
	gl_Position = (camera_projection_matrix * position_matrix) * vec4(position, 1);
	scr_position_interpolated = gl_Position.xyz; }
