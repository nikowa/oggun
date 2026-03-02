#version 460 core
layout (binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
uniform vec2 resolution;
uniform vec2 window_size;
void main (void) {
	ivec2 index=ivec2(tex_coord*window_size);
	vec2 delta=vec2(0.5)/resolution;
	vec4 w=vec4(0.25);
	// Direct //
	if((index.x%2==0)&&(index.y%2==0)) {
		color=texture(samp,tex_coord); }
	// First Pass //
	if((index.x%2==1)&&(index.y%2==1)) {
		vec4 a=texture(samp,tex_coord+vec2(delta.x,delta.y));
		vec4 b=texture(samp,tex_coord+vec2(delta.x,-delta.y));
		vec4 c=texture(samp,tex_coord+vec2(-delta.x,-delta.y));
		vec4 d=texture(samp,tex_coord+vec2(-delta.x,delta.y));
		color=w*transpose(mat4(a,b,c,d)); }
	// Second Pass //
}

