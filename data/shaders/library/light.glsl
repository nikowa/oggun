#include <types.glsl>
#include <noise.glsl>
#include <csdf.glsl>
#include <color.glsl>
#include <uv.glsl>
#include <cubemap.glsl>








#define SHADE(light_color,light_intensity) (normalize(light_color)*light_intensity)
#define MOD(light_color,surface_color) (light_color*surface_color)
#define SCATTER(ray,roughness,seed) mix(ray,random_vec3(seed),roughness)








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