uniform int symbol;
uniform vec3 pos;
uniform vec2 symbol_size;
uniform vec2 this_buffer_res;
out vec2 tex_coords;
void main(void) {
	int i = symbol;
	int j = gl_VertexID / 6;
//	float x = (pos.x + this_buffer_res.x / 2) / (this_buffer_res.x / 2) - 1;
//	float y = (pos.y + this_buffer_res.y / 2) / (this_buffer_res.y / 2) - 1;
//	float x = (2*pos.x/this_buffer_res.x);
//	float y = (2*pos.y/this_buffer_res.y);
	float x=(float(pos.x)/this_buffer_res.x)*2;
	float y=(float(pos.y)/this_buffer_res.y)*2;
	float z=pos.z;
	float w=(symbol_size.x/this_buffer_res.x)*2;
	float h=(symbol_size.y/this_buffer_res.y)*2;
	float half_w=0.5*w;
	float half_h=0.5*h;
	if((gl_VertexID % 6) == 0) {
		gl_Position = vec4(x-half_w,y+half_h,z,1);
		tex_coords = vec2(0,0); }
	else if((gl_VertexID % 6) == 1) {
		gl_Position = vec4(x-half_w,y-half_h,z,1);
		tex_coords = vec2(0,1); }
	else if((gl_VertexID % 6) == 2) {
		gl_Position = vec4(x+half_w,y-half_h,z,1);
		tex_coords = vec2(1,1); }
	else if((gl_VertexID % 6) == 3) {
		gl_Position = vec4(x-half_w,y+half_h,z,1);
		tex_coords = vec2(0,0); }
	else if((gl_VertexID % 6) == 4) {
		gl_Position = vec4(x+half_w,y-half_h,z,1);
		tex_coords = vec2(1,1); }
	else if((gl_VertexID % 6) == 5) {
		gl_Position = vec4(x+half_w,y+half_h,z,1);
		tex_coords = vec2(1,0); }
	tex_coords.y = 1.0 - tex_coords.y; }
