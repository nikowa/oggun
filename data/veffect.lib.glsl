layout(location = 0) in vec2 vert;
uniform mat4 node_matrix;
uniform mat4 camera_position_matrix;
uniform mat4 camera_projection_matrix;
uniform float time;
out vec2 uv_interpolated;
out vec3 scr_position_interpolated;