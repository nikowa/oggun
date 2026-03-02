out vec4 color;
in vec2 texCoord;
layout (binding = 0) uniform sampler2D samp0;
layout (binding = 1) uniform sampler2D samp1;
layout (binding = 2) uniform sampler2D samp2;
uniform int x;
uniform int y;
uniform int sprite_width;
uniform int sprite_height;
uniform float time;
uniform float time_birth;
uniform float time_death;
uniform int window_width;
uniform int window_height;
#define N 8
const float line_length = 6.0;
const float line_girth = 0.5;
struct line2 {
	vec2 pos;
	vec2 dir;
};
struct line3 {
	vec3 pos;
	vec3 dir;
};
float hb(vec3 sides) {
	float a = sides.x;
	float b = sides.y;
	float c = sides.z;
	float p = (a + b + c) / 2;
	return 2 * sqrt(p * (p - a) * (p - b) * (p - c)) / b;
}
vec3 sides(vec2 X, vec2 pos, vec2 posdir) {
	vec3 s;
	s.x = length(X - pos);
	s.y = length(pos - posdir);
	s.z = length(X - posdir);
	return s;
}
float extent(float a, float h) {
	return sqrt(a*a - h*h);
}
int tile_size = window_height / 8;
// Determines the position along the tile border. The interpolation variable a ranges from 0 to 1.
vec2 border_position(float a) {
	a *= 4;
	// Go to center of quad:
	vec2 center = gl_FragCoord.xy - (vec2(window_width, window_height) + vec2(x, y)) / 2;
	center = vec2(0.0, 0.0);
	// Compute the corners of the tile starting from lower left and proceding clock-wise:
	vec2 A = center + vec2(-tile_size/2, -tile_size/2);
	vec2 B = center + vec2(-tile_size/2, tile_size/2);
	vec2 C = center + vec2(tile_size/2, tile_size/2);
	vec2 D = center + vec2(tile_size/2, -tile_size/2);
	// Interpolate:
	if((a >= 0) && (a < 1))
		return mix(A, B, a);
	if((a >= 1) && (a < 2))
		return mix(B, C, a - 1);
	if((a >= 2) && (a < 3))
		return mix(C, D, a - 2);
	if((a >= 3) && (a < 4))
		return mix(D, A, a - 3);
	return A;
}
vec3 draw_line(line2 l) {
	vec3 col = vec3(0.0, 0.0, 0.0);
	vec3 s = sides(gl_FragCoord.xy - (vec2(window_width, window_height) + vec2(x, y)) / 2, l.pos, l.pos + l.dir);
	float h = hb(s);
	if(h < line_girth)
		col.xyz = vec3(1.0, 0.98, 0.7);
	if(extent(s.x, h) > length(l.dir))
		col.xyz = vec3(0.0, 0.0, 0.0);
	return col;
}
void main (void) {
	color = vec4(0.0, 0.0, 0.0, 1.0);
	float as[N];
	for(int i = 0; i < N; i ++) {
		as[i] = (sin((time_birth * 10 + i) * 7.77) * cos((time_birth * 10 + i) * 3.33)) / 2 + 0.5;
	}
	line2 ls[N];
	vec3 pos3s[N];
	vec3 dir3s[N];
	float t = time - time_birth;
	for(int i = 0; i < N; i ++) {
		vec2 bp = border_position(as[i]);
		float verpos = abs(sin(t * 4)) * tile_size / 4;
		float verdir = (sin(t * 4) * cos(t * 4)) / (abs(sin(t * 4))) * tile_size / 4;
		pos3s[i] = vec3(bp, 0.0) + vec3(bp * t * 4 * (as[i] + 0.5), verpos);
		ls[i] = line2(pos3s[i].xy + vec2(0.0, pos3s[i].z), (bp + vec2(0.0, verdir * 4)) / tile_size * line_length);
	}
	for(int i = 0; i < N; i ++) {
		color.xyz += draw_line(ls[i]);
	}
	float mask = length(color.xyz);
	color.w = mask;
	clamp(color.w, 0, 1);
	color.w *= pow(2, -pow((t * 4), 8));
	color = color_correct(color);
}
