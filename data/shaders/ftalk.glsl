uniform vec2 this_buffer_res;
uniform vec2 size;
uniform vec2 pos;
uniform vec2 arrow;
in vec2 tex_coord;
out vec4 color;
void main (void) {
	float scr_ratio = this_buffer_res.x/this_buffer_res.y;
	vec2 scr_point = (gl_FragCoord.xy/this_buffer_res) * 2.0 - vec2(1,1);
	scr_point.x = scr_point.x * scr_ratio;
	color = vec4(1,1,1,1);
}
