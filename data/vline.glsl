uniform vec4 line;
uniform vec2 this_buffer_res;
void main(void) {
	vec2 half_this_buffer_res = this_buffer_res / 2;
	vec2 a = vec2(
		2.0 * (line.x + half_this_buffer_res.x) / this_buffer_res.x - 1.0,
		2.0 * (line.y + half_this_buffer_res.y) / this_buffer_res.y - 1.0
	);
	vec2 b = vec2(
		2.0 * (line.z + half_this_buffer_res.x) / this_buffer_res.x - 1.0,
		2.0 * (line.w + half_this_buffer_res.y) / this_buffer_res.y - 1.0
	);
	if(gl_VertexID == 0) {
		gl_Position = vec4(a, 0.0, 1.0);
	}
	else {
		gl_Position = vec4(b, 0.0, 1.0);
	}
}
