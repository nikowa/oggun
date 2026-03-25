#include <veffect>
#define PI 3.14159265359
vec3 effect_position() {
	vec3 pos;
	if (surface_index == 0) {
		pos.z = 2 * uv.y - 1;
		pos.x = cos(2 * PI * uv.x);
		pos.y = sin(2 * PI * uv.x);
		pos.xy *= cos(asin(pos.z));
		pos *= 0.5;
		pos *= 1.0 + 0.2 * sin(4 * time); }
	else {
		pos.x = 2 * (uv.x - 0.5);
		pos.y = 2 * (uv.y - 0.5);
		pos.z = -0.3 + 32.0 * (pow(pos.x / 10, 2.0) + pow(pos.y / 10, 2.0)) + 0.2 * (sin(4 * time + 32 * uv.x) + sin(3 * time + 32 * uv.y)); }
	pos = clamp(pos, vec3(-1), vec3(1));
	return pos; }
#include <veffect-main>