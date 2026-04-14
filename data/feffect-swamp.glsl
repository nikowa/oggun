#include <feffect>
#include <sdf>
#define RGB(r, g, b) vec3(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0)
float threshold(float x, float t) {
	return (x > t) ? 1.0 : 0.0; }
vec2 hash(vec2 p) {
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0*fract(sin(p)*43758.5453123); }
float noise(vec2 p) {
	const float K1 = 0.366025404; // (sqrt(3)-1)/2;
	const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2  i = floor( p + (p.x+p.y)*K1 );
	vec2  a = p - i + (i.x+i.y)*K2;
	float m = step(a.y,a.x);
	vec2  o = vec2(m,1.0-m);
	vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0*K2;
	vec3  h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3  n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
	return dot( n, vec3(70.0) ); }
vec4 effect_color() {
	vec3 green = RGB(43, 90, 87);
	vec3 yellow = RGB(174, 152, 56);
	vec3 color = green;
	color = vec3(0);
	vec2 grid_size = { 8, 8 };
	color.xy = uv * grid_size;
	sd_t d = sdf_rect(uv, vec2(1.0) / grid_size);
	float alpha = 1.0;
	if (d > 0.0) {
		color = yellow; }
	else {
		color = green; }
	color -= 0.5 * vec3(-position.z);
	alpha = noise((4 + surface_index) * 0.2 * (position.xy + vec2(surface_index)));
	alpha = threshold(alpha, 0.0);
	return vec4(color, alpha); }
#include <feffect-main>