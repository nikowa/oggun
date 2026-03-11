layout (binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
void main (void) {
	float alpha = texture(samp, tex_coord).w;
	color = vec4(alpha, alpha, alpha, 1.0);
}
