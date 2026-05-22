layout (binding = 0) uniform sampler2D samp;
layout (binding = 1) uniform sampler2D samp_bold;

layout (location = 0) uniform vec2 res;

in vec2 tex_coords;
flat in uint _symbol;
flat in vec4 _text_color;
flat in vec2 quad_size;
flat in uint _bold;
out vec4 color;

#define bold _bold

#include <msaa>

vec4 sample_raw(vec2 uv) {
	vec2 offset = vec2(_symbol % 16, _symbol / 16 - 15);
	uv = vec2(uv.x, 1 - uv.y);
	uv /= 16;
	uv.x += float(_symbol % 16) / 16;
	uv.y += float(_symbol / 16) / 16;
	return texture(samp, uv); }
	// return texture((bold == 1) ? samp_bold : samp, uv); }

vec4 sample_styled(vec2 uv) {
	return _text_color * sample_raw(uv); }
	// vec4 pc;
	// pc.w=step(0.1,sample_bitmap(uv).w)*frag_text_color.w;
	// pc.xyz=(frag_text_color.xyz);//*vec3(1-pc.w)
	// // pc.xyz=vec3(0);
	// // pc.xyz=pc.xyz;
	// // pc.xyz=vec3(1-pc.w);
	// // pc.w=1;
	// // pc.w=step(0.01,pc.w*frag_text_color.w);
	// float ol=outline(uv);
	// if(ol>0.0){
	// 	pc=mix(pc,vec4(vec3(0),1),ol); }
	// else if(shadow(uv)) {
	// 	pc=SHADOW_COLOR; }
	// return pc; }

void main(void) {
	msaa8_scope_begin(color.w, 1 * quad_size)
		color.w += 1.0 * sample_styled(tex_coords + msaa_off).w;
	msaa8_scope_end(color.w)
	// color.w = 1 - pow(1 - color.w, 2.0);
	if (color.w < 0.25) color.w = 0.0;
	// color.w = pow(color.w, 0.5);
	color.rgb = sample_styled(tex_coords).rgb;
	if (color.w == 0.0) { gl_FragDepth = 1.0; } }
