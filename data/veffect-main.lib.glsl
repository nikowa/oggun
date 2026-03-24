void main(void) {
	vec4 position = vec4(effect_position(vert), 1);
	uv_interpolated = vert;
	gl_Position = (camera_projection_matrix * camera_position_matrix * node_matrix) * position;
	scr_position_interpolated = gl_Position.xyz;
	position_interpolated = position.xyz; }