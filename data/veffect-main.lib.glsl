const float EPSILON = 0.0001;
void main(void) {
	vec2 uv = _vert;
	vec4 position = vec4(effect_position(_vert), 1.0);
	_uv_interpolated = _vert;
	gl_Position = (camera_projection_matrix * camera_position_matrix * node_matrix) * position;
	_normal_interpolated = normalize(cross(
		normalize(effect_position(vec2(_vert.x + EPSILON, _vert.y + EPSILON)) - effect_position(vec2(_vert.x - EPSILON, _vert.y - EPSILON))),
		normalize(effect_position(vec2(_vert.x + EPSILON, _vert.y - EPSILON)) - effect_position(vec2(_vert.x - EPSILON, _vert.y + EPSILON)))));
	_scr_position_interpolated = gl_Position.xyz;
	_position_interpolated = position.xyz;
	_surface_index_flat = _surface_index; }