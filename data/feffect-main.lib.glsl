void main(void) {
	_color = effect_color();
	gl_FragDepth = length(_scr_position_interpolated) / camera_far_clip; }