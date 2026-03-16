#include <types>








// TODO Move the definition of uv_t here. //
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
