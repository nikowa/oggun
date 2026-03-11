layout (binding = 0) uniform sampler2D diffuse_samp;
layout (binding = 1) uniform sampler2D thickness_samp;
layout (binding = 2) uniform sampler2D world_position_samp;
layout (binding = 3) uniform sampler2D sky_samp;
#include <rdf.glsl>
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
