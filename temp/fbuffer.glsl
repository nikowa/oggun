#version 460 core
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








float posterize(float t,int n) {
	return round(n*t)/n; }
vec3 posterize(vec3 c,int n) {
	return vec3(round(n*c.x)/n,round(n*c.y)/n,round(n*c.z)/n); }
vec3 saturation(vec3 rgb,float adjustment) {
	const vec3 w=vec3(0.2125,0.7154,0.0721);
	vec3 intensity=vec3(dot(rgb,w));
	return mix(intensity,rgb,adjustment); }
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
