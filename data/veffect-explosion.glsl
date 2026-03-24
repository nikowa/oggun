#include <veffect>
vec3 effect_position(vec2 uv) {
	vec3 pos;
	pos.x = 2 * (uv.x - 0.5);
	pos.y = 2 * (uv.y - 0.5);
	pos.z = -0.3 + 32.0 * (pow(pos.x / 10, 2.0) + pow(pos.y / 10, 2.0)) + 0.2 * (sin(4 * time + 32 * uv.x) + sin(3 * time + 32 * uv.y));
	pos = clamp(pos, vec3(-1), vec3(1));
	return pos; }
#include <veffect-main>