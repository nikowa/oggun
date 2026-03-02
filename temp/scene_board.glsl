#version 460 core
#define MAX_INDEX 255
layout(location=0) out vec4 color;
layout(binding=0) uniform sampler2D skybox_sampler;
in vec2 tex_coord;
uniform float time;
uniform vec2 res;
uniform vec3 camera_position;
uniform vec3 camera_direction;
uniform vec3 camera_up_direction;
uniform vec3 camera_side_direction;
uniform vec3 surf_position;
uniform vec3 sun_dir;
uniform float camera_zoom;
uniform int hovered_index;
const int STEPS_LIMIT=240;
const float EPSILON=0.02; // low: 0.02, high: 0.001
const float SHADOW_RADIUS=0.02;
const float SHADOW_LIMIT=8.0;
const float E=2.71828;
const float PI=3.14159265;
const float TWO_PI=6.28318530;
const float HALF_PI=1.57059632;
const float DELTA=0.01;
const float HALF_DELTA=DELTA/2;
const int NORMAL=0;
const int BINORMAL=1;
const int TANGENT=2;
float pixel_seed;
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








#define mat4_translate_x(v) mat4(1,0,0,0,0,1,0,0,0,0,1,0,v,0,0,1)
#define mat2_rotate(v) mat2(cos(v),-sin(v),sin(v),cos(v))
vec3 translate_x(vec3 p,float d) {
	return (mat4_translate_x(d)*vec4(p,1)).xyz; }
#define mat4_translate_y(v) mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,v,0,1)
vec3 translate_y(vec3 p,float d) {
	return (mat4_translate_y(d)*vec4(p,1)).xyz; }
#define mat4_translate_z(v) mat4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,v,1)
vec3 translate_z(vec3 p,float d) {
	return (mat4_translate_z(d)*vec4(p,1)).xyz; }
#define mat4_translate(v) mat4(1,0,0,0,0,1,0,0,0,0,1,0,v.x,v.y,v.z,1)
vec3 translate(vec3 p,vec3 d) {
	return (mat4_translate(d)*vec4(p,1)).xyz; }
#define mat4_scale(s) mat4(1.0/s,0,0,0,0,1.0/s,0,0,0,0,1.0/s,0,0,0,0,1)
vec3 scale(vec3 p,float s) {
	return (mat4_scale(s)*vec4(p,1)).xyz; }
#define mat4_scale_offset(s,o) (mat4_translate(-o)*mat4_scale(s)*mat4_translate(o))
vec3 scale_offset(vec3 p,float s,vec3 o) {
	return (mat4_scale_offset(s,o)*vec4(p,1)).xyz; }
#define mat4_rotate_x(a) mat4(1,0,0,0,0,cos(a),-sin(a),0,0,sin(a),cos(a),0,0,0,0,1)
vec3 rotate_x(vec3 p,float a) {
	return (mat4_rotate_x(a)*vec4(p,1)).xyz; }
#define mat4_rotate_y(a) mat4(cos(a),0,sin(a),0,0,1,0,0,-sin(a),0,cos(a),0,0,0,0,1)
vec3 rotate_y(vec3 p,float a) {
	return (mat4_rotate_y(a)*vec4(p,1)).xyz; }
#define mat4_rotate_z(a) mat4(cos(a),-sin(a),0,0,sin(a),cos(a),0,0,0,0,1,0,0,0,0,1)
vec3 rotate_z(vec3 p,float a) {
	return (mat4_rotate_z(a)*vec4(p,1)).xyz; }
#define mat4_rotate(a) (mat4_rotate_x(a.x)*mat4_rotate_y(a.y)*mat4_rotate_z(a.z))
vec3 rotate(vec3 p,vec3 a) {
	return (mat4_rotate(a)*vec4(p,1)).xyz; }
#define mat4_rotate_offset(a,o) (mat4_translate(-o)*mat4_rotate(a)*mat4_translate(o))
vec3 rotate_offset(vec3 p,vec3 a,vec3 o) {
	return (mat4_rotate_offset(a,o)*vec4(p,1)).xyz; }
#define mat4_mirror_x(h) mat4(-1,0,0,0,0,1,0,0,0,0,1,0,h,0,0,1)
vec3 mirror_x(vec3 p,float h) {
	return (mat4_mirror_x(h)*vec4(p,1)).xyz; }
#define mat4_mirror_y(h) mat4(1,0,0,0,0,-1,0,0,0,0,1,0,0,h,0,1)
vec3 mirror_y(vec3 p,float h) {
	return (mat4_mirror_y(h)*vec4(p,1)).xyz; }
#define mat4_mirror_z(h) mat4(1,0,0,0,0,1,0,0,0,0,-1,0,0,0,h,1)
vec3 mirror_z(vec3 p,float h) {
	return (mat4_mirror_z(h)*vec4(p,1)).xyz; }
#define mat4_bend_xy(k) mat4(cos(k*p.x),-sin(k*p.x),0,0, sin(k*p.x),cos(k*p.x),0,0, 0,0,1,0, 0,0,0,1)
vec3 bend_xy(vec3 p,float k) {
	return (mat4_bend_xy(k)*vec4(p,1)).xyz; }
#define mat4_bend_yx(k) mat4(sin(k*p.y),cos(k*p.y),0,0,cos(k*p.y),-sin(k*p.y),0,0,0,0,1,0,0,0,0,1)
#define mat4_bend_xz(k) mat4(cos(k*p.x),0,-sin(k*p.x),0,0,1,0,0,sin(k*p.x),0,cos(k*p.x),0,0,0,0,1)
#define mat4_bend_zx(k) mat4(sin(k*p.z),0,cos(k*p.z),0,0,1,0,0,cos(k*p.z),0,-sin(k*p.z),0,0,0,0,1)
#define mat4_bend_yz(k) mat4(1,0,0,0,0,1,0,0,0,0,cos(k*p.y),-sin(k*p.y),0,0,sin(k*p.y),cos(k*p.y))
#define mat4_bend_zy(k) mat4(1,0,0,0,0,1,0,0,0,0,sin(k*p.z),cos(k*p.z),0,0,cos(k*p.z),-sin(k*p.z))
vec3 repeat(vec3 p,vec3 s) {
	return p-s*round(p/s); }
vec3 repeat_finite(vec3 p,float s,vec3 l) {
	return p-s*clamp(round(p/s),-l,l); }
vec3 bend_y(vec3 p,float k) {
	float c=cos(k*p.x);
	float s=sin(k*p.x);
	mat2 m=mat2(c,-s,s,c);
	p.xy*=m;
	return p; }
vec3 sceil(vec3 v) {
	return vec3(ceil((v.x-1)/2)*2,ceil((v.y-1)/2)*2,ceil((v.z-1)/2)*2); }
vec3 abs_x(vec3 p) {
	return vec3(abs(p.x),p.yz); }
vec3 abs_y(vec3 p) {
	return vec3(p.x,abs(p.y),p.z); }
vec3 abs_z(vec3 p) {
	return vec3(p.xy,abs(p.z)); }









/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                      O P E R A T O R S                                      |
  |_____________________________________________________________________________________________|*/


bool inside(sd_t x) { return x<=0; }


bool outside(sd_t x) { return x>0; }


sd_t sdf_sect(sd_t a,sd_t b) {
	return max(a,b); }


sd_t sdf_smooth_sect(sd_t a,sd_t b,float k) {
	float h=clamp(0.5-0.5*(b-a)/k,0,1);
	return mix(b,a,h)+k*h*(1-h); }


sd_t sdf_union(sd_t a,sd_t b) {
	return min(a,b); }


sd_t sdf_smooth_union(sd_t a,sd_t b,float k) {
	float h=clamp(0.5+0.5*(b-a)/k,0,1);
	return mix(b,a,h)-k*h*(1-h); }


sd_t sdf_diff(sd_t a,sd_t b) {
	return max(a,-b); }


sd_t sdf_smooth_diff(sd_t a,sd_t b,float k) {
	float h=clamp(0.5-0.5*(b+a)/k,0,1);
	return mix(a,-b,h)+k*h*(1-h); }


sd_t sdf_xor(sd_t a,sd_t b) {
	return max(min(a,b),-max(a,b)); }


sd_t sdf_inverse(sd_t a) {
	return -a; }


sd_t sdf_round(sd_t a,float r) {
	return a-r; }


sd_t sdf_onion(sd_t d,float r) {
	return abs(d)-r; }


sd_t sdf_displace(sd_t a,float h,float r) {
	return a-(h-0.5)*r; }


sd_t sdf_extrude_x(sd_t d,vec3 s,float h) {
	vec2 q=vec2(d,abs(s.x)-h);
	return min(max(q.x,q.y),0)+length(max(q,0)); }


sd_t sdf_extrude_z(sd_t d,vec3 s,float h) {
	vec2 q=vec2(d,abs(s.z)-h);
	return min(max(q.x,q.y),0)+length(max(q,0)); }


sd_t sdf_extrude_y(sd_t d,vec3 s,float h) {
	vec2 q=vec2(d,abs(s.y)-h);
	return min(max(q.x,q.y),0)+length(max(q,0)); }


sd_t sdf_extrude(sd_t d,vec3 s,vec3 a,float h) {
	vec2 q=vec2(d,abs(dot(s,a))-h);
	vec3 n=cross(s,a);
	vec3 b=cross(a,n);
	return min(max(length(n),length(b)),0)+length(max(q,0)); }


sd_t sdf_mix(sd_t a,sd_t b,float r) {
	return mix(a,b,r); }


sd_t sdf_blinn_potential(sd_t d,float r) {
	return d-r;
	return d-pow(E,-pow(d,2.0)/r);
	return d*pow(E,-r*pow(d,2.0)); }









/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                    P R I M I T I V E S                                      |
  |_____________________________________________________________________________________________|*/


sd_t sdf_plane(vec3 p,vec3 n,float h) {
	n=normalize(n);
	return dot(p,n)+h; }


sd_t sdf_slice(vec3 p,vec3 n,float h) {
	n=normalize(n);
	return abs(dot(p,n))-h; }


sd_t sdf_sphere(vec3 p,float r) {
	return length(p)-r; }


sd_t sdf_cut_sphere(vec3 p,float r,float h) {
	float w=sqrt(r*r-h*h);
	vec2 q=vec2(length(p.xz),p.y);
	float s=max((h-r)*q.x*q.x+w*w*(h+r-2*q.y),h*q.x-w*q.y);
	return (s<0)?length(q)-r:(q.x<w)?h-q.y:length(q-vec2(w,h)); }


sd_t sdf_capsule_x(vec3 p,float r,float l) {
	p.x=sign(p.x)*clamp(abs(p.x)-l,0,1);
	return length(p)-r; }


sd_t sdf_capsule_y(vec3 p,float r,float l) {
	p.y=sign(p.y)*clamp(abs(p.y)-l,0,1);
	return length(p)-r; }


sd_t sdf_capsule_z(vec3 p,float r,float l) {
	p.z=sign(p.z)*clamp(abs(p.z)-l,0,1);
	return length(p)-r; }


sd_t sdf_capsule(vec3 p,vec3 a,vec3 b,float r) {
	vec3 pa=p-a;
	vec3 ba=b-a;
	float h=clamp(dot(pa,ba)/dot(ba,ba),0,1);
	return length(pa-ba*h)-r; }


sd_t sdf_box(vec3 p,vec3 r) {
	vec3 d=abs(p)-r;
	return length(max(d,0))+min(max(d.x,max(d.y,d.z)),0); }


sd_t sdf_box_frame(vec3 p,vec3 r,float t) {
	p=abs(p)-r;
	vec3 q=abs(p+t)-t;
	return min(min(
		length(max(vec3(p.x,q.y,q.z),0))+min(max(p.x,max(q.y,q.z)),0),
		length(max(vec3(q.x,p.y,q.z),0))+min(max(q.x,max(p.y,q.z)),0)),
		length(max(vec3(q.x,q.y,p.z),0))+min(max(q.x,max(q.y,p.z)),0)); }


