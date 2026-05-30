
bool clip_in_range(float x, float lo, float hi) {
	return (x >= lo) && (x <= hi); }

bool clip_point(vec2 point, vec4 clip_rect) {
	return clip_in_range(point.x, clip_rect.x - clip_rect.z / 2, clip_rect.x + clip_rect.z / 2) &&
		   clip_in_range(point.y, clip_rect.y - clip_rect.w / 2, clip_rect.y + clip_rect.w / 2); }

vec4 clip_color(vec4 color, vec2 point, vec4 clip_rect) {
	if (clip_point(point, clip_rect)) return color;
	return vec4(0); }
