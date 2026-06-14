layout(location = 0) in vec2 center;
layout(location = 1) in float radius;
layout(location = 2) in vec2 angle_range;
layout(location = 3) in vec4 line_color;
layout(location = 4) in float depth;
layout(location = 5) in vec4 clip;
layout(location = 6) in float clip_radius;
layout(location = 0) uniform vec2 res;

#include <mesh>

flat out vec4 _line_color;
flat out float _depth;
flat out vec4 _clip;
flat out float _clip_radius;
flat out vec2 _center;
flat out float _radius;
flat out vec2 _angle_range;

void main(void) {
	_line_color = line_color;
	_depth = depth;
	_clip = clip;
	_clip_radius = clip_radius;
	_center = center;
	_radius = radius;
	_angle_range = angle_range;
	gl_Position.zw = vec2(0, 1);
	gl_Position.xy = mh_rect(gl_VertexID % 6, center / res, vec2(2 * radius) / res); }
