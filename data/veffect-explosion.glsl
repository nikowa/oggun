#include <veffect>
vec3 effect_position(vec2 uv) {
	vec3 pos;
	pos.x = 32 * (uv.x - 0.5);
	pos.y = 32 * (uv.y - 0.5);
	pos.z = 4 * (pow(pos.x / 10, 2.0) + pow(pos.y / 10, 2.0)) + 2.0 * (sin(4 * time + 32 * uv.x) + sin(3 * time + 32 * uv.y));
	return pos; }
#include <veffect-main>