sd_t sdf_directed_box(vec3 p,vec3 r,vec3 x,vec3 cx) {
	x=normalize(x);
	vec3 y=normalize(cross(x,cx));
	vec3 z=normalize(cross(x,y));
	vec3 q=vec3(length(dot(p,x)),length(dot(p,y)),length(dot(p,z)));
	vec3 d=abs(q)-r;
	return length(max(d,0))+min(max(d.x,max(d.y,d.z)),0); }


sd_t sdf_sliced_box(vec3 p,vec3 r,vec3 n,float h) {
	n=normalize(n);
	vec3 d=abs(p)-r;
	return max(dot(p,n)-h,length(max(d,0))); }


sd_t sdf_nicked_box(vec3 p,vec3 r,float h) {
	vec3 q=abs(p)-r;
	float d=length(max(q,0))+min(max(q.x,max(q.y,q.z)),0);
	d=max(d,sdf_plane(p-vec3(+r.x,+r.y,+r.z),vec3(+1,+1,+1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,+r.y,-r.z),vec3(+1,+1,-1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,-r.y,+r.z),vec3(+1,-1,+1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,-r.y,-r.z),vec3(+1,-1,-1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,+r.y,+r.z),vec3(-1,+1,+1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,+r.y,-r.z),vec3(-1,+1,-1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,-r.y,+r.z),vec3(-1,-1,+1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,-r.y,-r.z),vec3(-1,-1,-1),h));
	return d; }


sd_t sdf_chiselled_box(vec3 p,vec3 r,float h) {
	vec3 q=abs(p)-r;
	float d=length(max(q,0))+min(max(q.x,max(q.y,q.z)),0);
	d=max(d,sdf_plane(p-vec3(0,+r.y,+r.z),vec3(0,+1,+1),h));
	d=max(d,sdf_plane(p-vec3(0,-r.y,+r.z),vec3(0,-1,+1),h));
	d=max(d,sdf_plane(p-vec3(0,+r.y,-r.z),vec3(0,+1,-1),h));
	d=max(d,sdf_plane(p-vec3(0,-r.y,-r.z),vec3(0,-1,-1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,0,+r.z),vec3(+1,0,+1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,0,+r.z),vec3(-1,0,+1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,0,-r.z),vec3(+1,0,-1),h));
	d=max(d,sdf_plane(p-vec3(-r.x,0,-r.z),vec3(-1,0,-1),h));
	d=max(d,sdf_plane(p-vec3(+r.x,+r.y,0),vec3(+1,+1,0),h));
	d=max(d,sdf_plane(p-vec3(-r.x,+r.y,0),vec3(-1,+1,0),h));
	d=max(d,sdf_plane(p-vec3(+r.x,-r.y,0),vec3(+1,-1,0),h));
	d=max(d,sdf_plane(p-vec3(-r.x,-r.y,0),vec3(-1,-1,0),h));
	return d; }


sd_t sdf_rounded_box(vec3 p,vec3 b,float r) {
	vec3 d=abs(p)-(b-vec3(r));
	return length(max(d,0))-r; }


sd_t sdf_directed_torus(vec3 p,vec2 b,vec3 n) {
	n=normalize(n);
	mat3 ax=axify(n);
	vec3 t;
	vec3 bn;
	n=ax[NORMAL];
	bn=ax[BINORMAL];
	t=ax[TANGENT];
	vec2 q=vec2(length(vec2(length(dot(p,t)),length(dot(p,bn))))-b.x,dot(p,n));
	return length(q)-b.y; }


sd_t sdf_torus(vec3 p,vec2 b) {
	vec2 d=vec2(length(p.xy)-b.x,p.z);
	return length(d)-b.y; }


sd_t sdf_cylinder_x(vec3 p,float h,float r) {
	vec2 d=abs(vec2(length(p.yz),p.x))-vec2(r,h);
	return min(max(d.x,d.y),0)+length(max(d,0)); }


sd_t sdf_cylinder_y(vec3 p,float h,float r) {
	vec2 d=abs(vec2(length(p.xz),p.y))-vec2(r,h);
	return min(max(d.x,d.y),0)+length(max(d,0)); }


sd_t sdf_cylinder_z(vec3 p,float h,float r) {
	vec2 d=abs(vec2(length(p.xy),p.z))-vec2(r,h);
	return min(max(d.x,d.y),0)+length(max(d,0)); }


sd_t sdf_infcone_x(vec3 p,vec2 c) {
    vec2 q=vec2(length(p.yz),-p.x);
    float d=length(q-c*max(dot(q,c),0));
    return d*((q.x*c.y-q.y*c.x<0)?-1:1); }


sd_t sdf_infcone_y(vec3 p,vec2 c) {
    vec2 q=vec2(length(p.xz),-p.y);
    float d=length(q-c*max(dot(q,c),0));
    return d*((q.x*c.y-q.y*c.x<0)?-1:1); }


sd_t sdf_infcone_z(vec3 p,vec2 c) {
    vec2 q=vec2(length(p.xy),-p.z);
    float d=length(q-c*max(dot(q,c),0));
    return d*((q.x*c.y-q.y*c.x<0)?-1:1); }


sd_t sdf_cone_x(vec3 p,vec2 b,float h) {
	p.x+=h;
	float d=length(p.yz);
	return max(dot(b.xy,vec2(d,-p.x)),-2*h+p.x); }


sd_t sdf_cone_y(vec3 p,vec2 b,float h) {
	p.y+=h;
	float d=length(p.xz);
	return max(dot(b.xy,vec2(d,-p.y)),-2*h+p.y); }


sd_t sdf_cone_z(vec3 p,vec2 b,float h) {
	p.z+=h;
	float d=length(p.xy);
	return max(dot(b.xy,vec2(d,-p.z)),-2*h+p.z); }


sd_t sdf_directed_cone(vec3 p,vec2 b,vec3 n,float h) {
	n=normalize(n);
	mat3 ax=axify(n);
	vec3 local_p=vec3(dot(p,ax[TANGENT]),dot(p,ax[BINORMAL]),dot(p,ax[NORMAL]));
	float d=length(local_p.xy);
	return max(dot(b.xy,vec2(d,-local_p.z)),-h+local_p.z); }


sd_t sdf_circle(vec2 p,float r) {
	return length(p)-r; }


sd_t sdf_rounded_box(vec2 p,vec2 b,vec4 r) {
	r.xy=(p.x>0)?r.xy:r.zw;
	r.x=(p.y>0)?r.x:r.y;
	vec2 q=abs(p)-b+r.x;
	return min(max(q.x,q.y),0)+length(max(q,0))-r.x; }


sd_t sdf_prism(vec3 p,float r,float h,int order) {
	float d=SDF_CLEAR;
	for(int n=0; n<order; n+=1) {
		float a=float(n)/float(order)*TWO_PI;
		vec3 delta=vec3(angle_vec(a),0);
		d=sdf_union(d,sdf_plane(p,delta,r)); }
	d=-d;
	d=sdf_diff(d,sdf_plane(p,vec3(0,0,1),h));
	d=sdf_diff(d,sdf_plane(p,vec3(0,0,-1),h));
	return d; }


sd_t sdf_octahedron(vec3 p,float r) {
	p=abs(p);
	return (p.x+p.y+p.z-r)*0.57735027; }


sd_t sdf_ellipsoid(vec3 p,vec3 r) {
	float q=length(p/r);
	float q2=length(p/(r*r));
	return (q*q-q)/q2; }


#define STAR_FACE0_ANGLE 0.0000000000
#define STAR_FACE1_ANGLE 3.7699111843
#define STAR_FACE2_ANGLE 1.2566370614
#define STAR_FACE3_ANGLE 5.0265482458
#define STAR_FACE4_ANGLE 2.5132741229
#define STAR_FACE0_ANGLE_COS  1.00000000000000000
#define STAR_FACE0_ANGLE_SIN  0.00000000000000000
#define STAR_FACE1_ANGLE_COS -0.80901699437950380
#define STAR_FACE1_ANGLE_SIN -0.58778525228620180
#define STAR_FACE2_ANGLE_COS  0.30901699440910685
#define STAR_FACE2_ANGLE_SIN  0.95105651628405450
#define STAR_FACE3_ANGLE_COS  0.30901699440910685
#define STAR_FACE3_ANGLE_SIN -0.95105651628405450
#define STAR_FACE4_ANGLE_COS -0.80901699439150270
#define STAR_FACE4_ANGLE_SIN  0.58778525226968690
sd_t sdf_star(vec3 p,float k,float h) {
	vec3 c_fwd=p-vec3(0,0,h);
	vec3 c_bwd=p+vec3(0,0,h);
	float face_fwd0=dot(c_fwd,normalize(vec3(STAR_FACE0_ANGLE_COS,STAR_FACE0_ANGLE_SIN,k)));
	float face_fwd1=dot(c_fwd,normalize(vec3(STAR_FACE1_ANGLE_COS,STAR_FACE1_ANGLE_SIN,k)));
	float face_fwd2=dot(c_fwd,normalize(vec3(STAR_FACE2_ANGLE_COS,STAR_FACE2_ANGLE_SIN,k)));
	float face_fwd3=dot(c_fwd,normalize(vec3(STAR_FACE3_ANGLE_COS,STAR_FACE3_ANGLE_SIN,k)));
	float face_fwd4=dot(c_fwd,normalize(vec3(STAR_FACE4_ANGLE_COS,STAR_FACE4_ANGLE_SIN,k)));
	float face_bwd0=dot(c_bwd,normalize(vec3(STAR_FACE0_ANGLE_COS,STAR_FACE0_ANGLE_SIN,-k)));
	float face_bwd1=dot(c_bwd,normalize(vec3(STAR_FACE1_ANGLE_COS,STAR_FACE1_ANGLE_SIN,-k)));
	float face_bwd2=dot(c_bwd,normalize(vec3(STAR_FACE2_ANGLE_COS,STAR_FACE2_ANGLE_SIN,-k)));
	float face_bwd3=dot(c_bwd,normalize(vec3(STAR_FACE3_ANGLE_COS,STAR_FACE3_ANGLE_SIN,-k)));
	float face_bwd4=dot(c_bwd,normalize(vec3(STAR_FACE4_ANGLE_COS,STAR_FACE4_ANGLE_SIN,-k)));
	float convex_fwd0=max(max(face_fwd0,face_fwd1),face_fwd4);
	float convex_fwd1=max(max(face_fwd1,face_fwd2),face_fwd3);
	float convex_fwd2=max(max(face_fwd2,face_fwd3),face_fwd4);
	float convex_bwd0=max(max(face_bwd0,face_bwd1),face_bwd4);
	float convex_bwd1=max(max(face_bwd1,face_bwd2),face_bwd3);
	float convex_bwd2=max(max(face_bwd2,face_bwd3),face_bwd4);
	return max(min(min(convex_fwd0,convex_fwd1),convex_fwd2),min(min(convex_bwd0,convex_bwd1),convex_bwd2)); }


sd_t sdf_rect(vec2 p,vec2 r) {
	vec2 d=abs(p)-r;
	return length(max(d,0))+min(max(d.x,d.y),0); }


sd_t sdf_rounded_rect(vec2 p,vec2 b,vec4 r) {
	r.xy=(p.x>0)?r.xy:r.zw;
	r.x=(p.y>0)?r.x:r.y;
	vec2 q=abs(p)-b+r.x;
	return min(max(q.x,q.y),0)+length(max(q,0))-r.x; }


