layout(location = 0) in vec2 point_a;
layout(location = 1) in vec2 point_b;
layout(location = 2) in vec4 line_color;
layout(location = 3) in float depth;
layout(location = 4) in vec4 clip;
layout(location = 5) in float clip_radius;
layout(location = 0) uniform vec2 res;

flat out vec4 _line_color;
flat out float _depth;
flat out vec4 _clip;
flat out float _clip_radius;

void main(void) {
	_line_color = line_color;
	_depth = depth;
	_clip = clip;
	_clip_radius = clip_radius;

	vec2 half_res = res / 2;
	vec2 a = vec2(
		2 * (point_a.x + half_res.x) / res.x - 1,
		2 * (point_a.y + half_res.y) / res.y - 1);
	vec2 b = vec2(
		2 * (point_b.x + half_res.x) / res.x - 1,
		2 * (point_b.y + half_res.y) / res.y - 1);
	if(gl_VertexID % 2 == 0) gl_Position = vec4(a, 0, 1);
	else gl_Position = vec4(b, 0, 1); }
