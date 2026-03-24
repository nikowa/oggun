void main(void) {
	vec4 position = vec4(effect_position(), 1);
	_uv_interpolated = _vert;
	gl_Position = (camera_projection_matrix * camera_position_matrix * node_matrix) * position;
	_scr_position_interpolated = gl_Position.xyz;
	_position_interpolated = position.xyz;
	_surface_index_flat = _surface_index; }