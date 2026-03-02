#include <types.glsl>








#define PLUS_X  0
#define MINUS_X 1
#define PLUS_Y  2
#define MINUS_Y 3
#define PLUS_Z  4
#define MINUS_Z 5
const vec2 cubemap_grid=vec2(4,3);
const vec2 cubemap_grid_reciprocal=vec2(1.0/4,1.0/3);


// CORRECT //
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


// UNVERIFIED //
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

