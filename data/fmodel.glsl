layout (binding = 0) uniform sampler2D diffuse_samp;
layout (binding = 1) uniform sampler2D thickness_samp;
layout (binding = 2) uniform sampler2D world_position_samp;
layout (binding = 3) uniform sampler2D sky_samp;
#include <rdf>
layout(location = 3) uniform vec3 camera_position;
layout(location = 4) uniform float camera_far_clip;
layout(location = 5) uniform vec3 haze_color;
layout(location = 6) uniform float metallic_factor;
layout(location = 7) uniform float roughness_factor;
out vec4 color;
out float emission;
in vec3 position_interpolated;
in vec3 scr_position_interpolated;
in vec3 scr_normal_interpolated;
in vec2 texcoord_interpolated;
in vec3 normal_interpolated;
in vec2 lightmap_texcoord_interpolated;

vec3 f_niko(vec3 rho, float r, vec3 wi_local, vec3 wo_local, bool exact) {
	const float DEFAULT_SHARPNESS = 0.75;
	float sharpness = 0.9;
	sharpness = clamp(sharpness, 0.0, 1.0);
	float mu_i = wi_local.z;
	float mu_o = clamp(sign(wo_local.z) * abs(pow(wo_local.z, mix(4.0, 0.01, sharpness))), 0.0, 1.0);
	float s = dot(wi_local, wo_local) - mu_i * mu_o;
	// DICK
	// return vec3(1.0) * wi_local.z;
	// return vec3(1.0) * mix((1.0 - (sharpness - DEFAULT_SHARPNESS)) * mu_o, mu_o, pow(mu_o, 2.0));
	// return vec3(1.0) * (1.0 + 1.0 * (sharpness - 0.25)) * sign(mu_o) * abs(pow(mu_o, mix(0.01, 4.0, sharpness)));
	float sovertF = (s > 0.0f) ? (s / abs(max(mu_i, mu_o))) : s;
	float AF = 1.0f / (1.0f + constant1_FON * r);
	vec3 f_ss = (rho / PI) * AF * (1.0f + r * sovertF);
	// return vec3(1.0) * (1.0f + r * sovertF);

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

vec3 E_niko(vec3 rho, float r, vec3 wi_local, bool exact) {
	float mu_i = wi_local.z;
	float AF = 1.0f / (1.0f + constant1_FON * r);
	float EF = exact ? E_FON_exact(mu_i, r) : E_FON_approx(mu_i, r);
	float avgEF = AF * (1.0f + constant2_FON * r);
	vec3 rho_ms = (rho * rho) * avgEF / (vec3(1.0f) - rho * (1.0f - avgEF));
	return rho * EF + rho_ms * (1.0f - EF); }

vec3 niko_BRDF(vec3 base_color, vec3 outgoing_direction, vec3 surface_normal, vec3 light_direction, float roughness) {
	vec3 result = vec3(0);
	vec3 single_scattering_albedo = base_color;
	vec3 surface_z = surface_normal;
	vec3 surface_non_z = vec3(1, 0, 0);
	if (abs(dot(surface_z, surface_non_z)) > 0.999) {
		surface_non_z = vec3(0, 1, 0); }
	vec3 surface_x = normalize(cross(surface_z, surface_non_z));
	vec3 surface_y = cross(surface_z, surface_x);
	mat3 basis_change = inverse(mat3(surface_x, surface_y, surface_z));
	// return surface_x;
	vec3 incident_ray = basis_change * (light_direction);
	vec3 outgoing_ray = basis_change * (-outgoing_direction);
	// result += E_niko(single_scattering_albedo, roughness, incident_ray, false);
	result += f_niko(single_scattering_albedo, roughness, incident_ray, outgoing_ray, false);
	return result; }

void main(void) {
	color.w = 1.0;
	float depth = length(scr_position_interpolated) / camera_far_clip;
	depth = -scr_position_interpolated.z;
	// depth = 0.4;
	gl_FragDepth = gl_FragCoord.z;
	// color.xyz = 1 * vec3(depth); return;
	// if (depth > 0.79) color.xyz = vec3(1, 0, 0);
	// color.xyz = vec3(8 * gl_FragCoord.z) / 1.0;
	// return;
	// color.xyz = vec3(-scr_position_interpolated.z / camera_far_clip); return;
	vec3 base_color = texture(diffuse_samp, vec2(texcoord_interpolated.x, -texcoord_interpolated.y)).xyz;
	base_color = vec3(0.8);
	vec3 camera_direction = normalize(position_interpolated - camera_position);
	vec3 light_direction = normalize(vec3(1, 0, 1));
	vec3 rough_component = lambert_BRDF(0.62 * base_color, camera_direction, normal_interpolated, light_direction, 1.0);
	// (TODO): "camera_position" is not set. Fix this.
	// color.xyz = position_interpolated; return;
	// color.xyz = vec3(1, 0, 0); return; // TODO
	// color.xyz = normal_interpolated; return;
	// color.xyz = vec3(dot(camera_direction, normal_interpolated)); return;
	// color.xyz = vec3(dot(scr_normal_interpolated, vec3(0,0,1))); return;
	color.xyz = rough_component; return;
	vec3 metallic_component=mirror_BRDF(camera_direction, normal_interpolated);
	base_color = mix(rough_component, metallic_component, metallic_factor);
	base_color = mix(base_color, haze_color, clamp((2.0 * (depth - 1)) + 1, 0.0, 1.0));
	// base_color = texture(world_position_samp, vec2(lightmap_texcoord_interpolated.x, lightmap_texcoord_interpolated.y)).xyz; // TEMP
	// base_color=vec3(texcoord_interpolated.x, texcoord_interpolated.y, 0);
	base_color = 0.5 * (normal_interpolated + vec3(1, 1, 1)); // TEMP
	color.xyz = base_color;
}
