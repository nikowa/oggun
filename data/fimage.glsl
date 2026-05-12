layout(binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
flat in float _depth;

void main(void) {
	color = texture(samp, vec2(tex_coord.x, tex_coord.y));
	gl_FragDepth = _depth;
	if (color.w == 0.0) {
		gl_FragDepth = 1.0; } }
