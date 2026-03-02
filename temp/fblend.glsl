#version 460 core
layout(binding=0) uniform sampler2D samp_color_0;
layout(binding=1) uniform sampler2D samp_normal_0;
layout(binding=2) uniform sampler2D samp_position_0;
layout(binding=3) uniform sampler2D samp_depth_0;
layout(binding=4) uniform sampler2D samp_color_1;
layout(binding=5) uniform sampler2D samp_normal_1;
layout(binding=6) uniform sampler2D samp_position_1;
layout(binding=7) uniform sampler2D samp_depth_1;
layout(location=0) out vec4 color;
layout(location=1) out vec3 position;
layout(location=2) out vec3 normal;
layout(location=3) out float depth;
in vec2 tex_coord;
void main(void) {
	//float t=texture(samp_depth_1,tex_coord).x>texture(samp_depth_0,tex_coord).x?1:0;
	float t=float(texture(samp_depth_0,tex_coord).x>texture(samp_depth_1,tex_coord).x);
	color=mix(texture(samp_color_0,tex_coord),texture(samp_color_1,tex_coord),t);
	position=mix(texture(samp_position_0,tex_coord).xyz,texture(samp_position_1,tex_coord).xyz,t);
	normal=mix(texture(samp_normal_0,tex_coord).xyz,texture(samp_normal_1,tex_coord).xyz,t);
	depth=mix(texture(samp_depth_0,tex_coord).x,texture(samp_depth_1,tex_coord).x,t);
	color.w=1;
	//color.xyz=mix(texture(samp_position_0,tex_coord).xyz,texture(samp_position_1,tex_coord).xyz,t);
}

