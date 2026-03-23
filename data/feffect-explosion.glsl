#include <feffect>
vec4 effect_color(vec2 uv) {
	vec3 red = vec3(214.0 / 255, 40.0 / 255, 40.0 / 255);
	vec3 yellow = vec3(252.0 / 255, 191.0 / 255, 73.0 / 255);
	vec3 color = mix(red, yellow, uv.x);
	return vec4(color, 1); }
#include <feffect-main>