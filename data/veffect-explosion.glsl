#include <veffect>
vec3 effect_position(vec2 uv) {
	vec3 pos;
	pos.x = 50 * (uv.x - 0.5);
	pos.y = 50 * (uv.y - 0.5);
	pos.z = pow(pos.x / 10, 2.0) + pow(pos.y / 10, 2.0);
	return pos; }
#include <veffect-main>