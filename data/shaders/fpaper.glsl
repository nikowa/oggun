layout(binding=0)uniform sampler2D samp_image;
layout(binding=1)uniform sampler2D samp_paper;
in vec2 tex_coord;
out vec4 color;
void main(void) {
	//color.xyz=texture(samp_image,tex_coord).xyz-(vec3(1)-texture(samp_paper,tex_coord).xyz);
	color.xyz=texture(samp_image,tex_coord).xyz;
	color.w=1; }
