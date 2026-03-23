void main(void) {
	_color = effect_color(uv_interpolated);
	gl_FragDepth = length(scr_position_interpolated) / camera_far_clip; }