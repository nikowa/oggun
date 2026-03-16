#include <types>
#include <sdf>








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







/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                           S E A                                             |
  |_____________________________________________________________________________________________|*/


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