sd_t sdf_oriented_rect(vec2 p,vec2 a,vec2 b,float h) {
	float l=length(b-a);
	vec2 d=(b-a)/l;
	vec2 q=(p-(a+b)*0.5);
	q=mat2(d.x,-d.y,d.y,d.x)*q;
	q=abs(q)-vec2(l,h)*0.5;
	return length(max(q,0))+min(max(q.x,q.y),0); }


sd_t sdf_segment(vec2 p,vec2 a,vec2 b) {
	vec2 pa=p-a;
	vec2 ba=b-a;
	float h=clamp(dot(pa,ba)/dot(ba,ba),0,1);
	return length(pa-ba*h); }


sd_t sdf_rhombus(vec2 p,vec2 b) {
	p=abs(p);
	float h=clamp(ndot(b-2*p,b)/dot(b,b),-1,1);
	float d=length(p-0.5*b*vec2(1-h,1+h));
	return d*sign(p.x*b.y+p.y*b.x-b.x*b.y); }


sd_t sdf_trapezoid(vec2 p,float r1,float r2,float he) {
	vec2 k1=vec2(r2,he);
	vec2 k2=vec2(r2-r1,2*he);
	p.x=abs(p.x);
	vec2 ca=vec2(p.x-min(p.x,(p.y<0)?r1:r2),abs(p.y)-he);
	vec2 cb=p-k1+k2*clamp(dot(k1-p,k2)/dot2(k2),0,1);
	float s=(cb.x<0&&ca.y<0)?-1:1;
	return s*sqrt(min(dot2(ca),dot2(cb))); }


sd_t sdf_parallelogram(vec2 p,float wi,float he,float sk) {
	vec2 e=vec2(sk,he);
	p=(p.y<0)?-p:p;
	vec2 w=p-e; w.x-=clamp(w.x,-wi,wi);
	vec2 d=vec2(dot(w,w),-w.y);
	float s=p.x*e.y-p.y*e.x;
	p=(s<0)?-p:p;
	vec2 v=p-vec2(wi,0); v-=e*clamp(dot(v,e)/dot(e,e),-1,1);
	d=min(d,vec2(dot(v,v),wi*he-abs(s)));
	return sqrt(d.x)*sign(-d.y); }


sd_t sdf_equilateral_triangle(vec2 p,float r) {
	const float k=sqrt(3);
	p.x=abs(p.x)-r;
	p.y=p.y+r/k;
	if(p.x+k*p.y>0) { p=vec2(p.x-k*p.y,-k*p.x-p.y)/2; }
	p.x-=clamp(p.x,-2*r,0);
	return -length(p)*sign(p.y); }


sd_t sdf_isosceles_triangle(vec2 p,vec2 q) {
	p.x=abs(p.x);
	vec2 a=p-q*clamp(dot(p,q)/dot(q,q),0,1);
	vec2 b=p-q*vec2(clamp(p.x/q.x,0,1),1);
	float s=-sign(q.y);
	vec2 d=min(vec2(dot(a,a),s*(p.x*q.y-p.y*q.x)),vec2(dot(b,b),s*(p.y-q.y)));
	return -sqrt(d.x)*sign(d.y); }


sd_t sdf_triangle(vec2 p,vec2 p0,vec2 p1,vec2 p2) {
	vec2 e0=p1-p0;
	vec2 e1=p2-p1;
	vec2 e2=p0-p2;
	vec2 v0=p-p0;
	vec2 v1=p-p1;
	vec2 v2=p-p2;
	vec2 pq0=v0-e0*clamp(dot(v0,e0)/dot(e0,e0),0,1);
	vec2 pq1=v1-e1*clamp(dot(v1,e1)/dot(e1,e1),0,1);
	vec2 pq2=v2-e2*clamp(dot(v2,e2)/dot(e2,e2),0,1);
	float s=sign(e0.x*e2.y-e0.y*e2.x);
	vec2 d=min(min(vec2(dot(pq0,pq0),s*(v0.x*e0.y-v0.y*e0.x)),vec2(dot(pq1,pq1),s*(v1.x*e1.y-v1.y*e1.x))),vec2(dot(pq2,pq2),s*(v2.x*e2.y-v2.y*e2.x)));
	return -sqrt(d.x)*sign(d.y); }


sd_t sdf_uneven_capsule(vec2 p,float r1,float r2,float h) {
	p.x=abs(p.x);
	float b=(r1-r2)/h;
	float a=sqrt(1-b*b);
	float k=dot(p,vec2(-b,a));
	if(k<0) { return length(p)-r1; }
	if(k>a*h) { return length(p-vec2(0,h))-r2; }
	return dot(p,vec2(a,b))-r1; }


sd_t sdf_pentagon(vec2 p,float r) {
	const vec3 k=vec3(0.809016994,0.587785252,0.726542528);
	p.x=abs(p.x);
	p-=2*min(dot(vec2(-k.x,k.y),p),0)*vec2(-k.x,k.y);
	p-=2*min(dot(vec2(k.x,k.y),p),0)*vec2(k.x,k.y);
	p-=vec2(clamp(p.x,-r*k.z,r*k.z),r);
	return length(p)*sign(p.y); }


sd_t sdf_hexagon(vec2 p,float r) {
	const vec3 k=vec3(-0.866025404,0.5,0.577350269);
	p=abs(p);
	p-=2*min(dot(k.xy,p),0)*k.xy;
	p-=vec2(clamp(p.x,-k.z*r,k.z*r),r);
	return length(p)*sign(p.y); }


sd_t sdf_octagon(vec2 p,float r) {
	const vec3 k=vec3(-0.9238795325,0.3826834323,0.4142135623 );
	p=abs(p);
	p-=2*min(dot(vec2(k.x,k.y),p),0)*vec2(k.x,k.y);
	p-=2*min(dot(vec2(-k.x,k.y),p),0)*vec2(-k.x,k.y);
	p-=vec2(clamp(p.x,-k.z*r,k.z*r),r);
	return length(p)*sign(p.y); }


sd_t sdf_hexagram(vec2 p,float r) {
	const vec4 k=vec4(-0.5,0.8660254038,0.5773502692,1.7320508076);
	p=abs(p);
	p-=2*min(dot(k.xy,p),0)*k.xy;
	p-=2*min(dot(k.yx,p),0)*k.yx;
	p-=vec2(clamp(p.x,r*k.z,r*k.w),r);
	return length(p)*sign(p.y); }


sd_t sdf_star5(vec2 p,float r,float rf) {
	const vec2 k1=vec2(0.809016994375,-0.587785252292);
	const vec2 k2=vec2(-k1.x,k1.y);
	p.x=abs(p.x);
	p-=2*max(dot(k1,p),0)*k1;
	p-=2*max(dot(k2,p),0)*k2;
	p.x=abs(p.x);
	p.y-=r;
	vec2 ba=rf*vec2(-k1.y,k1.x)-vec2(0,1);
	float h=clamp(dot(p,ba)/dot(ba,ba),0,r);
	return length(p-ba*h)*sign(p.y*ba.x-p.x*ba.y); }


sd_t sdf_star(vec2 p,float r,int n,float m) {
	float an=PI/float(n);
	float en=PI/m;
	vec2  acs=vec2(cos(an),sin(an));
	vec2  ecs=vec2(cos(en),sin(en));
	float bn=mod(atan(p.x,p.y),2*an)-an;
	p=length(p)*vec2(cos(bn),abs(sin(bn)));
	p-=r*acs;
	p+=ecs*clamp(-dot(p,ecs),0,r*acs.y/ecs.y);
	return length(p)*sign(p.x); }


sd_t sdf_pie(vec2 p,vec2 c,float r) {
	p.x=abs(p.x);
	float l=length(p)-r;
	float m=length(p-c*clamp(dot(p,c),0,r));
	return max(l,m*sign(c.y*p.x-c.x*p.y)); }


sd_t sdf_cut_disk(vec2 p,float r,float h) {
	float w=sqrt(r*r-h*h);
	p.x=abs(p.x);
	float s=max((h-r)*p.x*p.x+w*w*(h+r-2.0*p.y),h*p.x-w*p.y);
	return (s<0)?length(p)-r:(p.x<w)?h-p.y:length(p-vec2(w,h)); }


sd_t sdf_arc(vec2 p,vec2 n,float r,float th) {
    p.x=abs(p.x);
    p=mat2(n.x,n.y,-n.y,n.x)*p;
    return max(abs(length(p)-r)-th*0.5,length(vec2(p.x,max(0.0,abs(r-p.y)-th*0.5)))*sign(p.x)); }


sd_t sdf_ring(vec2 p,vec2 n,float r,float th) {
	p.x=abs(p.x);
	p=mat2x2(n.x,n.y,-n.y,n.x)*p;
	return max(abs(length(p)-r)-th*0.5,length(vec2(p.x,max(0,abs(r-p.y)-th*0.5)))*sign(p.x)); }


sd_t sdf_horseshoe(vec2 p,vec2 c,float r,vec2 w) {
	p.x=abs(p.x);
	float l=length(p);
	p=mat2(-c.x,c.y,c.y,c.x)*p;
	p=vec2((p.y>0||p.x>0)?p.x:l*sign(-c.x),(p.x>0)?p.y:l);
	p=vec2(p.x,abs(p.y-r))-w;
	return length(max(p,0))+min(0,max(p.x,p.y)); }


sd_t sdf_vesica(vec2 p,float r,float d) {
	p=abs(p);
	float b=sqrt(r*r-d*d);
	return ((p.y-b)*d>p.x*b)?length(p-vec2(0,b)):length(p-vec2(-d,0))-r; }


sd_t sdf_oriented_vesica(vec2 p,vec2 a,vec2 b,float w) {
	float r=0.5*length(b-a);
	float d=0.5*(r*r-w*w)/w;
	vec2 v=(b-a)/r;
	vec2 c=(b+a)*0.5;
	vec2 q=0.5*abs(mat2(v.y,v.x,-v.x,v.y)*(p-c));
	vec3 h=(r*q.x<d*(q.y-r))?vec3(0,r,0):vec3(-d,0,d+w);
	return length(q-h.xy)-h.z; }


sd_t sdf_moon(vec2 p,float d,float ra,float rb) {
	p.y=abs(p.y);
	float a=(ra*ra-rb*rb+d*d)/(2*d);
	float b=sqrt(max(ra*ra-a*a,0));
	if(d*(p.x*b-p.y*a)>d*d*max(b-p.y,0)) { return length(p-vec2(a,b)); }
	return max((length(p)-ra),-(length(p-vec2(d,0))-rb)); }


sd_t sdf_rounded_cross(vec2 p,float h) {
	float k=0.5*(h+1.0/h);
	p=abs(p);
	return (p.x<1&&p.y<p.x*(k-h)+h )?k-sqrt(dot2(p-vec2(1,k))):sqrt(min(dot2(p-vec2(0,h)),dot2(p-vec2(1,0)))); }


sd_t sdf_egg(vec2 p,float ra,float rb) {
	const float k=sqrt(3.0);
	p.x=abs(p.x);
	float r=ra-rb;
	return ((p.y<0)?length(vec2(p.x,p.y))-r:(k*(p.x+r)<p.y)?length(vec2(p.x,p.y-k*r)):length(vec2(p.x+r,p.y))-2*r)-rb; }


sd_t sdf_heart(vec2 p) {
	p.x=abs(p.x);
	if(p.y+p.x>1) { return sqrt(dot2(p-vec2(0.25,0.75)))-sqrt(2.0)/4.0; }
	return sqrt(min(dot2(p-vec2(0,1)),dot2(p-0.5*max(p.x+p.y,0))))*sign(p.x-p.y); }


