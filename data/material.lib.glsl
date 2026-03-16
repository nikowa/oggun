#include <types>
#include <color>
#include <substance>
#include <uv>
#include <rdf>


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


const color_t FOAM_COLOR=color_t(232,244,248)/255;
const color_t SHALLOW_SEA_COLOR=color_t(146,174,230)/255;
const color_t DEEP_SEA_COLOR=color_t(95,124,182)/255;
const color_t SURF_COLOR_1=color_t(250,173,255)/255;
const color_t SURF_COLOR_2=color_t(255,148,194)/255;
const color_t SURF_COLOR_3=color_t(255,255,230)/255;


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
	float t=(1-diffuse_of_surface(surface,-1000*sun_dir,vec3(1))).x;
	float w=dot(ray_direction(surface),vec3(0,0,1));
	return mix(mix(SURF_COLOR_2,SURF_COLOR_1,w),SHADOW_COLOR,0.5*t); }
	// return color_t(float(209)/255,float(167)/255,float(213)/255); }


color_t shade_skin(ray_t surface,bool occlusion) {
	return color_t(float(221)/255,float(211)/255,float(202)/255); }


color_t shade_dev(ray_t surface,bool occlusion) {
	uv_t uv=uv_normal_tri_plane(ray_position(surface),ray_direction(surface),8.0);
	return texture(dev_oriented_grid_sampler,uv).xyz; }

