out vec4 color;
layout(location = 0) uniform vec2 res;
flat in vec4 _line_color;
flat in float _depth;
flat in vec4 _clip;
flat in float _clip_radius;
flat in vec2 _center;
flat in float _radius;
flat in vec2 _angle_range;

#include <sdf>
#include <msaa>
#include <clip>

#define line_color _line_color
#define depth _depth
#define clip _clip
#define clip_radius _clip_radius
#define center _center
#define radius _radius
#define angle_range _angle_range

const float thickness = 0.5;

vec2 rotate(vec2 vec, float angle) {
	return vec * mat2(cos(angle), - sin(angle), sin(angle), cos(angle)); }

float sample_alpha(vec2 off) {
	vec2 p = get_p(res) - vec2(center.x, -center.y) + off;
	vec2 range = angle_range;
	float angle = angle_range[1] - angle_range[0];
	p = rotate(p, -3.14159 / 2 + angle_range[0] + angle/2);
	angle *= 0.5;
	angle += 0.5 * 3.14159;
	float dist = sdf_arc(p, vec2(sin(angle), cos(angle)), radius + 0.0, 0.1);
	return (dist <= thickness / 2) ? 1 : 0; }

void main(void) {
	color = line_color;
	color.a = 0;
	msaa16_scope_begin(color.a, vec2(1))
		color.a += sample_alpha(msaa_off);
	msaa16_scope_end(color.a)
	color.a = 1 - pow(1 - color.a, 2);
	gl_FragDepth = depth;
	if (color.a == 0) gl_FragDepth = 1;
	color.a *= line_color.a;
}
