layout(location=0) out float d_surf;
layout(location=1) out float d_surf_displaced;
layout(location=2) out float d_surfer;
layout(location=3) out vec3 n_surf;
layout(location=4) out vec3 n_surf_displaced;
in vec2 tex_coord;
uniform vec3 surfer_position;
uniform vec3 surf_position;
uniform vec3 surf_direction;
uniform vec3 surf_up_direction;
uniform vec3 surf_side_direction;
uniform float time;
const int STEPS_LIMIT=240;
const float EPSILON=0.02; // low: 0.02, high: 0.001
const float SHADOW_RADIUS=0.02;
const float SHADOW_LIMIT=8.0;
const float DELTA=0.01;
const float HALF_DELTA=DELTA/2;
const int NORMAL=0;
const int BINORMAL=1;
const int TANGENT=2;
float pixel_seed;
#define PHYSICS
#include <util.glsl>
#include <linalg.glsl>
#include <csdf.glsl>
// #include <material.glsl>
#include <scene-water.glsl>
#include <normal.glsl>
// #include <ray.glsl>
// #include <camera.glsl>
// #include <light.glsl>








void main(void) {
	d_surf=csd_distance(csdf_scene(surf_position,false));
	d_surf_displaced=csd_distance(csdf_scene(surf_position,true));
	d_surfer=csd_distance(csdf_scene(surfer_position,true));
	n_surf=csdf_normal(surf_position,false);
	n_surf_displaced=csdf_normal(surf_position,true); }

