layout(location = 0) uniform vec4 points;
layout(location = 1) uniform vec2 res;

void main(void) {
	vec2 half_res = res / 2;
	vec2 a = vec2(
		2.0 * (points.x + half_res.x) / res.x - 1.0,
		2.0 * (points.y + half_res.y) / res.y - 1.0
	);
	vec2 b = vec2(
		2.0 * (points.z + half_res.x) / res.x - 1.0,
		2.0 * (points.w + half_res.y) / res.y - 1.0
	);
	if(gl_VertexID == 0) {
		gl_Position = vec4(a, 0.0, 1.0);
	}
	else {
		gl_Position = vec4(b, 0.0, 1.0);
	}
}