sd_t sdf_cross(vec2 p,vec2 b,float r) {
	p=abs(p);
	p=(p.y>p.x)?p.yx:p.xy;
	vec2 q=p-b;
	float k=max(q.y,q.x);
	vec2 w=(k>0)?q:vec2(b.y-p.x,-k);
	return sign(k)*length(max(w,0.0))+r; }


sd_t sdf_rounded_X(vec2 p,float w,float r) {
	p=abs(p);
	return length(p-min(p.x+p.y,w)*0.5)-r; }


#define SDF_FUNC_POLYGON_POINTS(func_name,n_points) sd_t func_name(vec2 p,vec2 v[n_points]) {\
	float d=dot(p-v[0],p-v[0]);\
	float s=1;\
	for(int i=0, j=n_points-1; i<n_points; j=i, i++) {\
		vec2 e=v[j]-v[i];\
		vec2 w=p-v[i];\
		vec2 b=w-e*clamp(dot(w,e)/dot(e,e),0,1);\
		d=min(d,dot(b,b));\
		bvec3 c=bvec3(p.y>=v[i].y,p.y<v[j].y,e.x*w.y>e.y*w.x);\
		if(all(c)||all(not(c))) { s*=-1; } }\
	return s*sqrt(d); }


SDF_FUNC_POLYGON_POINTS(sdf_polygon_4,4)


sd_t sdf_ellipse(vec2 p,vec2 ab) {
	p=abs(p);
	if(p.x>p.y) {
		p=p.yx;
		ab=ab.yx; }
	float l=ab.y*ab.y-ab.x*ab.x;
	float m=ab.x*p.x/l;
	float m2=m*m;
	float n=ab.y*p.y/l;
	float n2=n*n;
	float c=(m2+n2-1)/3;
	float c3=c*c*c;
	float q=c3+m2*n2*2;
	float d=c3+m2*n2;
	float g=m+m*n2;
	float co;
	if(d<0) {
		float h=acos(q/c3)/3;
		float s=cos(h);
		float t=sin(h)*sqrt(3.0);
		float rx=sqrt(-c*(s+t+2)+m2);
		float ry=sqrt(-c*(s-t+2)+m2);
		co=(ry+sign(l)*rx+abs(g)/(rx*ry)- m)/2; }
	else {
		float h=2*m*n*sqrt(d);
		float s=sign(q+h)*pow(abs(q+h),1.0/3);
		float u=sign(q-h)*pow(abs(q-h),1.0/3);
		float rx=-s-u-c*4+2*m2;
		float ry=(s-u)*sqrt(3.0);
		float rm=sqrt(rx*rx+ry*ry);
		co=(ry/sqrt(rm-rx)+2*g/rm-m)/2; }
	vec2 r=ab*vec2(co,sqrt(1-co*co));
	return length(r-p)*sign(p.y-r.y); }


sd_t sdf_parabola(vec2 pos,float k) {
	pos.x=abs(pos.x);
	float ik=1.0/k;
	float p=ik*(pos.y-0.5*ik)/3;
	float q=0.25*ik*ik*pos.x;
	float h=q*q-p*p*p;
	float r=sqrt(abs(h));
	float x=(h>0)?pow(q+r,1.0/3)-pow(abs(q-r),1.0/3)*sign(r-q):2*cos(atan(r,q)/3)*sqrt(p);
	return length(pos-vec2(x,k*x*x))*sign(pos.x-x); }


sd_t sdf_parabola_segment(vec2 pos,float wi,float he) {
	pos.x=abs(pos.x);
	float ik=wi*wi/he;
	float p=ik*(he-pos.y-0.5*ik)/3;
	float q=pos.x*ik*ik*0.25;
	float h=q*q-p*p*p;
	float r=sqrt(abs(h));
	float x=(h>0)?pow(q+r,1.0/3)-pow(abs(q-r),1.0/3)*sign(r-q):2*cos(atan(r/q)/3)*sqrt(p);
	x=min(x,wi);
	return length(pos-vec2(x,he-x*x/ik))*sign(ik*(pos.y-he)+pos.x*pos.x); }


sd_t sdf_bezier(vec2 pos,vec2 A,vec2 B,vec2 C) {
	vec2 a=B-A;
	vec2 b=A-2*B+C;
	vec2 c=a*2;
	vec2 d=A-pos;
	float kk=1.0/dot(b,b);
	float kx=kk*dot(a,b);
	float ky=kk*(2*dot(a,a)+dot(d,b))/3;
	float kz=kk*dot(d,a);
	float res=0;
	float p=ky-kx*kx;
	float p3=p*p*p;
	float q=kx*(2*kx*kx-3*ky)+kz;
	float h=q*q+4*p3;
	if(h>=0) {
		h=sqrt(h);
		vec2 x=(vec2(h,-h)-q)/2;
		vec2 uv=sign(x)*pow(abs(x),vec2(1.0/3));
		float t=clamp(uv.x+uv.y-kx,0,1);
		res=dot2(d+(c+b*t)*t); }
	else {
		float z=sqrt(-p);
		float v=acos(q/(p*z*2))/3;
		float m=cos(v);
		float n=sin(v)*1.732050808;
		vec3 t=clamp(vec3(m+m,-n-m,n-m)*z-kx,0,1);
		res=min(dot2(d+(c+b*t.x)*t.x),dot2(d+(c+b*t.y)*t.y)); }
	return sqrt(res); }


sd_t sdf_blobby_cross(vec2 pos,float he) {
	pos=abs(pos);
	pos=vec2(abs(pos.x-pos.y),1-pos.x-pos.y)/sqrt(2.0);
	float p=(he-pos.y-0.25/he)/(6*he);
	float q=pos.x/(he*he*16);
	float h=q*q-p*p*p;
	float x;
	if(h>0) {
		float r=sqrt(h);
		x=pow(q+r,1.0/3)-pow(abs(q-r),1.0/3)*sign(r-q); }
	else { float r=sqrt(p);
		x=2*r*cos(acos(q/(p*r))/3); }
	x=min(x,sqrt(2.0)/2);
	vec2 z=vec2(x,he*(1-2*x*x))-pos;
	return length(z)*sign(z.y); }


sd_t sdf_doorway(vec2 p,vec2 wh) {
	p.x=abs(p.x);
	p.y=-p.y;
	vec2 q=p-wh;
	float d1=dot2(vec2(max(q.x,0),q.y));
	q.x=(p.y>0)?q.x:length(p)-wh.x;
	float d2=dot2(vec2(q.x,max(q.y,0)));
	float d=sqrt(min(d1,d2));
	return (max(q.x,q.y)<0)?-d:d; }


sd_t sdf_quadratic_circle(vec2 p) {
	p=abs(p);
	if(p.y>p.x) { p=p.yx; }
	float a=p.x-p.y;
	float b=p.x+p.y;
	float c=(2*b-1)/3;
	float h=a*a+c*c*c;
	float t;
	if(h>=0) {
		h=sqrt(h);
		t=sign(h-a)*pow(abs(h-a),1.0/3)-pow(h+a,1.0/3); }
	else {
		float z=sqrt(-c);
		float v=acos(a/(c*z))/3;
		t=-z*(cos(v)+sin(v)*1.732050808); }
	t*=0.5;
	vec2 w=vec2(-t,t)+0.75-t*t-p;
	return length(w)*sign(a*a*0.5+b-1.5); }


sd_t sdf_circle_wave(vec2 p,float tb,float ra) {
	tb=3.1415927*5/6*max(tb,0.0001);
	vec2 co=ra*vec2(sin(tb),cos(tb));
	p.x=abs(mod(p.x,co.x*4)-co.x*2);
	vec2 p1=p;
	vec2 p2=vec2(abs(p.x-2*co.x),-p.y+2*co.y);
	float d1=((co.y*p1.x>co.x*p1.y)?length(p1-co):abs(length(p1)-ra));
	float d2=((co.y*p2.x>co.x*p2.y)?length(p2-co):abs(length(p2)-ra));
	return min(d1,d2); }


sd_t sdf_slanted_box_east(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n=normalize(vec3(sin(s+HALF_PI),0,cos(s+HALF_PI)));
	return max(dot(p+vec3(-r.x,0,-r.z),n),length(max(o,0.0))); }


sd_t sdf_slanted_box_west(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n=normalize(vec3(-sin(s+HALF_PI),0,cos(s+HALF_PI)));
	return max(dot(p+vec3(r.x,0,-r.z),n),length(max(o,0.0))); }


sd_t sdf_slanted_box_north(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n=normalize(vec3(0,sin(s+HALF_PI),cos(s+HALF_PI)));
	return max(dot(p+vec3(0,-r.y,-r.z),n),length(max(o,0.0))); }


sd_t sdf_slanted_box_south(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n=normalize(vec3(0,-cos(s),-sin(s)));
	return max(dot(p+vec3(0,r.y,-r.z),n),length(max(o,0.0))); }


sd_t sdf_doubly_slanted_box_east_west(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n1=normalize(vec3(sin(s+HALF_PI),0,cos(s+HALF_PI)));
	vec3 n2=normalize(vec3(-sin(s+HALF_PI),0,cos(s+HALF_PI)));
	return max(dot(p+vec3(-r.x,0,-r.z),n1),
	           max(dot(p+vec3(r.x,0,-r.z),n2),
	           length(max(o,0)))); }


sd_t sdf_doubly_slanted_box_north_south(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	vec3 n1=normalize(vec3(0,sin(s+HALF_PI),cos(s+HALF_PI)));
	vec3 n2=normalize(vec3(0,-cos(s),-sin(s)));
	return max(dot(p+vec3(0,-r.y,-r.z),n1),
	           max(dot(p+vec3(0,r.y,-r.z),n2),
	           length(max(o,0)))); }


sd_t sdf_trap_box_east_west(vec3 p,vec3 r,float s,float c) {
	vec3 o=abs(p)-r;
	float a=s+HALF_PI;
	vec3 n1=normalize(vec3(sin(a),0,cos(a)));
	vec3 n2=normalize(vec3(-sin(a),0,cos(a)));
	vec3 n3=vec3(0,0,-1);
	return max(max(dot(p+vec3(-r.x,0,-r.z),n1),
	               max(dot(p+vec3(r.x,0,-r.z),n2),
	               length(max(o,0)))),
	           dot(p,n3)+c*r.z); }


sd_t sdf_trap_box_west_east(vec3 p,vec3 r,float s,float c) {
	vec3 o=abs(p)-r;
	float a=HALF_PI-s;
	vec3 n1=normalize(vec3(sin(a),0,cos(a)));
	vec3 n2=normalize(vec3(-sin(a),0,cos(a)));
	vec3 n3=vec3(0,0,1);
	return max(max(dot(p+vec3(-r.x,0,r.z),n1),
	               max(dot(p+vec3(r.x,0,r.z),n2),
	               length(max(o,0)))),
	           dot(p,n3)+c*r.z); }


sd_t sdf_skewed_box_east_west(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	float a=s+HALF_PI;
	vec3 n1=normalize(vec3(sin(a),0,cos(a)));
	a=s-HALF_PI;
	vec3 n2=normalize(vec3(sin(a),0,cos(a)));
	return max(dot(p+vec3(-r.x,0,-r.z),n1),
	           max(dot(p+vec3(r.x,0,r.z),n2),
	           length(max(o,0)))); }


sd_t sdf_skewed_box_west_east(vec3 p,vec3 r,float s) {
	vec3 o=abs(p)-r;
	float a=HALF_PI-s;
	vec3 n1=normalize(vec3(sin(a),0,cos(a)));
	a=PI+HALF_PI-s;
	vec3 n2=normalize(vec3(sin(a),0,cos(a)));
	return max(dot(p+vec3(-r.x,0,r.z),n1),
	           max(dot(p+vec3(r.x,0,-r.z),n2),
	           length(max(o,0)))); }


sd_t sdf_tri_prism(vec3 p,vec2 h) {
	vec3 q=abs(p);
	return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5); }


