layout (binding = 0) uniform sampler2D samp;
layout (binding = 1) uniform sampler2D samp_bold;

layout (location = 0) uniform vec2 res;

in vec2 tex_coords;
flat in uint _symbol;
flat in vec4 _text_color;
flat in vec2 quad_size;
flat in uint _bold;
flat in vec2 _uv_offset;
flat in vec4 _clip;
out vec4 color;

#define bold _bold

#include <msaa>
#include <clip>

#define clip _clip

float sample_alpha(vec2 uv) {
	vec2 offset = vec2(_symbol % 16, _symbol / 16 - 15);
	uv = vec2(uv.x, 1 - uv.y);
	uv /= 16;
	uv.x += float(_symbol % 16) / 16;
	uv.y += float(_symbol / 16) / 16;
	return texture(samp, uv).a; }
	// return texture((bold == 1) ? samp_bold : samp, uv); }

void main(void) {
	vec2 uv = tex_coords + _uv_offset;
	msaa16_scope_begin(color.w, 4 * quad_size)
		color.w += sample_alpha(uv + msaa_off);
	msaa16_scope_end(color.w)
	// color.w = 1 - pow(1 - color.w, 2.0);

	// if (color.w < 0.25) color.w = 0.0;

	// color.w = pow(color.w, 0.5);
	color.rgb = _text_color.rgb;
	color.a *= _text_color.a;
	// color.xyz = sample_raw(uv).xyz;
	// color.w = 1;
	color = clip_color(color, gl_FragCoord.xy - res / 2, clip);

	// TEMP
	// color.a = 1;
	// color.rgb = vec3(0);
	// color.rg = tex_coords;

	if (color.w == 0.0) { gl_FragDepth = 1.0; }

}
