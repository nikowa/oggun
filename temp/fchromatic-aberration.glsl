#version 460 core
layout(binding=0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;


void main(void) {
	float t = length(tex_coord - vec2(0.5)) * 1 - 0.0;
	t = pow(t, 2);
	float r = texture(samp, tex_coord).r;
	float g = texture(samp, tex_coord).g;
	float b = texture(samp, tex_coord).b;
	float force = 0.004 * t;
	color.r = texture(samp, tex_coord + vec2(force * r, 0)).r;
	color.g = g;
	color.b = texture(samp, tex_coord - vec2(force * b, 0)).b;
	// color.r = t;
	// color.gb = vec2(0);
	color.w = 1.0; }


