#include <types>
#include <util>



/*._______________________.
  |                       |
  |        HELPERS        |
  |_______________________|*/

vec2 get_p(vec2 res) {
	vec2 pixel = gl_FragCoord.xy; // + vec2(0.5);
	return vec2(pixel.x - res.x / 2, res.y / 2 - pixel.y); }

vec2 p_from_rect_uv(vec2 uv, vec4 rect) {
	// vec2 pixel = gl_FragCoord.xy + vec2(0.5);
	// return vec2(pixel.x - res.x / 2, res.y / 2 - pixel.y); }
	return ((uv - vec2(0.5)) * rect.zw + vec2(rect.x, -rect.y)); }



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


sd_t sdf_ground_triangle(vec3 p,vec3 a,vec3 b,vec3 c) {
	vec3 n=normalize(cross(b-a,c-b));
	vec3 o=(a+b+c)/3;
	const vec3 z=vec3(0,0,1);
	vec3 ab_n=normalize(cross(b-a,z));
	vec3 bc_n=normalize(cross(c-b,z));
	vec3 ca_n=normalize(cross(a-c,z));
	sd_t d=sdf_plane(p-o,n,0);
	d=sdf_sect(d,sdf_plane(p-(a+b)/2,ab_n,0));
	d=sdf_sect(d,sdf_plane(p-(b+c)/2,bc_n,0));
	d=sdf_sect(d,sdf_plane(p-(c+a)/2,ca_n,0));
	d=sdf_union(d,sdf_sphere(p-a,0.2));
	d=sdf_union(d,sdf_sphere(p-b,0.2));
	d=sdf_union(d,sdf_sphere(p-c,0.2));
	return d; }


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