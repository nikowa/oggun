layout(binding=0) uniform sampler2D samp;
layout(binding=1) uniform sampler2D samp_position;
layout(binding=2) uniform sampler2D samp_normal;
layout(binding=3) uniform sampler2D samp_depth;
layout(binding=4) uniform sampler2D samp_threshold;
layout(binding=5) uniform sampler2D samp_blue_noise;
layout(binding=6) uniform sampler2D samp_advector;
in vec2 tex_coord;
out vec4 color;
uniform vec2 this_buffer_res;
uniform vec2 main_buffer_res;
uniform vec2 threshold_res;
uniform vec2 blue_noise_res;
uniform float time;
uniform int high_contrast;
#include <dither.glsl>
#include <color.glsl>
#include "quantize.glsl"
#define PALETTE_SIZE 5
vec3 palette[PALETTE_SIZE]=vec3[PALETTE_SIZE](
	vec3(38,70,83)/vec3(255),
	vec3(42,157,143)/vec3(255),
	vec3(233,196,106)/vec3(255),
	vec3(244,162,97)/vec3(255),
	vec3(231,111,81)/vec3(255));

vec3 palette_nearest(vec3 sample_color) {
	vec3 sample_color_n = normalize(sample_color);
	float best_dist = 2;
	vec3 best_target_n = sample_color_n;
	for(int i=0; i<PALETTE_SIZE; i+=1) {
		vec3 target = palette[i];
		vec3 target_n = normalize(target);
		float dist = length(target_n-sample_color_n);
		if(dist<best_dist) {
			best_dist = dist;
			best_target_n = target_n; } }
	return best_target_n*length(sample_color); }

vec3 bound_palette_nearest(vec3 sample_color,float lower_bound) {
	vec3 sample_color_n = normalize(sample_color);
	float best_dist = 2;
	vec3 best_target_n = sample_color_n;
	for(int i=0; i<PALETTE_SIZE; i+=1) {
		vec3 target = palette[i];
		vec3 target_n = normalize(target);
		float dist = length(target_n-sample_color_n);
		if((dist<best_dist)&&(dist>lower_bound)) {
			best_dist = dist;
			best_target_n = target_n; } }
	return best_target_n*length(sample_color); }

vec3 apply_palette(vec3 color) {
	return palette_nearest(color);
	vec3 first = palette_nearest(color);
	float first_dist = length(normalize(color)-normalize(first));
	vec3 second = bound_palette_nearest(color,first_dist);
	float second_dist = length(normalize(color)-normalize(second));
	return bound_palette_nearest(color,second_dist); }

//float posterize(float t,int n) {
//	return round(n*t)/n; }

float fsd_dither_map[3][3] = {
	{0.0,   0.0,   0.0},
	{0.0,   0.0,   0.0},
	{3.0/16,5.0/16,1.0/16}};

vec2 advect_uv(vec2 origin,sampler2D flow_map,float flow_rate,int steps,float noise) {
	vec2 uv=origin;
	for(int i=0; i<steps; i+=1) {
		vec2 delta=mix(texture(flow_map,uv).xy,texture(samp_advector,uv).xy,noise);
		delta=(delta-vec2(0.5))*2;
		delta.y+=1;
		uv+=delta*flow_rate; }
	return uv; }

void main (void) {
	color.w=1;
	color.xyz=texture(samp,tex_coord).xyz;
//	return;
	vec3 real_color=color.xyz;
	//real_color=posterize(real_color,4);
	vec3 acc=real_color;
	for(int i=0; i<=2; i+=1) for(int j=0; j<=2; j+=1) {
		vec3 other_color=texture(samp,tex_coord+vec2((1-i)/this_buffer_res.x,(1-j)/this_buffer_res.y)).xyz;
		acc+=(other_color-quantize(other_color))*fsd_dither_map[i][j]; }
	color.xyz=quantize(acc)*vec3(posterize(real_color,4));
	//color.xyz=vec3(flat_step(-texture(samp_depth,tex_coord).x,-0.5,-0.51));
	//color.xyz=contrast(color.xyz,flat_step(-1,1,sin(time)));
	float fog=(texture(samp_depth,tex_coord).x-0.50)*4;
	//color.xyz=texture(samp,tex_coord).xyz;
	//color.xyz=real_color;
	//vec2 auv=advect_uv(tex_coord,samp_normal,-0.01-sin(time)*0.01,8,0.1);
	//vec2 auv=advect_uv(tex_coord,samp_normal,-0.008,2,0.1);
	//auv=advect_uv(auv,samp_normal,0.008,2,0.1);
	//color.xyz=texture(samp,auv).xyz;
	//color.xyz=rgb_to_vec3(texture(samp_normal,tex_coord).xyz,1);
	//color.xyz=texture(samp_normal,tex_coord).xyz;
	//color.xyz=vec3(auv,0); 
	//color.xyz=contrast(color.xyz,clamp(1-fog,0,1));
	//color.xyz=mix(color.xyz,(contrast(color.xyz,0.5)-normalize(vec3(1))),0.5*(sin(0.5*time)+1));
}