sd_t sdf_quad(vec3 p,vec3 A,vec3 B,vec3 C,vec3 D) {
	vec3 ba=B-A;
	vec3 pa=p-A;
	vec3 cb=C-B;
	vec3 pb=p-B;
	vec3 dc=D-C;
	vec3 pc=p-C;
	vec3 ad=A-D;
	vec3 pd=p-D;
	vec3 nor=cross(ba,ad);
	return sqrt(
		(sign(dot(cross(ba,nor),pa))+
		sign(dot(cross(cb,nor),pb))+
		sign(dot(cross(dc,nor),pc))+
		sign(dot(cross(ad,nor),pd))<3)
		?
		min(min(min(
		dot2(ba*clamp(dot(ba,pa)/dot2(ba),0,1)-pa),
		dot2(cb*clamp(dot(cb,pb)/dot2(cb),0,1)-pb)),
		dot2(dc*clamp(dot(dc,pc)/dot2(dc),0,1)-pc)),
		dot2(ad*clamp(dot(ad,pd)/dot2(ad),0,1)-pd))
		:
		dot(nor,pa)*dot(nor,pa)/dot2(nor)); }


sd_t sdf_wedge_x(vec3 p,vec3 n) {
	n=normalize(n);
	return dot(vec3(abs(p.x),p.yz),n); }


sd_t sdf_wedge_y(vec3 p,vec3 n) {
	n=normalize(n);
	return dot(vec3(p.x,abs(p.y),p.z),n); }


sd_t sdf_wedge_z(vec3 p,vec3 n) {
	n=normalize(n);
	return dot(vec3(p.xy,abs(p.z)),n); }








float posterize(float t,int n) {
	return round(n*t)/n; }
vec3 posterize(vec3 c,int n) {
	return vec3(round(n*c.x)/n,round(n*c.y)/n,round(n*c.z)/n); }
vec3 saturation(vec3 rgb,float adjustment) {
	const vec3 w=vec3(0.2125,0.7154,0.0721);
	vec3 intensity=vec3(dot(rgb,w));
	return mix(intensity,rgb,adjustment); }








vec2 substance_uv = vec2(0,0);
vec2 substance_res = vec2(0,0);
vec3 blend_switch(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_2,t); }
vec3 blend_add(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1+image_2,t); }
vec3 blend_sub(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1-image_2,t); }
vec3 blend_multiply(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1*image_2,t); }
vec3 blend_div(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1/image_2,t); }
vec3 blend_max(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,max(image_1,image_2),t); }
vec3 blend_min(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,min(image_1,image_2),t); }
vec3 blend_screen(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,vec3(1)-(vec3(1)-image_1)*(vec3(1)-image_2),t); }
vec3 blend_overlay(vec3 image_1,vec3 image_2,float t) {
	return mix(blend_multiply(image_1,image_2,t),blend_screen(image_1,image_2,t),t); }



const color_t LIGHT_COLOR=color_t(float(255)/255,float(236)/255,float(214)/255);
const color_t SHADOW_COLOR=color_t(float(39)/255,float(31)/255,float(86)/255);


float attenuation_from_distance(float distance,float attenuation_coefficient) {
	return pow(float(10),-float(distance*attenuation_coefficient)); }
color_t view_specular_of_surface(ray_t surface,vec3 view_point,vec3 light_source,float exponent) {
	return LIGHT(pow(max(dot(normalize(ray_position(surface)-view_point),normalize(reflect(normalize(ray_position(surface)-light_source),ray_direction(surface)))),0),exponent))*exponent; }
color_t diffuse_of_surface(ray_t surface,vec3 light_source,color_t surface_color) {
	return surface_color*max(dot(ray_direction(surface),normalize(ray_direction(surface)-light_source)),0); }
color_t view_diffuse_of_surface(ray_t surface,vec3 view_point,vec3 light_source,color_t surface_color,float attenuation_coefficient) {
	return attenuation_from_distance(length(view_point-light_source),attenuation_coefficient)*surface_color*max(dot(ray_direction(surface),ray_direction(surface)-light_source),0); }
color_t view_phong_of_surface(ray_t surface,vec3 view_point,LIGHT ambient_light,color_t surface_color,vec3 light_source,float exponent) {
	return diffuse_of_surface(surface,light_source,surface_color)+surface_color*ambient_light+view_specular_of_surface(surface,view_point,light_source,exponent); }
color_t view_partial_phong_of_surface(ray_t surface,vec3 view_point,color_t surface_color,vec3 light_source,float exponent) {
	return diffuse_of_surface(surface,light_source,surface_color)+view_specular_of_surface(surface,view_point,light_source,exponent); }



float hash2(vec2 p) {
	float h = dot(p,vec2(127.1,311.7));
    return fract(sin(h)*43758.5453123); }
float noise(in vec2 p) {
	// Use texture instead. //
    vec2 i = floor( p );
    vec2 f = fract( p );
	vec2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*mix( mix( hash2( i + vec2(0.0,0.0) ),
                     hash2( i + vec2(1.0,0.0) ), u.x),
                mix( hash2( i + vec2(0.0,1.0) ),
                     hash2( i + vec2(1.0,1.0) ), u.x), u.y); }


float hash(float h) {
	return fract(sin(h) * 43758.5453123);
}

float noise3(vec3 x) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	float n = p.x + p.y * 157.0 + 113.0 * p.z;
	return mix(
			mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
					mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
			mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
					mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}


float fbm(vec3 p) {
	float f1=0.5*noise3(p);
	p*=4.0;
	float f2=0.5*noise3(p);
	p*=2.0;
	float f3=0.25*noise3(p);
	return f1+(f2-0.25)+(f3-0.125);
	return f1+(f2-0.25); }


sd_t sdf_foam(vec3 p,sd_t bounds,vec3 motion,float fade_r) {
	sd_t d;
	const float s=0.4;
	const float min_density=-0.3;
	const float max_density=2*pow(s,2);
	// const float max_density=0.1;
	float t=mix(min_density,max_density,flat_step(0,fade_r,-bounds));
	// t=min_density;
	d=(fbm((p-time*motion)/s)-t)*s;
	return sdf_sect(d,bounds); }





const int ITER_GEOMETRY = 3;
const int ITER_FRAGMENT = 1;
const float SEA_HEIGHT = 0.6;
const float SEA_SHARPNESS = 0.5;
const float SEA_CHOPPY = 4.0;
const float SEA_SPEED = 0.2;
const float SEA_FREQ = 0.16;
float SEA_TIME=1.0+time*SEA_SPEED;
const mat2 octave_m = mat2(1.6,1.2,-1.2,1.6);


float sea_octave(vec2 uv,float sharpness,float choppy) {
	uv+=2*noise(uv-vec2(4*SEA_TIME,2*sin(SEA_TIME)));
	// uv+=4*noise(mix(uv+3*time,uv+5*time,fract(time)));
	uv=sin(2.0*uv)*0.5+0.5;
	float h=min(uv.x,uv.y);
	// float h=uv.x*uv.y;
	// float h=mix(uv.x*uv.y,min(uv.x,uv.y),max(uv.x,uv.y));
	return pow(1.0-pow(h,1.0-SEA_SHARPNESS),choppy); }


float map(vec2 uv) {
    float freq = SEA_FREQ;
    float amp = SEA_HEIGHT;
    float choppy = SEA_CHOPPY;
    uv.x *= 0.75;

    float d, h = 0.0;
    for(int i = 0; i < ITER_GEOMETRY; i++) {
    	d = sea_octave((uv+SEA_TIME)*freq,SEA_SHARPNESS,choppy);
    	d += sea_octave((uv-SEA_TIME)*freq,SEA_SHARPNESS,choppy);
        h += d * amp;
    	uv *= octave_m; freq *= 1.9; amp *= 0.22;
        choppy = mix(choppy,1.0,0.2);
    }
    return h; }


const color_t FOAM_COLOR=color_t(232,244,248)/255;
const color_t SHALLOW_SEA_COLOR=color_t(146,174,230)/255;
const color_t DEEP_SEA_COLOR=color_t(95,124,182)/255;


color_t shade_water(ray_t surface,bool occlusion) {
	// color_t color=(1-int(occlusion))*color_t(1);
	// color_t color=(1-int(occlusion))*;
	float t=clamp(dot(vec3(0,0,1),ray_direction(surface)),0,1);
	color_t color=mix(
		color_t(float(146)/255,float(174)/255,float(230)/255),
		color_t(float(95)/255,float(124)/255,float(182)/255),
		t);
	color=blend_multiply(color,SHADOW_COLOR,0.5*int(occlusion));
	// color*=view_partial_phong_of_surface(surface,surface[0],vec3(1),-1000*sun_dir,16);
	// return mix(color_t(0),color_t(1),0.5*(map(ray_position(surface).xzy)+1));
	// return mix(color_t(0),color_t(1),0.5*(noise(ray_position(surface).xy)+1));
	// color+=sea_octave(ray_position(surface).xy,SEA_SHARPNESS,SEA_CHOPPY);
	float foam_t=float(sea_octave(ray_position(surface).xy,SEA_SHARPNESS,SEA_CHOPPY)>0.9);
	color=mix(color,FOAM_COLOR,foam_t);
	return color; }
	// return posterize(color,4); }


color_t shade_foam(ray_t surface,bool occlusion) {
	float t=(1-diffuse_of_surface(surface,-1000*sun_dir,vec3(1))).x;
	return mix(FOAM_COLOR,SHALLOW_SEA_COLOR,0.2*t); }
	// return blend_switch(FOAM_COLOR,SHADOW_COLOR,0.2*); }
	// return blend_switch(FOAM_COLOR,SHADOW_COLOR,1.0*(1-view_partial_phong_of_surface(surface,surface[0],vec3(1),-1000*sun_dir,1).x)); }


color_t shade_sand(ray_t surface,bool occlusion) {
	return color_t(float(213)/255,float(192)/255,float(187)/255); }


color_t shade_rock(ray_t surface,bool occlusion) {
	return color_t(float(86)/255,float(92)/255,float(125)/255); }


color_t shade_surf(ray_t surface,bool occlusion) {
	return color_t(float(209)/255,float(167)/255,float(213)/255); }


color_t shade_skin(ray_t surface,bool occlusion) {
	return color_t(float(221)/255,float(211)/255,float(202)/255); }










/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                        S P E C I A L                                        |
  |_____________________________________________________________________________________________|*/


#define csdf_flux(csdf,p) (\
	csdf(p+vec3(EPSILON,0,0))+\
	csdf(p+vec3(-EPSILON,0,0))+\
	csdf(p+vec3(0,EPSILON,0))+\
	csdf(p+vec3(0,-EPSILON,0))+\
	csdf(p+vec3(0,0,EPSILON))+\
	csdf(p+vec3(0,0,-EPSILON)))








/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                      O P E R A T O R S                                      |
  |_____________________________________________________________________________________________|*/


float csdf_material_nearest(csd_t a,csd_t b) {
	if (csd_distance(a)<=csd_distance(b)) {
		return csd_material(a); }
	else {
		return csd_material(b); } }


