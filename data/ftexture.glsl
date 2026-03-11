layout(binding=0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
void main(void) {
	color = texture(samp, vec2(tex_coord.x, 1 - tex_coord.y)); }
