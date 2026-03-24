#include <feffect>
vec4 effect_color() {
	vec3 red = vec3(214.0 / 255, 40.0 / 255, 40.0 / 255);
	vec3 yellow = vec3(252.0 / 255, 191.0 / 255, 73.0 / 255);
	// vec3 color = mix(red, yellow, clamp(0.5 * (position.z + 1.0), 0, 1));
	// vec3 color = mix(red, yellow, float(surface_index));
	vec3 color = mix(vec3(1, 0, 0), vec3(0, 1, 0), float(surface_index));
	float alpha = length(uv);
	return vec4(color, alpha); }
#include <feffect-main>