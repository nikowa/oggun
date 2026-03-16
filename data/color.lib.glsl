#include <types>
#include <util>








float posterize(float t,int n) {
	return round(n*t)/n; }
vec3 posterize(vec3 c,int n) {
	return vec3(round(n*c.x)/n,round(n*c.y)/n,round(n*c.z)/n); }
vec3 saturation(vec3 rgb,float adjustment) {
	const vec3 w=vec3(0.2125,0.7154,0.0721);
	vec3 intensity=vec3(dot(rgb,w));
	return mix(intensity,rgb,adjustment); }
// TODO:
// - saturation
// - contrast
// - lightness
// - highlights & shadows
// - temperature
// - tint
// - brightness
// - vibrance
// - tone curve
// - per-color hue, saturation, luminance
// - color grading
// - calibration