csd_t csdf_sect(csd_t a,csd_t b) {
	csd_t d;
	csd_distance(d)=sdf_sect(csd_distance(a),csd_distance(b));
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_smooth_sect(csd_t a,csd_t b,float k) {
	csd_t d;
	csd_distance(d)=sdf_smooth_sect(csd_distance(a),csd_distance(b),k);
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_union(csd_t a,csd_t b) {
	csd_t d;
	csd_distance(d)=sdf_union(csd_distance(a),csd_distance(b));
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_smooth_union(csd_t a,csd_t b,float k) {
	csd_t d;
	csd_distance(d)=sdf_smooth_union(csd_distance(a),csd_distance(b),k);
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_diff(csd_t a,csd_t b) {
	csd_t d;
	csd_distance(d)=sdf_diff(csd_distance(a),csd_distance(b));
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_smooth_diff(csd_t b,csd_t a,float k) {
	csd_t d;
	csd_distance(d)=sdf_smooth_diff(csd_distance(a),csd_distance(b),k);
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_xor(csd_t a,csd_t b) {
	csd_t d;
	csd_distance(d)=sdf_xor(csd_distance(a),csd_distance(b));
	csd_material(d)=csdf_material_nearest(a,b);
	return d; }


csd_t csdf_fill(csd_t a,mat_t m) {
	csd_t d;
	csd_distance(d)=csd_distance(a);
	csd_material(d)=m;
	return d; }


csd_t csdf_round(csd_t a,float r) {
	csd_t d;
	csd_distance(d)=sdf_round(csd_distance(a),r);
	csd_material(d)=csd_material(a);
	return d; }


csd_t csdf_onion(csd_t a,float r) {
	csd_t d;
	csd_distance(d)=sdf_onion(csd_distance(a),r);
	csd_material(d)=csd_material(a);
	return d; }


#define csdf_scale(f,p,s) (f((p)/(s))*(s))


csd_t csdf_displace(csd_t a,float h,float r) {
	csd_t d;
	csd_distance(d)=sdf_displace(csd_distance(a),h,r);
	csd_material(d)=csd_material(a);
	return d; }








/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                    P R I M I T I V E S                                      |
  |_____________________________________________________________________________________________|*/


csd_t csdf_plane(vec3 p,vec3 n,float h,mat_t m) {
	return csd_t(sdf_plane(p,n,h),m); }


csd_t csdf_sphere(vec3 p,float r,mat_t m) {
	return csd_t(sdf_sphere(p,r),m); }


csd_t csdf_capsule_x(vec3 p,float r,float l,mat_t m) {
	return csd_t(sdf_capsule_x(p,r,l),m); }


csd_t csdf_capsule_y(vec3 p,float r,float l,mat_t m) {
	return csd_t(sdf_capsule_y(p,r,l),m); }


csd_t csdf_capsule_z(vec3 p,float r,float l,mat_t m) {
	return csd_t(sdf_capsule_z(p,r,l),m); }


csd_t csdf_capsule(vec3 p,vec3 a,vec3 b,float r,mat_t m) {
	return csd_t(sdf_capsule(p,a,b,r),m); }


csd_t csdf_box(vec3 p,vec3 b,mat_t m) {
	return csd_t(sdf_box(p,b),m); }


csd_t csdf_box_frame(vec3 p,vec3 b,float t,mat_t m) {
	return csd_t(sdf_box_frame(p,b,t),m); }


csd_t csdf_directed_box(vec3 p,vec3 b,vec3 x,vec3 cx,mat_t m) {
	return csd_t(sdf_directed_box(p,b,x,cx),m); }


csd_t csdf_sliced_box(vec3 p,vec3 b,vec3 n,float h,mat_t m) {
	return csd_t(sdf_sliced_box(p,b,n,h),m); }


csd_t csdf_nicked_box(vec3 p,vec3 b,float h,mat_t m) {
	return csd_t(sdf_nicked_box(p,b,h),m); }


csd_t csdf_chiselled_box(vec3 p,vec3 b,float h,mat_t m) {
	return csd_t(sdf_chiselled_box(p,b,h),m); }


csd_t csdf_rounded_box(vec3 p,vec3 b,float r,mat_t m) {
	return csd_t(sdf_rounded_box(p,b,r),m); }


csd_t csdf_torus(vec3 p,vec2 b,float s,mat_t m) {
	return csd_t(sdf_torus(p,b),m); }


csd_t csdf_directed_torus(vec3 p,vec2 b,vec3 n,float s,mat_t m) {
	return csd_t(sdf_directed_torus(p,b,n),m); }


csd_t csdf_cylinder_x(vec3 p,float h,float r,mat_t m) {
	return csd_t(sdf_cylinder_x(p,h,r),m); }


csd_t csdf_cylinder_y(vec3 p,float h,float r,mat_t m) {
	return csd_t(sdf_cylinder_y(p,h,r),m); }


csd_t csdf_cylinder_z(vec3 p,float h,float r,mat_t m) {
	return csd_t(sdf_cylinder_z(p,h,r),m); }


csd_t csdf_cone_x(vec3 p,vec2 b,float h,mat_t m) {
	return csd_t(sdf_cone_x(p,b,h),m); }


csd_t csdf_cone_y(vec3 p,vec2 b,float h,mat_t m) {
	return csd_t(sdf_cone_y(p,b,h),m); }


csd_t csdf_cone_z(vec3 p,vec2 b,float h,mat_t m) {
	return csd_t(sdf_cone_z(p,b,h),m); }


csd_t csdf_directed_cone(vec3 p,vec2 b,vec3 n,float h,mat_t m) {
	return csd_t(sdf_directed_cone(p,b,n,h),m); }


csd_t csdf_prism(vec3 p,float r,float h,int order,mat_t m) {
	float d=SDF_CLEAR;
	for(int n=0; n<order; n+=1) {
		float angle=float(n)/float(order)*TWO_PI;
		vec3 delta=vec3(angle_vec(angle),0);
		d=sdf_union(d,sdf_plane(p,delta,r)); }
	d=-d;
	d=sdf_diff(d,sdf_plane(p,vec3(0,0,1),h));
	d=sdf_diff(d,sdf_plane(p,vec3(0,0,-1),h));
	return csd_t(d,m); }


csd_t csdf_ellipsoid(vec3 p,vec3 r,float s,mat_t m) {
	return csd_t(sdf_ellipsoid(p,r),m); }


csd_t csdf_octahedron(vec3 p,float r,mat_t m) {
	return csd_t(sdf_octahedron(p,r),m); }


csd_t csdf_quad(vec3 p,vec3 A,vec3 B,vec3 C,vec3 D,mat_t m) {
	return csd_t(sdf_quad(p,A,B,C,D),m); }








csd_t csdf_scene(vec3 p) {
	sd_t sd=SDF_CLEAR;
	const float one4=1.0/4;
	vec3 cell_size=vec3(0.5*one4,0.5*one4,0.2*one4);
	//SDF_UNION(sd,sdf_plane(p+vec3(0,0,0.001),vec3(0,0,1),0));
	//SDF_UNION(sd,sdf_box_frame(repeat(p+vec3(0,0,0.2*one4),vec3(one4,one4,0)),cell_size,0.002));
	//SDF_SECT(sd,sdf_box(p,8*vec3(cell_size)+cell_size));
	vec3 c=vec3(0,0,0.2*one4);
	// for(int i=0;i<8;i+=1) {
	// 	for(int j=0;j<8;j+=1) {
	// 		sd_t cell=sdf_nicked_box(p+c-vec3((2*i-7)*cell_size.x,(2*j-7)*cell_size.y,0),0.95*cell_size,0.01);
	// 		if(INSIDE(cell)) {
	// 			index=(1+i*8.0+j)/MAX_INDEX; }
	// 		SDF_UNION(sd,cell); } }
	vec3 wave_center=vec3(0,0,0);
	sd=sdf_plane(p,vec3(0,0,1),0);
	// sd=SDF_CLEAR;
	c=p-wave_center;
	// sd=sdf_union(sd,sdf_isosceles_triangle(p.zx,vec2(0.25,1)));
	float back_length=mix(2.0,4.0,(1+sin(time*0.2))/2);
	float front_length=mix(1.0,2.0,(1+sin(time*0.5))/2);
	float height=mix(0.4,0.8,(1+sin(time*0.3))/2);

	// WAVE TROUGH //
	sd_t wave_trough=sdf_box(p-vec3(front_length/2,0,height/2),vec3(front_length/2,1000,height/2));
	wave_trough=sdf_diff(wave_trough,sdf_ellipse(p.zx-vec2(height,front_length),vec2(height,front_length)));
	sd=sdf_union(sd,wave_trough);

	// WAVE CREST //
	float ct=2*max(0,height/front_length-0.5);
	ct=(1+sin(time*0.7))/2;
	float crest_length=mix(0.0,3.0,ct);
	crest_length=min(crest_length,2);
	float crest_thickness=0.1;
	float lip_t=-2*crest_length+PI;
	vec2 wave_lip=vec2(
		0.5*front_length+0.5*cos(lip_t)*front_length-0.5*crest_thickness,
		height+0.5*sin(lip_t)*front_length-crest_thickness);
	vec2 wave_peak=vec2(
		0.5*front_length+0.5*cos(-2*min(crest_length,PI/6)+PI)*(front_length+crest_thickness)-0.5*crest_thickness,
		height+0.5*sin(-2*min(crest_length,PI/6)+PI)*(front_length+crest_thickness)-crest_thickness);
	sd_t wave_crest=sdf_arc(
		mat2_rotate(crest_length)*vec2(-p.z+height-1*crest_thickness,-p.x+front_length/2-crest_thickness/2),
		vec2(cos(crest_length),sin(crest_length)),
		front_length/2,
		crest_thickness);
	sd=sdf_smooth_union(sd,wave_crest,0.0);

	// TUNNEL //
	sd_t tunnel=sdf_cylinder_y(p-vec3(front_length/2-0.5*crest_thickness,0,height-crest_thickness),1000,front_length/2-0.5*crest_thickness);
	sd_t foam_bounds=sdf_cylinder_y(p-vec3(wave_lip.x,0,wave_lip.y),1000,0.6*pow(ct,0.6));
	// sd=sdf_union(sd,tunnel);

	// WAVE BACK //
	// vec2 wave_peak=vec2(front_length,0);
	sd_t wave_back=sdf_isosceles_triangle(c.zx+vec2(height,back_length*2),vec2(2*height,back_length*2));
	sd_t wave_extra_back=sdf_isosceles_triangle(
		c.zx+vec2(wave_peak.y,back_length*2+wave_peak.x),
		vec2(2*wave_peak.y,2*back_length+2*wave_peak.x));
	sd=sdf_smooth_union(sd,wave_back,0.0);
	sd=sdf_smooth_union(sd,sdf_diff(wave_extra_back,tunnel),0.0);

	// TEMP
	// sd=sdf_diff(sd,sdf_plane(c,vec3(0,1,0),0));


	csd_t csd=csd_t(sd,WATER);

	// csd=csdf_union(csd,csd_t(foam_bounds,FOAM));

	const float MAX_WAVE_HEIGHT=0.1;

	// csd=csdf_displace(csd,1-map(p.xy),-clamp((MAX_WAVE_HEIGHT-p.z)/MAX_WAVE_HEIGHT,0.0,0.2));
	// csd=csdf_displace(csd,map(p.xy),0.2);
	csd=csdf_displace(csd,1-sea_octave(p.xy,SEA_SHARPNESS,SEA_CHOPPY),-0.1);


	csd=csdf_union(csd,csdf_capsule(c,vec3(front_length,0,0),vec3(-back_length,0,0),0.01,ROCK));
	csd=csdf_union(csd,csdf_capsule(c,vec3(0,0,0),vec3(0,0,height),0.01,SAND));
	csd=csdf_union(csd,csdf_sphere(c,0.03,ROCK));
	csd=csdf_union(csd,csdf_sphere(c-vec3(wave_peak.x,0,wave_peak.y),0.03,SAND));
	csd=csdf_union(csd,csdf_sphere(c-vec3(wave_lip.x,0,wave_lip.y),0.1,SURF));

	// SURFER //
	csd=csdf_union(csd,csdf_sphere(c-vec3(1,0,0.5),0.05,SKIN));

	// SURF //
	csd=csdf_union(csd,csdf_sphere(c-surf_position,0.05,SURF));

	csd=csdf_union(csd,csdf_capsule(c,vec3(-1,0,0),vec3(-1,0,1),0.01,SURF));

	csd=csdf_union(csd,csd_t(sdf_foam(p,foam_bounds,vec3(1,0,0),1*ct),FOAM));
	// csd=csd_t(sdf_foam(p,sdf_sphere(p,1),0.1*normalize(p),0.5),FOAM);

	return csd; }







#define BYTE_0(x) ((x<<24)>>24)
#define BYTE_1(x) ((x<<16)>>24)
#define BYTE_2(x) ((x<<8)>>24)
#define BYTE_3(x) (x>>24)
#define FNV32_BASE 0x811c9dc5
#define FNV32_PRIME 8378171
float int_ratio(int x) { return 0.5*(float(x)/float(0x7fffffff))+0.5; }
int hash_i(int value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value);
	hash=(hash*FNV32_PRIME)^BYTE_1(value);
	hash=(hash*FNV32_PRIME)^BYTE_2(value);
	hash=(hash*FNV32_PRIME)^BYTE_3(value);
	return hash; }
int hash_ivec2(ivec2 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	return hash; }
int hash_ivec3(ivec3 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.z);
	return hash; }
int hash_ivec4(ivec4 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.w);
	return hash; }
/*
float perlin_noise_3d(ivec3 pos) {
	int X = floor(pos.x) & 255; // x % 255
}
*/
vec2 random_vec2(int seed) { return vec2(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255); }
vec3 random_vec3(int seed) { return vec3(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255,float(BYTE_2(seed))/255); }
vec4 random_vec4(int seed) { return vec4(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255,float(BYTE_2(seed))/255,float(BYTE_3(seed))/255); }
const vec3 random_dirs[32] = vec3[32](
	vec3(0.00890501,  0.33932587,-0.2680479),
	vec3(0.33795923, -0.14174385,-0.05775675),
	vec3(0.24685223, -0.06839859, 0.037358),
	vec3(-0.35588088, 0.19096668, 0.02873264),
	vec3(-0.12825991, 0.21726794,-0.14824965),
	vec3(-0.03502917,-0.27566954,-0.07298317),
	vec3(-0.22338162,-0.17904491, 0.18859502),
	vec3(-0.16541397,-0.01115536, 0.36213034),
	vec3( 0.00417482, 0.15908165,-0.12566535),
	vec3(0.15844095, -0.06645189,-0.02707733),
	vec3(0.11572846, -0.0320664,  0.01751405),
	vec3(-0.16684291, 0.08952838, 0.01347034),
	vec3(-0.06013039, 0.10185885,-0.06950192),
	vec3(-0.01642226,-0.1292385, -0.03421573),
	vec3(-0.10472504,-0.08393925, 0.0884165),
	vec3(-0.07754884,-0.00522982, 0.16977276),
	vec3(0.16303464,  0.07938476, 0.0145593),
	vec3(-0.07879107,-0.11984104, 0.16595457),
	vec3(0.00567464, -0.1356574,  0.04361052),
	vec3(0.09771088,  0.03990721, 0.14736905),
	vec3(-0.16259318, 0.01009632,-0.01436057),
	vec3(-0.15455663, 0.04991017, 0.1245326),
	vec3(0.0328222,  -0.0847218,  0.12002946),
	vec3(0.00335348,  0.00384542, 0.08935784),
	vec3(-0.12433664, 0.11287646, 0.06472793),
	vec3(0.10138854, -0.10890599, 0.10678017),
	vec3(-0.10900923,-0.14777506, 0.12544872),
	vec3(0.12758758,  0.13297441,-0.00992011),
	vec3(-0.07979501,-0.17407095, 0.05146146),
	vec3(0.07766119,  0.11850656,-0.07703004),
	vec3(-0.10057095, 0.049205,   0.10773038),
	vec3(0.16374578, -0.12341746,-0.00628171));









#define PLUS_X  0
#define MINUS_X 1
#define PLUS_Y  2
#define MINUS_Y 3
#define PLUS_Z  4
#define MINUS_Z 5
const vec2 cubemap_grid=vec2(4,3);
const vec2 cubemap_grid_reciprocal=vec2(1.0/4,1.0/3);


vec2 ray_to_cubeuv(vec3 ray) {
	vec2 cubeuv=vec2(0);
	if((ray.x<=0)&&(abs(ray.y)<=abs(ray.x))&&(abs(ray.z)<=abs(ray.x))) { // 1 MINUS_X //
		vec2 quad_uv=(vec2(-ray.z/ray.x,-ray.y/ray.x)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(0,1))/cubemap_grid; }
	else if((ray.x>=0)&&(abs(ray.y)<=abs(ray.x))&&(abs(ray.z)<=abs(ray.x))) { // 0 PLUS_X //
		vec2 quad_uv=(vec2(-ray.z/ray.x,ray.y/ray.x)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(2,1))/cubemap_grid; }
	else if((ray.y<=0)&&(abs(ray.x)<=abs(ray.y))&&(abs(ray.z)<=abs(ray.y))) { // 3 MINUS_Y //
		vec2 quad_uv=(vec2(-ray.x/ray.y,-ray.z/ray.y)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(1,0))/cubemap_grid; }
	else if((ray.y>=0)&&(abs(ray.x)<=abs(ray.y))&&(abs(ray.z)<=abs(ray.y))) { // 2 PLUS_Y //
		vec2 quad_uv=(vec2(ray.x/ray.y,-ray.z/ray.y)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(1,2))/cubemap_grid; }
	else if((ray.z<=0)&&(abs(ray.x)<=abs(ray.z))&&(abs(ray.y)<=abs(ray.z))) { // 5 MINUS_Z //
		vec2 quad_uv=(vec2(ray.x/ray.z,-ray.y/ray.z)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(3,1))/cubemap_grid; }
	else if((ray.z>=0)&&(abs(ray.x)<=abs(ray.z))&&(abs(ray.y)<=abs(ray.z))) { // 4 PLUS_Z //
		vec2 quad_uv=(vec2(ray.x/ray.z,ray.y/ray.z)+vec2(1))/2;
		cubeuv=(quad_uv+vec2(1,1))/cubemap_grid; }
	return cubeuv; }


vec3 cubeuv_to_ray(vec2 cubeuv) {
	vec3 ray=vec3(0);
	if(cubeuv.x<=cubemap_grid_reciprocal.x) { // 1 MINUS_X //
		vec2 quad_uv=(cubeuv*cubemap_grid-vec2(0,1))*2-vec2(1);
		ray=normalize(vec3(1,-quad_uv.y,-quad_uv.x)); }
	else if((cubeuv.x>cubemap_grid_reciprocal.x)&&(cubeuv.x<=2*cubemap_grid_reciprocal.x)) {
		if(cubeuv.y<=cubemap_grid_reciprocal.y) { // 2 PLUS_Y //
			vec2 quad_uv=(cubeuv*cubemap_grid-vec2(1,2))*2-vec2(1);
			ray=normalize(vec3(quad_uv.x,1,-quad_uv.y)); }
		else if((cubeuv.y>cubemap_grid_reciprocal.y)&&(cubeuv.y<=2*cubemap_grid_reciprocal.y)) { // 4 PLUS_Z //
			vec2 quad_uv=(cubeuv*cubemap_grid-vec2(1,1))*2-vec2(1);
			ray=normalize(vec3(quad_uv.x,quad_uv.y,1)); }
		else if(cubeuv.y>2*cubemap_grid_reciprocal.y) { // 3 MINUS_Y //
			vec2 quad_uv=(cubeuv*cubemap_grid-vec2(1,0))*2-vec2(1);
			ray=normalize(vec3(-quad_uv.x,1,-quad_uv.y)); } }
	else if((cubeuv.x>2*cubemap_grid_reciprocal.x)&&(cubeuv.x<=3*cubemap_grid_reciprocal.x)) { // 0 PLUS_X //
		vec2 quad_uv=(cubeuv*cubemap_grid-vec2(2,1))*2-vec2(1);
		ray=normalize(vec3(1,quad_uv.y,-quad_uv.x)); }
	else if(cubeuv.x>3*cubemap_grid_reciprocal.x) { // 5 MINUS_Z //
		vec2 quad_uv=(cubeuv*cubemap_grid-vec2(3,1))*2-vec2(1);
		ray=normalize(vec3(quad_uv.x,-quad_uv.y,1)); }
	return ray; }










const vec3 CAMERA_DEFAULT_POSITION=vec3(0);
const vec3 CAMERA_DEFAULT_DIRECTION=vec3(0,1,0);
const vec3 CAMERA_DEFAULT_UP_DIRECTION=vec3(0,0,1);
const float CAMERA_DEFAULT_FOCAL_LENGTH=1;
const float CAMERA_DEFAULT_LENS_LENGTH=0;
const vec2 CAMERA_DEFAULT_SENSOR_SIZE=vec2(1,1);
vec3 camera_receptor_vector(
		vec2 sensor_point,
		float focal_length,
		vec2 sensor_size,
		vec3 forward_axis,
		vec3 vertical_axis,
		vec3 horizontal_axis) {
	return mat3(horizontal_axis,vertical_axis,forward_axis)*normalize(vec3(
		-0.5*sensor_size.x+sensor_point.x*sensor_size.x,
		-0.5*sensor_size.y+sensor_point.y*sensor_size.y,
		focal_length)); }








/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                   R A Y   C A S T I N G                                     |
  |_____________________________________________________________________________________________|*/


void ray_trace_scattered(
		out csd_t csd,
		vec3 light_dest,
		vec3 ray_dir,
		float scattering_coefficient,
		float eye_limit,
		int seed,
		out vec3 light_src,
		out float ray_length,
		out bool hit_surface,
		out bool hit_sky) {
	csd=CSDF_CLEAR;
	light_src=light_dest; ray_length=0; hit_surface=false; hit_sky=false;
	for(int i; i<STEPS_LIMIT; i=i+1) {
		ray_dir=normalize(mix(ray_dir,random_vec3(hash_ivec3(ivec3(int(gl_FragCoord.x),int(gl_FragCoord.y),i+seed))),scattering_coefficient));
		csd=csdf_scene(light_src);
		float step_length=csd.x;
		light_src+=(step_length*(ray_dir));
		ray_length+=step_length;
		if(csd.x<(EPSILON)) { hit_surface=true; break; }
		if((ray_length)>=eye_limit) { hit_sky=true; break; } } }


csd_t cast_ray(vec3 surface,vec3 receptor_vector,float eye_limit,out vec3 light_origin) {
	csd_t csd=CSDF_CLEAR;
	light_origin=surface;
	for (int i; i<STEPS_LIMIT; i+=1) {
		csd_t csd=csdf_scene(light_origin);
		light_origin+=(csd.x*receptor_vector);
		if (!((i<STEPS_LIMIT)&&(csd.x>=EPSILON)&&(distance(surface,light_origin)<eye_limit))) {
			return csd; } }
	return CSDF_CLEAR; }








uv_t uv_x(vec3 p,float s) { return p.yz/s; }
uv_t uv_y(vec3 p,float s) { return p.xz/s; }
uv_t uv_z(vec3 p,float s) { return p.xy/s; }
uv_t uv_sphere(vec3 p,float s) {
	return vec2(vec_angle(p.xy)/TWO_PI,p.z-0.5)/s; }
uv_t uv_directed_sphere(vec3 p,float s,vec3 y,vec3 cy) {
	y=normalize(y); cy=normalize(cy);
	vec3 x=normalize(cross(y,cy));
	vec3 z=normalize(cross(y,x));
	vec3 local_p=vec3(dot(p,x),dot(p,y),dot(p,z));
	return vec2(vec_angle(local_p.xz)/TWO_PI,local_p.y-0.5)/s; }
uv_t uv_cone_x(vec3 p,vec2 b,float h,float s) {
	return vec2((b.y/b.x)*vec_angle(p.yz)/2.6,length(p)*1.5)/(s); }
uv_t uv_cone_y(vec3 p,vec2 b,float h,float s) {
	return vec2((b.y/b.x)*vec_angle(p.xz)/2.6,length(p)*1.5)/(s); }
uv_t uv_cone_z(vec3 p,vec2 b,float h,float s) {
	return vec2((b.y/b.x)*vec_angle(p.xy)/2.6,length(p)*1.5)/(s); }
uv_t uv_directed_cone(vec3 p,vec2 b,float h,float s,vec3 n) {
	mat3 ax=axify(n);
	vec3 local_p=vec3(dot(p,ax[TANGENT]),dot(p,ax[BINORMAL]),dot(p,ax[NORMAL]));
	return vec2((b.y/b.x)*vec_angle(local_p.xz)/2.6,length(local_p)*1.5)/(s); }
uv_t uv_box(vec3 p,vec3 d,float scale) {
	vec2 uv_x=(p.yz/min(d.y,d.z)/2+vec2(0.5))/scale;
	vec2 uv_y=(p.xz/min(d.x,d.z)/2+vec2(0.5))/scale;
	vec2 uv_z=(p.xy/min(d.x,d.y)/2+vec2(0.5))/scale;
	float y_mask=0.5*sign(d.y-DELTA-abs(p.y))+0.5;
	float z_mask=0.5*sign(d.z-DELTA-abs(p.z))+0.5;
	return mix(uv_z,mix(uv_y,uv_x,y_mask),z_mask); }
uv_t uv_box_offset(vec3 p,vec3 d,float off,float scale) {
	vec2 base_uv=(p.xz/2/d.z+vec2(0.5))/scale;
	float diam=length(vec2(d.xz));
	vec2 side_uv=(p.xy/2/d.z+vec2(0.5))/scale;
	float side_mask=0.5*(sign(p.x-p.y)+1);
	side_uv.x=mix(side_uv.x,-side_uv.x,side_mask);
	float region=0.5*(sign((d.y-(DELTA+off))-abs(p.y))+1);
	return mix(base_uv,side_uv,region); }
uv_t uv_directed_box(vec3 p,vec3 b,vec3 x,vec3 cx,float uv_s) {
	x=normalize(x);
	cx=normalize(cx);
	vec3 y=normalize(cross(x,cx));
	vec3 z=normalize(cross(x,y));
	vec3 local_p=vec3(dot(p,x),dot(p,y),dot(p,z));
	if(abs(local_p.x)>b.x-DELTA) { return uv_x(local_p,uv_s); }
	if(abs(local_p.y)>b.y-DELTA) { return uv_y(local_p,uv_s); }
	if(abs(local_p.z)>b.z-DELTA) { return uv_z(local_p,uv_s); }
	return vec2(1,1); }
uv_t uv_cylinder_x(vec3 p,float h,float r,float s) {
	float circ=TWO_PI*r;
	float ratio=0.5*circ/h;
	vec2 base_uv=0.5*p.yz/r+vec2(0.5);
	vec2 surface_uv=vec2((vec_angle(p.yz)+PI)/TWO_PI,0.5*(p.x/h)+0.5);
	//float region=0.5*(sign((h-DELTA)-abs(p.yz))+1.0);
	float region=0; // TEMP
	return mix(base_uv,surface_uv,region); }
uv_t uv_cylinder_y(vec3 p,float h,float r,float s) {
	float circ=TWO_PI*r;
	float ratio=0.5*circ/h;
	vec2 base_uv=0.5*p.xz/r+vec2(0.5);
	vec2 surface_uv=vec2((vec_angle(p.xz)+PI)/TWO_PI,0.5*(p.y/h)+0.5);
	float region=0.5*(sign((h-DELTA)-abs(p.y))+1.0);
	return mix(base_uv,surface_uv,region); }
uv_t uv_cylinder_z(vec3 p,float h,float r,float s) {
	//TODO Fix the 2 other cylinder uv_t functions, this one is correct, the others aren't.
	float circ=TWO_PI*r;
	float ratio=0.5*circ/h;
	vec2 base_uv=0.5*p.xy/r+vec2(0.5);
	vec2 surface_uv=vec2((vec_angle(p.xy)+PI)/TWO_PI,0.5*(p.z/h)+0.5);
	float region=0.5*(sign((h-DELTA)-abs(p.z))+1.0);
	return mix(base_uv,surface_uv,region); }
uv_t uv_tri_plane(vec3 p,float s) {
	vec2 x=uv_x(p,s);
	vec2 y=uv_y(p,s);
	vec2 z=uv_z(p,s);
	vec3 m=vec3(
		abs(dot(p,vec3(1,0,0))),
		abs(dot(p,vec3(0,1,0))),
		abs(dot(p,vec3(0,0,1))));
	float m_max=max(max(m.x,m.y),m.z);
	m=(vec3(sign(m.x-m_max),sign(m.y-m_max),sign(m.z-m_max))+vec3(1));
	return x*m.x+y*m.y+z*m.z; }
uv_t uv_normal_tri_plane(vec3 p,vec3 n,float s) {
	vec2 x=uv_x(p,s);
	vec2 y=uv_y(p,s);
	vec2 z=uv_z(p,s);
	vec3 m=vec3(
		abs(dot(n,vec3(1,0,0))),
		abs(dot(n,vec3(0,1,0))),
		abs(dot(n,vec3(0,0,1))));
	float m_max=max(max(m.x,m.y),m.z);
	m=(vec3(sign(m.x-m_max),sign(m.y-m_max),sign(m.z-m_max))+vec3(1,1,1));
	return x*m.x+y*m.y+z*m.z; }
uv_t plane_uv(vec3 p,vec3 ax_u,vec3 ax_v,float s) {
	return vec2(dot(p,ax_u)/s,dot(p,ax_v)/s); }
uv_t uv_view(vec2 res) {
	return (gl_FragCoord.xy/res.xy)*vec2(res.x/res.y,1); }









#define SHADE(light_color,light_intensity) (normalize(light_color)*light_intensity)
#define MOD(light_color,surface_color) (light_color*surface_color)
#define SCATTER(ray,roughness,seed) mix(ray,random_vec3(seed),roughness)








/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                         N O R M A L                                         |
  |_____________________________________________________________________________________________|*/


#define NORMAL_DELTA 0.01
#define NORMAL_HALF_DELTA (0.5*NORMAL_DELTA)




vec3 csdf_normal(vec3 point) {
	return normalize(vec3(
		csdf_scene(vec3(point.x+NORMAL_HALF_DELTA,point.yz)).x-csdf_scene(vec3(point.x-NORMAL_HALF_DELTA,point.yz)).x,
		csdf_scene(vec3(point.x,point.y+NORMAL_HALF_DELTA,point.z)).x-csdf_scene(vec3(point.x,point.y-NORMAL_HALF_DELTA,point.z)).x,
		csdf_scene(vec3(point.xy,point.z+NORMAL_HALF_DELTA)).x-csdf_scene(vec3(point.xy,point.z-NORMAL_HALF_DELTA)).x)); }


#define MAX_SSLT_COEFFICIENT 1.0
float SSLT_coefficient_from_metallicity(float metallicity) {
	return mix(0.0,MAX_SSLT_COEFFICIENT,metallicity); }
LIGHT occluded_light_from_light(LIGHT light,bool occluder_present,VALUE occluder_transparency) {
	return occluder_present?occluder_transparency*light:light; }
LIGHT ambient_light_from_sky_sampler(sampler2D sky_sampler) {
	const int n_samples=4;
	LIGHT acc=vec3(0);
	for(int i=0;i<n_samples;i+=1) {
		acc+=texture(sky_sampler,uv_sphere(random_dirs[i],1)); }
	return acc/n_samples; }
float transmission_coefficient_from_reflection_coefficient(float reflection_coefficient) {
	return (1-reflection_coefficient); }
float reflection_coefficient_from_transmission_coefficient(float transmission_coefficient) {
	return (1-transmission_coefficient); }
bool occlusion_by_cone(vec3 receptor_origin,vec3 receptor_vector,float far_clip,int seed) {
	csd_t csd=CSDF_CLEAR; vec3 source_point; float ray_length; bool hit_surface, hit_sky;
	//ray_trace(csd,receptor[RECEPTOR_ORIGIN]+receptor[RECEPTOR_VECTOR]*(4*EPSILON),receptor[RECEPTOR_VECTOR],far_clip,source_point,ray_length,hit_surface,hit_sky);
	ray_trace_scattered(
		csd,
		receptor_origin+receptor_vector*(4*EPSILON),
		receptor_vector,
		0.2,
		far_clip,
		seed,
		source_point,
		ray_length,
		hit_surface,
		hit_sky);
	return hit_surface; }


color_t shade_surface_by_cone(vec3 surface,vec3 cone,float near_clip,float far_clip) {
	vec3 surface_offset=surface+cone*near_clip;
	vec3 light_origin_point;
	csd_t csd=cast_ray(surface_offset,cone,far_clip,light_origin_point);
	if (csd.x<EPSILON) {
		ray_t surface=ray_t(light_origin_point,csdf_normal(light_origin_point/*,csd.x*/));
		bool occlusion=occlusion_by_cone(light_origin_point,sun_dir,far_clip,0);
		if (csd_material(csd)==WATER) {
			return shade_water(surface,occlusion); }
		if (csd_material(csd)==SAND) {
			return shade_sand(surface,occlusion); }
		if (csd_material(csd)==ROCK) {
			return shade_rock(surface,occlusion); }
		if (csd_material(csd)==SURF) {
			return shade_surf(surface,occlusion); }
		if (csd_material(csd)==SKIN) {
			return shade_skin(surface,occlusion); }
		if (csd_material(csd)==FOAM) {
			return shade_foam(surface,occlusion); }
		return color_t(0); }
	else {
		return texture(skybox_sampler,ray_to_cubeuv(-cone.xzy)).xyz;
		return mix(vec3(0,0,0),vec3(1,1,1),0.5*(cone.z+1)); } }








void main(void) {
	float eye_limit=24;
	color=vec4(0,0,0,1);
	float scr_ratio=res.x/res.y;
	vec2 scr_point=2*(gl_FragCoord.xy/res)-vec2(1);
	scr_point.x=scr_point.x*scr_ratio;
	vec2 camera_sensor_size=vec2(2*scr_ratio,2);
	float camera_focal_length=2;
	vec3 receptor_vector=camera_receptor_vector(
		tex_coord,
		camera_focal_length,
		camera_sensor_size,
		camera_direction,
		camera_up_direction,
		camera_side_direction);


	// vec2 uv=16*scr_point;
	// uv+=noise(uv);
	// uv=sin(2.0*uv)*0.5+0.5;

	// color.x=uv.x*uv.y;
	// color.x=min(uv.x,uv.y);
	// color.x=mix(uv.x*uv.y,min(uv.x,uv.y),max(uv.x,uv.y));

	// color.x=pow(color.x,0.3);

	// pow(1.0-pow(color.x,0.65),0.5*choppy);

	// color.x=0.5*(sea_octave(scr_point*10+0*time,SEA_SHARPNESS,SEA_CHOPPY)+1);
	// color.x=map(10*scr_point);
	// color.x=sea_octave(scr_point*10+0*time,SEA_SHARPNESS,SEA_CHOPPY);
	// return;

	color.x=noise3(receptor_vector*10);
	color.x=fbm(receptor_vector*10);

	// return;

	color.xyz=shade_surface_by_cone(camera_position,receptor_vector,0,eye_limit); }
	// color.xyz=color_t(0.5*(sea_octave(4*scr_point,1)+1)); }


