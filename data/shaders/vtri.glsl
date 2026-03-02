uniform vec2 point_a;
uniform vec2 point_b;
uniform vec2 point_c;
uniform vec2 this_buffer_res;
void main(void) {
	vec2 p;
	if(gl_VertexID == 0) {
		p = 2 * point_a / this_buffer_res;
	}
	else if(gl_VertexID == 1) {
		p = 2 * point_b / this_buffer_res;
	}
	else if(gl_VertexID == 2) {
		p = 2 * point_c / this_buffer_res;
	}
	gl_Position = vec4(p, 0.0, 1.0);
}
