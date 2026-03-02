#version 460 core
layout (binding = 0) uniform sampler2D diffuse_samp;
layout (binding = 1) uniform sampler2D thickness_samp;
layout (binding = 2) uniform sampler2D world_position_samp;
layout (binding = 3) uniform sampler2D sky_samp;
#define NORMAL   0
#define BINORMAL 1
#define TANGENT  2


const float PI = 3.14159265;
const float E=2.71828;
const float TWO_PI=6.28318530;
const float HALF_PI=1.57059632;


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
#define DEV   6
#define mat_t float








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




const float constant1_FON = 0.5 - 2.0 / (3.0 * PI);
const float constant2_FON = 2.0 / 3.0 - 28.0 / (15.0 * PI);


float E_FON_exact(float mu, float r) {
	float AF = 1.0f / (1.0f + constant1_FON * r);
	float BF = r * AF;
	float Si = sqrt(1.0f - (mu * mu));
	float G = Si * (acos(mu) - Si * mu) + (2.0f / 3.0f) * ((Si / mu) * (1.0f - (Si * Si * Si)) - Si);
	return AF + (BF/PI) * G; }


float E_FON_approx(float mu, float r) {
	float mucomp = 1.0f - mu;
	float mucomp2 = mucomp * mucomp;
	const mat2 Gcoeffs = mat2(0.0571085289f, -0.332181442f, 0.491881867f, 0.0714429953f);
	float GoverPi = dot(Gcoeffs * vec2(mucomp, mucomp2), vec2(1.0f, mucomp2));
	return (1.0f + r * GoverPi) / (1.0f + constant1_FON * r); }


vec3 f_EON(vec3 rho, float r, vec3 wi_local, vec3 wo_local, bool exact) {
	float mu_i = wi_local.z;
	float mu_o = wo_local.z;
	float s = dot(wi_local, wo_local) - mu_i * mu_o;
	float sovertF = s > 0.0f ? s / abs(max(mu_i, mu_o)) : s;
	float AF = 1.0f / (1.0f + constant1_FON * r);
	vec3 f_ss = (rho/PI) * AF * (1.0f + r * sovertF);
	float EFo = exact ? E_FON_exact(mu_o, r):
	E_FON_approx(mu_o, r);
	float EFi = exact ? E_FON_exact(mu_i, r):
	E_FON_approx(mu_i, r);
	float avgEF = AF * (1.0f + constant2_FON * r);
	vec3 rho_ms = (rho * rho) * avgEF / (vec3(1.0f) - rho * (1.0f - avgEF));
	const float eps = 1.0e-7f;
	vec3 f_ms = (rho_ms/PI) * max(eps, 1.0f - EFo) * max(eps, 1.0f - EFi) / max(eps, 1.0f - avgEF);
	// return vec3(s * min(1.0 / mu_i, 1.0 / mu_o));
	return f_ss + f_ms; }


vec3 E_EON(vec3 rho, float r, vec3 wi_local, bool exact) {
	float mu_i = wi_local.z;
	float AF = 1.0f / (1.0f + constant1_FON * r);
	float EF = exact ? E_FON_exact(mu_i, r) : E_FON_approx(mu_i, r);
	float avgEF = AF * (1.0f + constant2_FON * r);
	vec3 rho_ms = (rho * rho) * avgEF / (vec3(1.0f) - rho * (1.0f - avgEF));
	return rho * EF + rho_ms * (1.0f - EF); }


vec3 mirror_BRDF(vec3 outgoing_direction,vec3 surface_normal) {
	vec3 direction=reflect(-outgoing_direction,surface_normal);
	return texture(sky_samp,ray_to_cubeuv(direction.xzy)).xyz; }


vec3 lambert_BRDF(vec3 base_color,vec3 outgoing_direction,vec3 surface_normal,vec3 light_direction,float roughness) {
	// if (dot(-outgoing_direction,surface_normal)>0.95) { return 1.0; }
	// return 0.0;
	// if (surface_normal.y>0.0) { return 1.0; }
	float diffuse_component=clamp(1.0*dot(surface_normal,-light_direction),0.0,1.0);
	vec3 reflected_light_direction=reflect(-light_direction,surface_normal);
	float specular_component=0.1*pow(max(dot(outgoing_direction,reflected_light_direction),0.0),1.0);
	// float specular_component=clamp(dot(outgoing_direction,reflect(-light_direction,surface_normal)),0.0,1.0);
	return (1.0+diffuse_component)*base_color+vec3(1.0)*specular_component; }


vec3 jensen_BSSRDF(vec3 omega_out,vec3 omega_in) {
	return vec3(0);
}


vec3 eon_BRDF(vec3 base_color,vec3 outgoing_direction,vec3 surface_normal,vec3 light_direction,float roughness) {
	vec3 result=vec3(0);
	vec3 single_scattering_albedo=base_color;
	vec3 surface_z=surface_normal;
	vec3 surface_non_z=vec3(1,0,0);
	if (abs(dot(surface_z,surface_non_z))>0.999) {
		surface_non_z=vec3(0,1,0); }
	vec3 surface_x=normalize(cross(surface_z,surface_non_z));
	vec3 surface_y=cross(surface_z,surface_x);
	mat3 basis_change=inverse(mat3(surface_x,surface_y,surface_z));
	// return surface_x;
	vec3 incident_ray=basis_change*(light_direction);
	vec3 outgoing_ray=basis_change*(-outgoing_direction);
	result+=E_EON(single_scattering_albedo,roughness,incident_ray,false);
	result+=f_EON(single_scattering_albedo,roughness,incident_ray,outgoing_ray,false);
	// result=1*texture(sky_samp,ray_to_cubeuv(-vec3(surface_normal.xzy))).xyz+f_EON(vec3(0.2),2.0,incident_ray,outgoing_ray,false);
	return result; }
uniform vec3 camera_position;
uniform float camera_far_clip;
uniform vec3 haze_color;
uniform float metallic_factor;
out vec4 color;
in vec3 position_interpolated;
in vec2 texcoord_interpolated;
in vec3 normal_interpolated;
in vec2 lightmap_texcoord_interpolated;
void main(void) {
	color.w=1.0;
	// TODO: Should this use the corrected camera position vector?
	float depth=distance(position_interpolated,camera_position)/camera_far_clip;
	gl_FragDepth=depth;
	vec3 base_color=texture(diffuse_samp,vec2(texcoord_interpolated.x,-texcoord_interpolated.y)).xyz;
	// base_color=vec3(0.9); // TEMP
	// color.xyz=base_color; return;
	vec3 camera_direction=normalize(position_interpolated-camera_position);
	vec3 rough_component=eon_BRDF(0.62*base_color,camera_direction,normal_interpolated,normalize(vec3(0,0,-1)),2.0);
	vec3 metallic_component=mirror_BRDF(camera_direction,normal_interpolated);
	base_color=mix(rough_component,metallic_component,metallic_factor);
	base_color=mix(base_color,haze_color,clamp((2.0*(depth-1))+1,0.0,1.0));
	base_color=texture(world_position_samp, vec2(lightmap_texcoord_interpolated.x, lightmap_texcoord_interpolated.y)).xyz; // TEMP
	// base_color=vec3(texcoord_interpolated.x, texcoord_interpolated.y, 0);
	color.xyz=base_color; }

}

