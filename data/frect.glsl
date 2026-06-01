// precision highp float;

out vec4 color;
layout(location = 0) uniform vec2 res;
// layout(pixel_center_integer) in vec4 gl_FragCoord;
// in vec4 gl_FragCoord;
in vec2 tex_coord;
flat in vec4 _rect;
flat in float _depth;
flat in vec4 _fill_color;
flat in float _rounding;
flat in float _stroke;
flat in vec4 _stroke_color;
flat in vec4 _clip;

#include <sdf>
#include <msaa>
#include <clip>

#define rounding _rounding
#define rect _rect
#define fill_color _fill_color
#define stroke _stroke
#define stroke_color _stroke_color
#define clip _clip

// gl_FragCoord

vec3 sample_rgb(vec2 off) {
	vec3 acc = vec3(0);
	vec2 p = get_p(res) + off;
	float dist = sdf_rounded_rect(p - vec2(rect.x, -rect.y), rect.zw / 2, vec4(rounding));
	acc = fill_color.xyz;
	if (stroke != 0) if (dist > - stroke) acc = stroke_color.xyz;
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
	color.w = sample_a(vec2(0));
	msaa8_scope_begin(color.rgb, vec2(0.5))
		color.rgb += sample_rgb(msaa_off);
	msaa8_scope_end(color.rgb)

	// color.xyzw = vec4(0, 0, 0, 1);
	// vec2 uva = p_from_rect_uv(tex_coord, rect);
	// vec2 uvb = vec2(gl_FragCoord.x - res.x / 2, res.y / 2 - gl_FragCoord.y);
	// color.xy = 10000000 * abs(uva - uvb);
	// color.xy = (gl_FragCoord.xy - res / 2) / res;
	// return;

	color = clip_color(color, gl_FragCoord.xy - res / 2, clip);
	}
