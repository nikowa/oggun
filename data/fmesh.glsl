layout(location = 3) uniform float camera_far_clip;
out vec4 color;
in vec3 scr_position_interpolated;
void main(void) {
	color = vec4(1.0);
	// color.w = 0.25;
	// color.w = 0.5;
	color.w = 0.05;
	// color.xyz = vec3(0.5) + 1.0 * scr_position_interpolated;
	gl_FragDepth = length(scr_position_interpolated) / camera_far_clip; }
