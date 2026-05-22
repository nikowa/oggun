
const vec2 MSAA8_OFF[8] = {
	vec2(0.9,0.5),
	vec2(-0.5,0.9),
	vec2(-0.9,-0.5),
	vec2(0.5,-0.9),
	vec2(-0.45,0.25),
	vec2(0.25,0.45),
	vec2(0.45,-0.25),
	vec2(-0.25,-0.45) };

const vec2 MSAA16_OFF[16] = {
	vec2(0.9,0.36),
	vec2(0.36,0.9),
	vec2(-0.36,0.9),
	vec2(-0.9,0.36),
	vec2(-0.9,-0.36),
	vec2(-0.36,-0.9),
	vec2(0.36,-0.9),
	vec2(0.9,-0.36),
	vec2(1,1),
	vec2(-1,-1),
	vec2(1,-1),
	vec2(-1,1),
	vec2(0.3,0.3),
	vec2(-0.3,-0.3),
	vec2(0.3,-0.3),
	vec2(-0.3,0.3) };

#define msaa8_scope_begin(msaa8_acc, msaa8_res) \
	vec2 msaa8_pixel_size = vec2(1) / (msaa8_res);\
	for (int msaa8_i = 0; msaa8_i < 8; msaa8_i += 1) {\
		vec2 msaa_off = msaa8_pixel_size * (MSAA8_OFF[msaa8_i] - vec2(0.5));
#define msaa8_scope_end(msaa8_acc) } \
	msaa8_acc /= float(8);

#define msaa16_scope_begin(msaa16_acc, msaa16_res) \
	vec2 msaa16_pixel_size = vec2(1) / (msaa16_res);\
	for (int msaa16_i = 0; msaa16_i < 16; msaa16_i += 1) {\
		vec2 msaa_off = msaa16_pixel_size * (MSAA16_OFF[msaa16_i] - vec2(0.5));
#define msaa16_scope_end(msaa16_acc) } \
	msaa16_acc /= float(16);
