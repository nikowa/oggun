layout(binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
flat in float _depth;
void main(void) {
	gl_FragDepth = _depth;
	color = texture(samp, vec2(tex_coord.x, tex_coord.y)); }
	// color.xyz = vec3(_depth); }
