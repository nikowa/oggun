#include <types.glsl>








vec2 substance_uv = vec2(0,0);
vec2 substance_res = vec2(0,0);
vec3 blend_switch(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_2,t); }
vec3 blend_add(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1+image_2,t); }
vec3 blend_sub(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1-image_2,t); }
vec3 blend_multiply(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1*image_2,t); }
vec3 blend_div(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,image_1/image_2,t); }
vec3 blend_max(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,max(image_1,image_2),t); }
vec3 blend_min(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,min(image_1,image_2),t); }
vec3 blend_screen(vec3 image_1,vec3 image_2,float t) {
	return mix(image_1,vec3(1)-(vec3(1)-image_1)*(vec3(1)-image_2),t); }
vec3 blend_overlay(vec3 image_1,vec3 image_2,float t) {
	return mix(blend_multiply(image_1,image_2,t),blend_screen(image_1,image_2,t),t); }
// vec3 blur(sampler2D tex,float intensity) {
// 	float x_min = substance_uv.x*substance_res.x-intensity/2;
// 	float x_min = substance_uv.x*substance_res.x+intensity/2;
// 	float y_min = substance_uv.y*substance_res.y-intensity/2;
// 	float y_min = substance_uv.y*substance_res.y+intensity/2;
// 	vec3 acc = vec3(0);
// 	float weight = intensity*intensity;
// 	for(float x = x_min; x<=x_max; x = x+1) {
// 		for(float y = y_min; y<=y_max; y = y+1) {
// 			acc += texture(tex,clamp(vec2(x,y),vec2(0,0),substance_res)/substance_res); } }
// 	return acc/weight; }
// vec3 bezier_curve(vec3 image,vec2 cp) {
// 	vec3 op0 = vec3(0);
// 	vec3 op1 = vec3(1);
// 	return mix(,image);
// }
