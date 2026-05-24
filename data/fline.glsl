out vec4 color;

flat in vec4 _line_color;
flat in float _depth;

#define line_color _line_color
#define depth _depth

void main(void) {
	color = line_color;
	gl_FragDepth = depth; }
