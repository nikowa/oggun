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

	msaa16_scope_begin(color, vec2(1.0))
		// color += texture(samp, tex_coord + 1 * msaa_off);
		// (TODO): Why can't I use "get_p" here instead of "gl_FragCoord.xy - res / 2"? Why is "get_p" inverted-Y?
		//         One of them must be changed. Have some consistency, please!
		color += clip_color_rounded(texture(samp, tex_coord + msaa_off / rect.zw), gl_FragCoord.xy - res / 2 + msaa_off, clip, clip_radius);
	msaa16_scope_end(color)

	// color = texture(samp, tex_coord);
	gl_FragDepth = _depth;
	// color = clip_color_rounded(color, gl_FragCoord.xy - res / 2, clip, clip_radius);
	if (color.w == 0.0) {
		gl_FragDepth = 1.0; } }
