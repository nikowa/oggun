layout(binding=0) uniform sampler2D samp_color;
layout(binding=1) uniform sampler2D samp_position;
layout(binding=2) uniform sampler2D samp_normal;
in vec2 tex_coord;
out vec4 color;
uniform vec2 image_res;
uniform float time;
const float EYE_LIMIT=4.0;
#define AA 4
#include <util.glsl>
vec4 texture_antialiased(sampler2D samp,vec2 uv,float blur) {
	vec4 acc=vec4(0);
	float d=0;
	vec4 center=texture(samp,uv);
	for(int u=0; u<AA; u+=1) { for(int v=0; v<AA; v+=1) {
		acc+=texture(samp,uv-2*vec2(0.5)/image_res+2*blur*vec2(u,v)/AA/image_res);
		if(abs(center.w-acc.w)>16.0) {
			d=1; } } }
	acc/=AA*AA;
	return acc; }
float range_filter(float c,float range) {
	c=clamp(c,0,1);
	float lo=abs(c);
	float hi=abs(1-c);
	if((lo<range)||(hi<range)) {
		return 1; }
	else {
		return 0; } }
float curvature() {
	const float THRESHOLD_DIST=0.08*0.5;
	const float DELTA=0.16*0.5;
	//const float MIN_DEPTH=(sin(time)+1)*0.2;
	const float MIN_DEPTH=0.0;
	const float MAX_DEPTH=1.5;
	float c=0.0;
	int sample_count=0;
	vec2 origin=tex_coord;
	float sum_length=0;
	//vec3 origin_pos=rgb_to_vec3(texture_antialiased(samp_position,origin,2).xyz,EYE_LIMIT);
	vec3 origin_pos=rgb_to_vec3(texture(samp_position,origin).xyz,EYE_LIMIT);
	for(float i=-THRESHOLD_DIST; i<=THRESHOLD_DIST; i+=DELTA) {
		for(float j=-THRESHOLD_DIST; j<=THRESHOLD_DIST; j+=DELTA) {
			vec2 pos=tex_coord+vec2(i,j)/vec2(image_res.x/2,image_res.y/2);
			//vec3 other_pos=rgb_to_vec3(texture_antialiased(samp_position,pos,2).xyz,EYE_LIMIT);
			vec3 other_pos=rgb_to_vec3(texture(samp_position,pos).xyz,EYE_LIMIT);
			sum_length+=length(other_pos-origin_pos);
			if(length(other_pos-origin_pos)>MAX_DEPTH) {
				continue; }
			if(length(other_pos-origin_pos)<MIN_DEPTH) {
				continue; }
			/*if((pow(i,2)+pow(j,2))>pow(THRESHOLD_DIST,2)) {
				continue; }*/
			vec3 dist=other_pos-origin_pos;
			//vec3 norm=rgb_to_vec3(texture_antialiased(samp_normal,pos,1).xyz,1);
			vec3 norm=rgb_to_vec3(texture(samp_normal,pos).xyz,1);
			c+=dot(dist,norm);
			sample_count+=1; } }
	c/=THRESHOLD_DIST/DELTA;
	//c*=7.5; // TODO Is this resolution-dependent?
	return c; }
void main(void) {
	//color = vec4(0,0,0,1);
	float curv=curvature();
	float inside=0;
	float outside=0;
	float rf=range_filter(curv,0.45);
	/*
	if(curv>3.2) {
		inside = rf; }
	if(curv<0.5) {
		outside = rf; }
	curv = (curv-0.5)/4+0.5;
	*/
	color.xyz=texture(samp_color,tex_coord).xyz; //color.xyz=vec3(0);
	if(curv<-0.005) {
		color.xyz=mix(color.xyz,vec3(1),rf);
		//color.xyz=vec3(1,0,0);
	}
	if(curv>0.005) {
		color.xyz=mix(color.xyz,vec3(0),rf);
		//color.xyz=vec3(0,0,1);
	}
	//color.xyz=vec3(rf);
	//color.xyz=vec3(curv);
	//color.xyz=rgb_to_vec3(texture(samp_position,tex_coord).xyz,EYE_LIMIT);
	//color.xyz=128*(vec3(curv));
	//color.xyz*=length(gl_FragCoord.);
}
