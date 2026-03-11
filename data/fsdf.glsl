#define MAX_INDEX 255
#include "effect-common.glsl"
layout(binding=6) uniform sampler2D dev_grid_sampler;
layout(binding=7) uniform sampler2D dev_oriented_grid_sampler;
layout(binding=8) uniform sampler2D background_sampler;
uniform vec3 offset;
uniform vec3 normal;
uniform float height;
uniform float radius;
uniform vec3 point_a;
uniform vec3 point_b;
uniform vec3 point_c;
uniform int sdf_id;
uniform vec3 surface_color;
const float EPSILON=0.02; // low: 0.02, high: 0.001
const float SHADOW_RADIUS=0.02;
const float SHADOW_LIMIT=8.0;
const float DELTA=0.01;
const float HALF_DELTA=DELTA/2;
#define SDF_ID_PLANE 0
#define SDF_ID_SPHERE 1
#define SDF_ID_CAPSULE_Z 2
#define SDF_ID_GROUND_TRIANGLE 3
#define SDF_ID_GROUND 4
#define SDF_ID_MESH 5
#include <util.glsl>
#include <linalg.glsl>
#include <csdf.glsl>
#include <material.glsl>
csd_t csdf_scene(vec3 p,bool displaced) {
	sd_t sd=SDF_CLEAR;
	if (sdf_id==SDF_ID_SPHERE) {
		sd=sdf_sphere(p-offset,radius); }
	if (sdf_id==SDF_ID_GROUND_TRIANGLE) {
		sd=sdf_ground_triangle(p,point_a,point_b,point_c); }
	csd_t csd=csd_t(sd,WATER);
	return csd; }
#include <normal.glsl>
#include <ray.glsl>
#include <camera.glsl>
#include <light.glsl>
color_t shade(vec3 surface,vec3 cone,float near_clip,float far_clip) {
	vec3 surface_offset=surface+cone*near_clip;
	vec3 light_origin_point;
	csd_t csd=cast_ray(surface_offset,cone,far_clip,light_origin_point);
	if (csd.x<EPSILON) {
		color_t result=surface_color;
		float depth=distance(light_origin_point,camera_position)/camera_far_clip;
		gl_FragDepth=depth;
		// result=mix(color_t(1,0,0),color_t(0.5,0,1),clamp(4*depth,0,1));
		// result=color_t(1,0,0);
		result=lambert_BRDF(result,light_origin_point-camera_position,csdf_normal(light_origin_point,true),sun_dir,1.0);
		return result; }
	else {
		float depth=0.999;
		gl_FragDepth=depth;
		return color_t(0); } }
void main(void) {
	color=vec4(0,0,0,0.6);
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

