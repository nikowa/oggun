out vec4 color;
layout(location = 0) uniform vec2 res;
in vec4 gl_FragCoord;

flat in vec4 _line_color;
flat in float _depth;
flat in vec4 _clip;
flat in float _clip_radius;

#include <clip>

#define line_color _line_color
#define depth _depth
#define clip _clip
#define clip_radius _clip_radius

void main(void) {
	color = line_color;
	gl_FragDepth = depth;

	color = clip_color_rounded(color, gl_FragCoord.xy - res / 2, clip, clip_radius); }
