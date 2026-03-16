#include <types>








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
