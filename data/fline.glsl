out vec4 color;
layout(location = 2) uniform vec4 line_color;
layout(location = 3) uniform float depth;

void main(void) {
	color = line_color;
	gl_FragDepth = depth; }
