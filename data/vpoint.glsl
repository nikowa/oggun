uniform vec2 pos;
uniform float size;
uniform vec2 this_buffer_res;
void main(void) {
	float x=(pos.x/this_buffer_res.x)*2;
	float y=(pos.y/this_buffer_res.y)*2;
	gl_Position=vec4(x,y,0,1); }
