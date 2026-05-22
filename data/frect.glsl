out vec4 color;
layout(location = 0) uniform vec2 res;
in vec2 tex_coord;
flat in vec4 _rect;
flat in float _depth;
flat in vec4 _fill_color;
flat in float _rounding;
#include <sdf>
#define rounding _rounding
#define rect _rect
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
	if(dist < 0) { color = _fill_color; }
	if(dist > -2) { color.rgb = vec3(0, 0, 1); } }
