layout (binding = 0) uniform sampler2D samp;
uniform vec2 this_buffer_res;
in vec2 tex_coord;
out vec4 color;
const float PI = 3.14159265;
const float TWO_PI = 6.28318530;
const float HALF_PI = 1.57059632;
const float DIST_AMPLITUDE = 0.5; // distance ranges from -DA to +DA.
float flat_step(float e0, float e1, float x) {
	return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}
vec4 display_sdf(float d, float e0, float e1) {
	d = flat_step(e0, e1, d);
	vec4 p = vec4(0.0, 0.0, 1.0, 1.0);
	vec4 n = vec4(1.0, 0.0, 0.0, 1.0);
	vec4 z = vec4(0.0, 0.0, 0.0, 1.0);
	if(d > 0.0) {
		return mix(z, p, d);
	} else {
		return mix(z, n, -d);
	}
}
void main (void) {
	color = vec4(0.0, 0.0, 0.0, 1.0);
	vec2 u = (gl_FragCoord.xy / this_buffer_res);
	float c = texture(samp, u).x;
//	color.xyz = vec3(c,c,c); return;
	const float ds = 0.01;
	const float da = PI / 128.0;
//	const float da = PI / 4.0;
	float d = 0.0;
	bool found = false;
	if(c < 0.5) {
		for(float s = 0.0; (s <= 1.0) && !found; s += ds) {
			for(float a = 0.0; (a <= TWO_PI) && !found; a += da) {
				vec2 v = u + vec2(
					cos(a) * s,
					sin(a) * s);
//				v = vec2(clamp(v.x,0,1),clamp(v.y,0,1));
				if(texture(samp, v).x > 0.5) {
					d = length(u - v) * 1.0;
					found = true;
				}
			}
		}
	} else {
		for(float s = 0.0; (s <= 1.0) && !found; s += ds) {
			for(float a = 0.0; (a <= TWO_PI) && !found; a += da) {
				vec2 v = u + vec2(
					cos(a) * s,
					sin(a) * s);
//				v = vec2(clamp(v.x,0,1),clamp(v.y,0,1));
				if(texture(samp, v).x < 0.5) {
					d = -length(u - v) * 1.0;
					found = true;
				}
			}
		}
	}
	d = (d + 1.0) * DIST_AMPLITUDE;
//	color = display_sdf(d, 0.0, 2.0);
	color.xyz = vec3(d, d, d);
}
