#include <types.glsl>


const vec3 CAMERA_DEFAULT_POSITION=vec3(0);
const vec3 CAMERA_DEFAULT_DIRECTION=vec3(0,1,0);
const vec3 CAMERA_DEFAULT_UP_DIRECTION=vec3(0,0,1);
const float CAMERA_DEFAULT_FOCAL_LENGTH=1;
const float CAMERA_DEFAULT_LENS_LENGTH=0;
const vec2 CAMERA_DEFAULT_SENSOR_SIZE=vec2(1,1);


vec3 camera_receptor_vector(
		vec2 sensor_point,
		float focal_length,
		vec2 sensor_size,
		vec3 forward_axis,
		vec3 vertical_axis,
		vec3 horizontal_axis) {
	return mat3(horizontal_axis,vertical_axis,forward_axis)*normalize(vec3(
		-0.5*sensor_size.x+sensor_point.x*sensor_size.x,
		-0.5*sensor_size.y+sensor_point.y*sensor_size.y,
		focal_length)); }