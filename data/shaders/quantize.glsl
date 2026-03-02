vec3 quantize(vec3 c) {
	vec2 uv;
	uv=fract(tex_coord*(main_buffer_res/threshold_res));
	float threshold=texture(samp_threshold,uv).x;
	uv=fract(tex_coord*(main_buffer_res/blue_noise_res));
	float blue_noise=texture(samp_blue_noise,uv).x;
	if(length(c)<length(vec3(threshold))) {
		return vec3(0); }
	else {
		return vec3(1); } }
