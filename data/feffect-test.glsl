#include <feffect>
#include <sdf>
#include <noise>
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
	vec3 color = vec3(0);
	float alpha = 1.0;
	// alpha = noise((4 + surface_index) * 0.2 * (position.xy + vec2(surface_index)));
	// alpha = threshold(alpha, 0.0);
	// float t = fractional_noise(position.y + position.x + time);
	// float t = fractional_noise_2d(position.xy, 0.0);
	// float t = grid_noise(position.xy, 1.0, time);
	// float t = linear_fractional_noise(position.x, time);
	float t = smooth_fractional_noise_2d(position.xy, time);
	color = vec3(t);
	return vec4(color, alpha); }
#include <feffect-main>