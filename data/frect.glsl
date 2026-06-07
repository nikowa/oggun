// precision highp float;

out vec4 color;
layout(location = 0) uniform vec2 res;
layout(pixel_center_integer) in vec4 gl_FragCoord;
// in vec4 gl_FragCoord;
in vec2 tex_coord;
flat in vec4 _rect;
flat in float _depth;
flat in vec4 _fill_color;
flat in float _rounding;
flat in float _stroke;
flat in vec4 _stroke_color;
flat in vec4 _clip;
flat in float _clip_radius;

#include <sdf>
#include <msaa>
#include <clip>

#define rounding _rounding
#define rect _rect
#define fill_color _fill_color
#define stroke _stroke
#define stroke_color _stroke_color
#define clip _clip
#define clip_radius _clip_radius

vec3 sample_rgb(vec2 off) {
	vec3 acc = vec3(0);
	vec2 p = get_p(res) + off;
	float dist = sdf_rounded_rect(p - vec2(rect.x, -rect.y), rect.zw / 2, vec4(rounding));
	acc = fill_color.xyz;
	if (stroke != 0) if ((dist > - stroke) && (dist < 0)) {
		acc = stroke_color.xyz;
	}
	return acc; }

float sample_a(vec2 off) {
	float acc = 0;
	vec2 p = get_p(res) + off;
	float dist = sdf_rounded_rect(p - vec2(rect.x, -rect.y), rect.zw / 2, vec4(rounding));
	if (dist < 0.5) return 1;
	return 0; }

void main(void) {
	color = vec4(0);
	gl_FragDepth = _depth;
	vec2 b = rect.zw / 2 - vec2(rounding);
	vec3 _color;
	msaa16_scope_begin(color, vec2(1))
		color.rgb += sample_rgb(msaa_off);
		color.a += clip_value_rounded(sample_a(msaa_off), gl_FragCoord.xy - res / 2 + msaa_off, clip, clip_radius);
	msaa16_scope_end(color)
}
