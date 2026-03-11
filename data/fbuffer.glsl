#include <color.glsl>
layout (binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;

vec3 tonemap(vec3 c) {
	return 2.5 * c / (1.0 + 1.5 * c); }

void main (void) {
	color.xyz = texture(samp, tex_coord).xyz;
	color.w = 1.0;
	gl_FragDepth = texture(samp, tex_coord).w;
	color.xyz=saturation(color.xyz,1.5); }