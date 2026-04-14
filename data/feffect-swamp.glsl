#include <feffect>
vec4 effect_color() {
	vec3 green = vec3(
		43.0 / 255,
		90.0 / 255,
		87.0 / 255);
	vec3 color = green;
	float alpha = 1.0;
	return vec4(color, alpha); }
#include <feffect-main>