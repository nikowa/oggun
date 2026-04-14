void main(void) {
	_color = effect_color();
	_id = id;
	float depth = -_scr_position_interpolated.z;
	// depth = 0.5;
	gl_FragDepth = gl_FragCoord.z;
	// _color.xyz = vec3(id) / 4.0;
	// gl_FragDepth = length(_scr_position_interpolated) / camera_far_clip;
	// _color.xyz = vec3(depth);
	// _color.xyz = _scr_position_interpolated;
}
