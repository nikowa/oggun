#include <sdf>

bool clip_in_range(float x, float lo, float hi) {
	return (x >= lo) && (x <= hi); }

bool clip_point(vec2 point, vec4 clip_rect) {
	return clip_in_range(point.x, clip_rect.x - clip_rect.z / 2, clip_rect.x + clip_rect.z / 2) &&
		   clip_in_range(point.y, clip_rect.y - clip_rect.w / 2, clip_rect.y + clip_rect.w / 2); }

bool clip_point_rounded(vec2 point, vec4 clip_rect, float clip_radius) {
	// vec2 p = get_p(res) + off;
	float dist = sdf_rounded_rect(point - vec2(clip_rect.x, clip_rect.y), clip_rect.zw / 2, vec4(clip_radius));
	// float dist = sdf_rounded_rect(point - vec2(clip_rect.x, clip_rect.y), clip_rect.zw / 2, vec4(0));
	return dist <= 0; }

vec4 clip_color(vec4 color, vec2 point, vec4 clip_rect) {
	if (clip_point(point, clip_rect)) return color;
	return vec4(0); }

vec4 clip_color_rounded(vec4 color, vec2 point, vec4 clip_rect, float clip_radius) {
	// float dist = sdf_rounded_rect(point - vec2(clip_rect.x, clip_rect.y), clip_rect.zw / 2, vec4(0));
	// return vec4(vec3(dist) / 1000, 1);
	if (clip_point_rounded(point, clip_rect, clip_radius)) return color;
	return vec4(0); }

float clip_value_rounded(float value, vec2 point, vec4 clip_rect, float clip_radius) {
	if (clip_point_rounded(point, clip_rect, clip_radius)) return value;
	return 0; }
