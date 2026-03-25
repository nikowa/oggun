#include <feffect>
vec4 effect_color() {
	vec3 yellow = vec3(255.0 / 255, 190.0 / 255, 11.0 / 255);
	vec3 orange = vec3(251.0 / 255, 86.0 / 255, 7.0 / 255);
	vec3 purple = vec3(131.0 / 255, 56.0 / 255, 236.0 / 255);
	vec3 blue = vec3(58.0 / 255, 134.0 / 255, 255.0 / 255);
	vec3 color;
	if (surface_index == 0) {
		color = mix(yellow, orange, clamp(0.5 * (position.z + 1.0), 0, 1)); }
	else {
		color = mix(blue, purple, clamp(0.5 * (position.z + 1.0), 0, 1)); }
	// vec3 color = mix(red, yellow, float(surface_index));
	// vec3 color = mix(vec3(1, 0, 0), vec3(0, 1, 0), float(surface_index));
	// float alpha = length(uv);
	float alpha = 1.0;
	return vec4(color, alpha); }
#include <feffect-main>