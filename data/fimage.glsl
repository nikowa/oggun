layout(binding = 0) uniform sampler2D samp;
layout(location = 0) uniform vec2 res;
in vec4 gl_FragCoord;
in vec2 tex_coord;
out vec4 color;
flat in float _depth;
flat in vec4 _rect;
flat in vec4 _clip;
flat in float _clip_radius;

#include <msaa>
#include <clip>

#define rect _rect
#define clip _clip
#define clip_radius _clip_radius

void main(void) {

	msaa8_scope_begin(color, 2 * rect.zw)
		color += texture(samp, tex_coord + 1 * msaa_off);
	msaa8_scope_end(color)

	// color = texture(samp, tex_coord);
	gl_FragDepth = _depth;
	color = clip_color_rounded(color, gl_FragCoord.xy - res / 2, clip, clip_radius);
	if (color.w == 0.0) {
		gl_FragDepth = 1.0; } }
