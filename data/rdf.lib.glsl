#include <cubemap>


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


// omega_out -- outgoing_direction
// omega_in -- ingoing_direction
vec3 jensen_BSSRDF(vec3 omega_out,vec3 omega_in) {
	return vec3(0);
}


vec3 eon_BRDF(vec3 base_color, vec3 outgoing_direction, vec3 surface_normal, vec3 light_direction, float roughness) {
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
