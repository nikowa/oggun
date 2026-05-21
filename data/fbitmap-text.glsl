layout (binding = 0) uniform sampler2D samp;

layout (location = 0) uniform vec2 res;

in vec2 tex_coords;
flat in uint _symbol;
flat in vec4 _text_color;
flat in vec2 quad_size;
out vec4 color;

vec4 sample_raw(vec2 uv) {
	vec2 offset = vec2(_symbol % 16, _symbol / 16 - 15);
	uv = vec2(uv.x, 1 - uv.y);
	uv /= 16;
	uv.x += float(_symbol % 16) / 16;
	uv.y += float(_symbol / 16) / 16;
	return texture(samp, uv); }

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

const vec2 AA_OFF[8] = {
	vec2(0.279, 0.719),
	vec2(0.552, 0.107),
	vec2(0.499, 0.266),
	vec2(0.361, 0.881),
	vec2(0.579, 0.743),
	vec2(0.735, 0.995),
	vec2(0.002, 0.516),
	vec2(0.617, 0.177) };

#define AA 8

void main(void) {
	vec2 pixel_size = vec2(1) / quad_size;
	for (int i = 0; i < AA; i += 1) {
		vec2 off = (AA_OFF[i] - vec2(0.5));
		color.w += 1 * sample_styled(tex_coords + pixel_size * off).w; }
	color.w /= float(AA);
	// color.w = 1 - pow(1 - color.w, 2.0);
	// if (color.w < 0.16) color.w = 0.0;
	// color.w = pow(color.w, 0.5);
	color.rgb = sample_styled(tex_coords).rgb;
	if (color.w == 0.0) { gl_FragDepth = 1.0; } }
