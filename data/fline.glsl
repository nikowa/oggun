out vec4 color;
layout(location = 0) uniform vec2 res;
in vec4 gl_FragCoord;

flat in vec4 _line_color;
flat in float _depth;
flat in vec4 _clip;

#define line_color _line_color
#define depth _depth

#include <clip>

#define clip _clip

void main(void) {
	color = line_color;
	gl_FragDepth = depth;

	color = clip_color(color, gl_FragCoord.xy - res / 2, clip); }
