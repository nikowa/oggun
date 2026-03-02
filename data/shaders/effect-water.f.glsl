#define MAX_INDEX 255
#include "effect-common.glsl"
layout(binding=6) uniform sampler2D dev_grid_sampler;
layout(binding=7) uniform sampler2D dev_oriented_grid_sampler;
layout(binding=8) uniform sampler2D background_sampler;
uniform vec3 surf_position;
uniform vec3 surf_direction;
uniform vec3 surf_up_direction;
uniform vec3 surf_side_direction;
uniform vec3 surfer_position;
uniform int hovered_index;
uniform int swimming;
uniform int paddling;
uniform int surfing;
const float EPSILON=0.02; // low: 0.02, high: 0.001
const float SHADOW_RADIUS=0.02;
const float SHADOW_LIMIT=8.0;
const float DELTA=0.01;
const float HALF_DELTA=DELTA/2;
#include <util.glsl>
#include <linalg.glsl>
#include <csdf.glsl>
#include <material.glsl>
// #include <color.glsl>
// #include <linalg.glsl>
// TODO Rename this file to fscene.glsl //
#include <scene-water.glsl>
#include <normal.glsl>
#include <ray.glsl>
#include <camera.glsl>
#include <light.glsl>


color_t shade_water(ray_t surface,bool occlusion) {
	// color_t color=(1-int(occlusion))*color_t(1);
	// color_t color=(1-int(occlusion))*;
	float t=clamp(dot(vec3(0,0,1),ray_direction(surface)),0,1);
	color_t color=0.5*mix(
		color_t(float(120)/255,float(100)/255,float(250)/255),
		color_t(float(0)/255,float(50)/255,float(150)/255),
		t);
	color=vec3(0.5); // TEMP
	// TODO Do subsurface scattering here. //
	color_t reflection=mirror_BRDF(ray_position(surface)-camera_position,ray_direction(surface));


	color_t base_color=lambert_BRDF(color,ray_position(surface)-camera_position,ray_direction(surface),sun_dir,0.0);
	color=base_color+0.35*reflection;

	color=blend_multiply(color,SHADOW_COLOR,0.5*int(occlusion));
	float foam_t=float(sea_octave(ray_position(surface).xy,SEA_SHARPNESS,SEA_CHOPPY)>0.95);
	color=mix(color,FOAM_COLOR,foam_t);

	color_t background_color=texture(background_sampler,tex_coord).xyz;

	// color=mix(color,background_color,1-gl_FragDepth);

	return color; }
	// return posterize(color,4); }


color_t shade(vec3 surface,vec3 cone,float near_clip,float far_clip) {
	vec3 surface_offset=surface+cone*near_clip;
	vec3 light_origin_point;
	csd_t csd=cast_ray(surface_offset,cone,far_clip,light_origin_point);
	// gl_FragDepth=0;
	// return light_origin_point;
	// return color_t(csd.x/far_clip);
	if (csd.x<EPSILON) {
		float depth=distance(light_origin_point,camera_position)/camera_far_clip;
		gl_FragDepth=depth;
		// return color_t(1,0,0);
		ray_t surface=ray_t(light_origin_point,csdf_normal(light_origin_point/*,csd.x*/,true));
		bool occlusion=occlusion_by_cone(light_origin_point,sun_dir,far_clip,0);
		color_t result;
		if (csd_material(csd)==WATER) {
			result=shade_water(surface,occlusion); }
		else if (csd_material(csd)==SAND) {
			result=shade_sand(surface,occlusion); }
		else if (csd_material(csd)==ROCK) {
			result=shade_rock(surface,occlusion); }
		else if (csd_material(csd)==SURF) {
			result=shade_surf(surface,occlusion); }
		else if (csd_material(csd)==SKIN) {
			result=shade_skin(surface,occlusion); }
		else if (csd_material(csd)==FOAM) {
			result=shade_foam(surface,occlusion); }
		else if (csd_material(csd)==DEV) {
			result=shade_dev(surface,occlusion); }
		else {
			result=color_t(0); }
		return mix(result,haze_color,clamp((2.0*(depth-1))+1,0.0,1.0));
		return result; }
	else {
		float depth=0.999;
		gl_FragDepth=depth;
		// return color_t(0,0,1);
		// return color_t(depth);//TEMP
		vec3 ray=-cone.xzy;
		if((ray.x<=0)&&(abs(ray.y)<=abs(ray.x))&&(abs(ray.z)<=abs(ray.x))) { // 1 MINUS_X / BACK //
			vec2 quad_uv=(vec2(-ray.z/ray.x,-ray.y/ray.x)+vec2(1))/2;
			return texture(sky_back_sampler,quad_uv).xyz; }
		else if((ray.x>=0)&&(abs(ray.y)<=abs(ray.x))&&(abs(ray.z)<=abs(ray.x))) { // 0 PLUS_X / FRONT //
			vec2 quad_uv=(vec2(-ray.z/ray.x,ray.y/ray.x)+vec2(1))/2;
			return texture(sky_front_sampler,quad_uv).xyz; }
		else if((ray.y<=0)&&(abs(ray.x)<=abs(ray.y))&&(abs(ray.z)<=abs(ray.y))) { // 3 MINUS_Y //
			vec2 quad_uv=(vec2(-ray.x/ray.y,-ray.z/ray.y)+vec2(1))/2;
			return texture(sky_up_sampler,quad_uv).xyz; }
		else if((ray.y>=0)&&(abs(ray.x)<=abs(ray.y))&&(abs(ray.z)<=abs(ray.y))) { // 2 PLUS_Y / UP //
			vec2 quad_uv=(vec2(ray.x/ray.y,-ray.z/ray.y)+vec2(1))/2;
			return texture(sky_up_sampler,quad_uv).xyz; }
		else if((ray.z<=0)&&(abs(ray.x)<=abs(ray.z))&&(abs(ray.y)<=abs(ray.z))) { // 5 MINUS_Z / RIGHT //
			vec2 quad_uv=(vec2(ray.x/ray.z,-ray.y/ray.z)+vec2(1))/2;
			return texture(sky_right_sampler,quad_uv).xyz; }
		else if((ray.z>=0)&&(abs(ray.x)<=abs(ray.z))&&(abs(ray.y)<=abs(ray.z))) { // 4 PLUS_Z / LEFT //
			vec2 quad_uv=(vec2(ray.x/ray.z,ray.y/ray.z)+vec2(1))/2;
			return texture(sky_left_sampler,quad_uv).xyz; }
		// return texture(skybox_sampler,ray_to_cubeuv(-cone.xzy)).xyz;
		return mix(vec3(0,0,0),vec3(1,1,1),0.5*(cone.z+1)); } }


void main(void) {
	color=vec4(0,0,0,1);
	vec2 scr_point=2*(gl_FragCoord.xy/res)-vec2(1);
	scr_point.x=scr_point.x*res.x/res.y;
	vec3 receptor_vector=camera_receptor_vector(
		tex_coord,
		camera_focal_length,
		camera_sensor_size,
		camera_direction,
		camera_up_direction,
		camera_side_direction);
	color.xyz=shade(camera_position,receptor_vector,0,camera_far_clip); }