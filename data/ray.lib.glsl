#include <types>
#include <csdf>
#include <noise>
#include <cubemap>
#include <camera>








/*._____________________________________________________________________________________________.
  |                                                                                             |
  |                                   R A Y   C A S T I N G                                     |
  |_____________________________________________________________________________________________|*/


const int STEPS_LIMIT=100;


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
		csd=csdf_scene(light_src,true);
		float step_length=csd.x;
		light_src+=(step_length*(ray_dir));
		ray_length+=step_length;
		if(csd.x<(EPSILON)) { hit_surface=true; break; }
		if((ray_length)>=eye_limit) { hit_sky=true; break; } } }


csd_t cast_ray(vec3 surface,vec3 receptor_vector,float eye_limit,out vec3 light_origin) {
	csd_t csd=CSDF_CLEAR;
	light_origin=surface;
	for (int i; i<STEPS_LIMIT; i+=1) {
		csd_t csd=csdf_scene(light_origin,true);
		light_origin+=(csd.x*receptor_vector);
		if (!((i<STEPS_LIMIT)&&(csd.x>=EPSILON)&&(distance(surface,light_origin)<eye_limit))) {
			return csd; } }
	return CSDF_CLEAR; }