out vec4 color;
layout(location = 0) uniform vec2 res;
in vec4 gl_FragCoord;

flat in vec4 _line_color;
flat in float _depth;
flat in vec4 _clip;
flat in float _clip_radius;
flat in vec2 _point_a;
flat in vec2 _point_b;

#include <clip>
#include <sdf>
#include <msaa>

#define line_color _line_color
#define depth _depth
#define clip _clip
#define clip_radius _clip_radius

const float thickness = 1;

vec2 point_a = vec2(_point_a.x, -_point_a.y);
vec2 point_b = vec2(_point_b.x, -_point_b.y);

float sample_alpha(vec2 off) {
	vec2 p = get_p(res) + off;
	float dist = sdf_segment(p, point_a, point_b);
	return (dist >= thickness / 2) ? 0 : 1; }

void main(void) {
	color = line_color;
	color.a = 0;
	msaa16_scope_begin(color.a, vec2(1.0))
		color.a += sample_alpha(msaa_off);
	msaa16_scope_end(color.a)
	color.a = 1 - pow(1 - color.a, 2);
	gl_FragDepth = depth;
	if (color.a == 0) gl_FragDepth = 1;
	color.a *= line_color.a;
	color = clip_color_rounded(color, gl_FragCoord.xy - res / 2, clip, clip_radius); }
