void main(void) {
	_color = effect_color();
	_id = id;
	// _color.xyz = vec3(id) / 4.0;
	gl_FragDepth = length(_scr_position_interpolated) / camera_far_clip; }