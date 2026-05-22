out vec4 color;
layout(location = 0) uniform vec2 res;
in vec2 tex_coord;
flat in vec4 _rect;
flat in float _depth;
flat in vec4 _fill_color;
flat in float _rounding;
flat in float _stroke;
flat in vec4 _stroke_color;

#include <sdf>
#include <msaa>

#define rounding _rounding
#define rect _rect
#define fill_color _fill_color
#define stroke _stroke
#define stroke_color _stroke_color

vec4 sample_raw(vec2 uv, vec2 b) {
	vec4 acc = vec4(0);
	vec2 p = ((uv - vec2(0.5)) * rect.zw + vec2(rect.x, -rect.y));
	vec2 d = abs(p) - b;
	float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
	dist = sdf_rounded_rect(p - vec2(rect.x, -rect.y), rect.zw / 2, vec4(rounding));
	if(dist < 0) { acc = fill_color; }
	if((dist > - stroke) && (dist < 0)) { acc = stroke_color; }
	return acc; }

void main(void) {
	color = vec4(0);
	gl_FragDepth = _depth;
	vec2 b = rect.zw / 2 - vec2(rounding);

	msaa8_scope_begin(color, 2 * rect.zw)
		color += sample_raw(tex_coord + msaa_off, b);
	msaa8_scope_end(color)

	// color = sample_raw(tex_coord, b);

	// msaa8_scope_begin(color.w, res)
	// 	color.w += 1.0 * sample_styled(tex_coords + msaa_off).w;
	// msaa8_scope_end(color.w)

}
