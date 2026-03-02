

#define NORMAL_DELTA 0.01
#define NORMAL_HALF_DELTA (0.5*NORMAL_DELTA)


// vec3 csdf_normal_cheap(vec3 point,vec3 sd,bool displaced) {
// 	return normalize(vec3(
// 		csdf_scene(vec3(point.x+NORMAL_DELTA,point.yz),displaced).x-sd,
// 		csdf_scene(vec3(point.x,point.y+NORMAL_DELTA,point.z),displaced).x-sd,
// 		csdf_scene(vec3(point.xy,point.z+NORMAL_DELTA),displaced).x-sd)); }


vec3 csdf_normal(vec3 point,bool displaced) {
	return normalize(vec3(
		csdf_scene(vec3(point.x+NORMAL_HALF_DELTA,point.yz),displaced).x-
		csdf_scene(vec3(point.x-NORMAL_HALF_DELTA,point.yz),displaced).x,
		csdf_scene(vec3(point.x,point.y+NORMAL_HALF_DELTA,point.z),displaced).x-
		csdf_scene(vec3(point.x,point.y-NORMAL_HALF_DELTA,point.z),displaced).x,
		csdf_scene(vec3(point.xy,point.z+NORMAL_HALF_DELTA),displaced).x-
		csdf_scene(vec3(point.xy,point.z-NORMAL_HALF_DELTA),displaced).x)); }

