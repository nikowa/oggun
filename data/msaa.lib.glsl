
const vec2 MSAA2_OFF[2] = {
	vec2(0.45,0.45),
	vec2(-0.45,-0.45) };

const vec2 MSAA4_OFF[4] = {
	vec2(0.45,0.25),
	vec2(-0.25,0.45),
	vec2(-0.45,-0.25),
	vec2(0.25,-0.45) };

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

#define msaa2_scope_begin(msaa2_acc, msaa2_res) \
	vec2 msaa2_pixel_size = vec2(1) / (msaa2_res);\
	for (int msaa2_i = 0; msaa2_i < 2; msaa2_i += 1) {\
		vec2 msaa_off = msaa2_pixel_size * (MSAA2_OFF[msaa2_i] - vec2(0.5));
#define msaa2_scope_end(msaa2_acc) } \
	msaa2_acc /= float(2);

#define msaa4_scope_begin(msaa4_acc, msaa4_res) \
	vec2 msaa4_pixel_size = vec2(1) / (msaa4_res);\
	for (int msaa4_i = 0; msaa4_i < 4; msaa4_i += 1) {\
		vec2 msaa_off = msaa4_pixel_size * (MSAA4_OFF[msaa4_i] - vec2(0.5));
#define msaa4_scope_end(msaa4_acc) } \
	msaa4_acc /= float(4);

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
