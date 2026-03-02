#version 460 core
layout (binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
uniform vec2 window_size;
void main (void) {
	color=texture(samp,tex_coord);
	ivec2 index=ivec2(tex_coord*window_size);
	vec2 delta=vec2(0.5)/window_size;
	vec4 w=vec4(0.25);
	// Direct //
	if((index.x%2)==(index.y%2)) {
		color=texture(samp,tex_coord); }
	// First Pass //
	else {
		vec4 a=texture(samp,tex_coord+vec2(delta.x,0));
		vec4 b=texture(samp,tex_coord+vec2(0,-delta.y));
		vec4 c=texture(samp,tex_coord+vec2(-delta.x,0));
		vec4 d=texture(samp,tex_coord+vec2(0,delta.y));
		color=w*transpose(mat4(a,b,c,d)); }
	// Second Pass //
}
c,d));
	}*/
	// Second Pass //
}
ss //
}
