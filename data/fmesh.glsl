uniform float camera_far_clip;
out vec4 color;
in vec3 scr_position_interpolated;
void main(void) {
	color = vec4(1.0);
	gl_FragDepth = length(scr_position_interpolated) / camera_far_clip; }
