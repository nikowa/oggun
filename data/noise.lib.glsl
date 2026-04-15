#include <types>







// - Perlin Noise
// - Fractal Noise
// - Simplex Noise
// - Voronoi Noise
// - Worley Noise
// - Anisotropic Noise
// What patterns occur in nature? How can I recreate them mathematically?
// A procedural texture is a texture that is produced by a combination of
// noise (an image produced by a series of transformations on a position map)
// and per-pixel mathematical functions.
#define BYTE_0(x) ((x<<24)>>24)
#define BYTE_1(x) ((x<<16)>>24)
#define BYTE_2(x) ((x<<8)>>24)
#define BYTE_3(x) (x>>24)
#define FNV32_BASE 0x811c9dc5
#define FNV32_PRIME 8378171
// NOTE Primtes that produce good noise when the input is the pixel coordinate: //
// 4712299
// 6130699
// 1639087
// 9711179
// 7094251
// 8378171
// 3104851
float int_ratio(int x) { return 0.5*(float(x)/float(0x7fffffff))+0.5; }
int hash_i(int value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value);
	hash=(hash*FNV32_PRIME)^BYTE_1(value);
	hash=(hash*FNV32_PRIME)^BYTE_2(value);
	hash=(hash*FNV32_PRIME)^BYTE_3(value);
	return hash; }
int hash_ivec2(ivec2 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	return hash; }
int hash_ivec3(ivec3 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.z);
	return hash; }
int hash_ivec4(ivec4 value) {
	int hash=FNV32_BASE;
	hash=(hash*FNV32_PRIME)^BYTE_0(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.x);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.y);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.z);
	hash=(hash*FNV32_PRIME)^BYTE_0(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_1(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_2(value.w);
	hash=(hash*FNV32_PRIME)^BYTE_3(value.w);
	return hash; }
/*
float perlin_noise_3d(ivec3 pos) {
	int X = floor(pos.x) & 255; // x % 255
}
*/
vec2 random_vec2(int seed) { return vec2(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255); }
vec3 random_vec3(int seed) { return vec3(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255,float(BYTE_2(seed))/255); }
vec4 random_vec4(int seed) { return vec4(float(BYTE_0(seed))/255,float(BYTE_1(seed))/255,float(BYTE_2(seed))/255,float(BYTE_3(seed))/255); }
const vec3 random_dirs[32] = vec3[32](
	vec3(0.00890501,  0.33932587,-0.2680479),
	vec3(0.33795923, -0.14174385,-0.05775675),
	vec3(0.24685223, -0.06839859, 0.037358),
	vec3(-0.35588088, 0.19096668, 0.02873264),
	vec3(-0.12825991, 0.21726794,-0.14824965),
	vec3(-0.03502917,-0.27566954,-0.07298317),
	vec3(-0.22338162,-0.17904491, 0.18859502),
	vec3(-0.16541397,-0.01115536, 0.36213034),
	vec3( 0.00417482, 0.15908165,-0.12566535),
	vec3(0.15844095, -0.06645189,-0.02707733),
	vec3(0.11572846, -0.0320664,  0.01751405),
	vec3(-0.16684291, 0.08952838, 0.01347034),
	vec3(-0.06013039, 0.10185885,-0.06950192),
	vec3(-0.01642226,-0.1292385, -0.03421573),
	vec3(-0.10472504,-0.08393925, 0.0884165),
	vec3(-0.07754884,-0.00522982, 0.16977276),
	vec3(0.16303464,  0.07938476, 0.0145593),
	vec3(-0.07879107,-0.11984104, 0.16595457),
	vec3(0.00567464, -0.1356574,  0.04361052),
	vec3(0.09771088,  0.03990721, 0.14736905),
	vec3(-0.16259318, 0.01009632,-0.01436057),
	vec3(-0.15455663, 0.04991017, 0.1245326),
	vec3(0.0328222,  -0.0847218,  0.12002946),
	vec3(0.00335348,  0.00384542, 0.08935784),
	vec3(-0.12433664, 0.11287646, 0.06472793),
	vec3(0.10138854, -0.10890599, 0.10678017),
	vec3(-0.10900923,-0.14777506, 0.12544872),
	vec3(0.12758758,  0.13297441,-0.00992011),
	vec3(-0.07979501,-0.17407095, 0.05146146),
	vec3(0.07766119,  0.11850656,-0.07703004),
	vec3(-0.10057095, 0.049205,   0.10773038),
	vec3(0.16374578, -0.12341746,-0.00628171));
float fractional_noise(float t, float seed) {
	return fract(sin(t + 0.00001 * seed) * 128282); }
float smoothstep(float t) {
	float y = clamp(t, 0.0, 1.0);
	return y * y * (3.0 - 2.0 * y); }
float linear_fractional_noise(float t, float seed) {
	float i = floor(t);
	return mix(fractional_noise(i, seed), fractional_noise(i + 1, seed), fract(t)); }
float smooth_fractional_noise(float t, float seed) {
	float i = floor(t);
	return mix(fractional_noise(i, seed), fractional_noise(i + 1, seed), smoothstep(fract(t))); }
float fractional_noise_2d(vec2 t, float seed) {
	float w = fractional_noise(1.0 + 0.000001 * seed, 0.0);
	return fract(sin(dot(t.xy, 1000.0 * vec2(cos(w), sin(w)))) * 43758.5453123); }
float linear_fractional_noise_2d(vec2 t, float seed) {
	vec2 i = floor(t);
	vec2 f = fract(t);
	float a = fractional_noise_2d(i, seed);
	float b = fractional_noise_2d(i + vec2(1, 0), seed);
	float c = fractional_noise_2d(i + vec2(0, 1), seed);
	float d = fractional_noise_2d(i + vec2(1, 1), seed);
	return mix(a, b, f.x) +
	    (c - a)* f.y * (1 - f.x) +
	    (d - b) * f.x * f.y; }
float smooth_fractional_noise_2d(vec2 t, float seed) {
	vec2 i = floor(t);
	vec2 f = fract(t);
	float a = fractional_noise_2d(i, seed);
	float b = fractional_noise_2d(i + vec2(1, 0), seed);
	float c = fractional_noise_2d(i + vec2(0, 1), seed);
	float d = fractional_noise_2d(i + vec2(1, 1), seed);
	f = f * f * (vec2(3) - 2 * f);
	return mix(a, b, f.x) +
	    (c - a)* f.y * (1 - f.x) +
	    (d - b) * f.x * f.y; }
float grid_noise(vec2 t, float scale, float seed) {
	t /= scale;
	t.x = floor(t.x);
	t.y = floor(t.y);
	return fract(sin(dot(t.xy + vec2(0.000001 * seed), vec2(12.9898, 78.233))) * 43758.5453123); }
