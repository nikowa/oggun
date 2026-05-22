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
#define rounding _rounding
#define rect _rect
#define fill_color _fill_color
#define stroke _stroke
#define stroke_color _stroke_color

void main(void) {
	vec2 pos = rect.xy;
	vec2 size = rect.zw;
	color = vec4(0);
	gl_FragDepth = _depth;
	// vec2 p = gl_FragCoord.xy - res * 0.5 - pos;
	vec2 p = ((tex_coord - vec2(0.5)) * rect.zw + vec2(rect.x, -rect.y));
	vec2 b = size/2 - vec2(rounding);
	vec2 d = abs(p) - b;
	float dist = length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
	dist = sdf_rounded_rect(p - vec2(rect.x, -rect.y), size / 2, vec4(rounding));
	if(dist < 0) { color = fill_color; }
	if((dist > - stroke) && (dist < 0)) { color = stroke_color; } }
