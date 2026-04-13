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
		color = mix(orange, purple, clamp(0.5 * (position.z + 1.0), 0, 1)); }
	float alpha = 1.0;
	// color.xyz = normal;
	// color.xyz = 0.5 * (normal + vec3(1.0));
	vec3 incident_ray = position - camera_position;
	alpha = 1.0 - clamp(abs(0.35 * dot(incident_ray, normal)), 0.0, 1.0);
	alpha = pow(alpha + 0.2, 2.0);
	alpha = 1.0;
	return vec4(color, alpha); }
#include <feffect-main>