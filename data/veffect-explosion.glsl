#include <veffect>
#define PI 3.14159265359
// (TODO):
// vec3 effect_position(in vec2 uv, out vec3 position, out vec3 normal) {
vec3 effect_position(vec2 uv) {
	vec3 position;
	if (surface_index == 0) {
		position.z = 2 * uv.y - 1;
		position.x = cos(2 * PI * uv.x);
		position.y = sin(2 * PI * uv.x);
		position.xy *= cos(asin(position.z));
		position.xyz *= 0.5;
		position *= 1.0 + 0.2 * sin(4 * time); }
	else {
		position.x = 2 * (uv.x - 0.5);
		position.y = 2 * (uv.y - 0.5);
		position.z = -1.0 + 64.0 * (pow(position.x / 10, 2.0) + pow(position.y / 10, 2.0)) + 0.2 * (sin(4 * time + 32 * uv.x) + sin(3 * time + 32 * uv.y));
		position.xyz *= 0.5;
		position.xyz = vec3(0); }
	position = clamp(position, vec3(-1), vec3(1));
	// if (gl_VertexID <= 66) {
	// 	position.z += sin(4 * time);
	// }
	return position; }
#include <veffect-main>