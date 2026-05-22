
// const vec2 MSAA8_OFF[8] = {
// 	vec2(0.279, 0.719),
// 	vec2(0.552, 0.107),
// 	vec2(0.499, 0.266),
// 	vec2(0.361, 0.881),
// 	vec2(0.579, 0.743),
// 	vec2(0.735, 0.995),
// 	vec2(0.002, 0.516),
// 	vec2(0.617, 0.177) };

const vec2 MSAA8_OFF[8] = {
	vec2(0.9,0.5),
	vec2(-0.5,0.9),
	vec2(-0.9,-0.5),
	vec2(0.5,-0.9),
	vec2(-0.45,0.25),
	vec2(0.25,0.45),
	vec2(0.45,-0.25),
	vec2(-0.25,-0.45) };

#define msaa8_scope_begin(msaa8_acc, msaa8_res) \
	vec2 msaa8_pixel_size = vec2(1) / (msaa8_res);\
	for (int msaa8_i = 0; msaa8_i < 8; msaa8_i += 1) {\
		vec2 msaa8_off = msaa8_pixel_size * (MSAA8_OFF[msaa8_i] - vec2(0.5));
#define msaa8_scope_end(msaa8_acc) } \
	msaa8_acc /= float(8);
