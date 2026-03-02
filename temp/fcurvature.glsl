#version 460 core
layout(binding=0) uniform sampler2D samp_color;
layout(binding=1) uniform sampler2D samp_position;
layout(binding=2) uniform sampler2D samp_normal;
in vec2 tex_coord;
out vec4 color;
uniform vec2 image_res;
uniform float time;
const float EYE_LIMIT=4.0;
#define AA 4
#define NORMAL   0
#define BINORMAL 1
#define TANGENT  2


const float PI = 3.14159265;
const float E=2.71828;
const float TWO_PI=6.28318530;
const float HALF_PI=1.57059632;


#define RECEPTOR mat2x3
#define RECEPTOR_ORIGIN 0
#define RECEPTOR_VECTOR 1


#define ray_t mat2x3
#define ray_position(ray) ray[0]
#define ray_direction(ray) ray[1]


#define sd_t float
const float SDF_CLEAR=1000000;
const float SDF_ZERO=0;


#define csd_t vec2
#define csd_distance(csd) csd.x
#define csd_material(csd) csd.y
const csd_t CSDF_CLEAR=csd_t(1000000,0);
const csd_t CSDF_ZERO=csd_t(0,0);


#define VALUE float
#define uv_t vec2


#define color_t vec3


#define LIGHT vec3
#define SAMPLE mat3x3
#define SAMPLE_COLOR 0
#define SAMPLE_NORMAL 1
#define SAMPLE_POSITION 2


#define WATER 0
#define SAND  1
#define ROCK  2
#define SURF  3
#define SKIN  4
#define FOAM  5
#define DEV   6
#define mat_t float








float rand(float n) { return fract(sin(n)*43758.5453123); }


bool in_range(float x,float lo,float hi) { return (x>=lo)&&(x<=hi); }


float flat_step(float edge0,float edge1,float x) { return clamp((x-edge0)/(edge1-edge0),0,1); }


float nearest(float a, float b, float t) {
	float da=abs(a-t);
	float db=abs(b-t);
	return (da<=db)?a:b; }


float snap(float a,float b,float t) {
	float n=nearest(a,b,t);
	if(n==a) { return 0; } else { return 1; } }


float vec_angle(vec2 vec) {
	vec=normalize(vec);
	if(vec.y>0) { return acos(vec.x); } else { return -acos(vec.x); } }


vec2 angle_vec(float a) { return vec2(cos(a),sin(a)); }


mat3 axify(vec3 normal_ax) {
	vec3 tangent_ax=normalize(cross(normal_ax,normal_ax+(0.2)));
	vec3 binormal_ax=cross(normal_ax,tangent_ax);
	return mat3(normal_ax,binormal_ax,tangent_ax); }


float bell(float x) { return pow(2.0,-x*x); }


vec3 czm_saturation(vec3 rgb,float adjustment) {
	const vec3 w=vec3(0.2125,0.7154,0.0721);
	vec3 intensity=vec3(dot(rgb,w));
	return mix(intensity,rgb,adjustment); }


vec2 advect_uv(vec2 origin,sampler2D flow_map,float flow_rate,int steps) {
	vec2 uv=origin;
	for(int i=0; i<steps; i+=1) {
		vec2 delta=texture(flow_map,uv).xy;
		delta=(delta-vec2(0.5))*2;
		uv+=delta*flow_rate; }
	return uv; }


float ndot(vec2 a,vec2 b) { return a.x*b.x-a.y*b.y; }


float dot2(vec2 v) { return dot(v,v); }


float dot2(vec3 v) { return dot(v,v); }


vec3 vec3_to_rgb(vec3 p,float ceiling) {
	return 0.5*(p/ceiling)+vec3(0.5); }


vec3 rgb_to_vec3(vec3 p,float ceiling) {
	return 2*(p-vec3(0.5))*ceiling; }
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

