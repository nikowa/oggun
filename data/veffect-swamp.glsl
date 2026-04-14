#include <veffect>
#define PI 3.14159265359
// (TODO):
// vec3 effect_position(in vec2 uv, out vec3 position, out vec3 normal) {
vec3 effect_position(vec2 uv) {
	vec3 position;
	position.x = 8 * (uv.x - 0.5);
	position.y = 8 * (uv.y - 0.5);
	position.z = 0;
	return position; }
#include <veffect-main>