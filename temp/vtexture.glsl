#version 460 core
uniform vec2 pos;
uniform vec2 size;
uniform vec2 res;
out vec2 tex_coord;


vec2 project(vec2 point) {
	return 2*point/res; }


void main(void) {
	float x0=(-0.5*size.x)+pos.x;
	float x1=(0.5*size.x)+pos.x;
	float y0=(-0.5*size.y)+pos.y;
	float y1=(0.5*size.y)+pos.y;
	float frame_width=1.0/num_frames;
	float tex_x0=0;
	float tex_x1=1;
	float tex_y0=0;
	float tex_y1=1;
	vec2 point=vec2(x0,y0);
	vec2 size_ratio=vec2(x1-x0,y1-y0);
	gl_Position.z=depth;
	tex_coord=vec2(tex_x0,tex_y1);
	if((gl_VertexID+1)%6>2){
		point.x=x1;
		tex_coord.x=tex_x1; }
	if(gl_VertexID%2==1){
		point.y=y1;
		tex_coord.y=tex_y0; }
	point=rotate_point(point,pos,rot);
	gl_Position.xy=project(point); }

c2 project(vec2 point) {
	return 2*point/this_buffer_res; }
void main(void) {
	float x0=(-0.5*size.x)+pos.x;
	float x1=(0.5*size.x)+pos.x;
	float y0=(-0.5*size.y)+pos.y;
	float y1=(0.5*size.y)+pos.y;
	float frame_width=1.0/num_frames;
	float tex_x0=frame_width*frame_index;
	float tex_x1=frame_width*(frame_index+1);
	float tex_y0=0;
	float tex_y1=1;
	vec2 point=vec2(x0,y0);
	vec2 size_ratio=vec2(x1-x0,y1-y0);
	gl_Position.z=depth;
	tex_coord=vec2(tex_x0,tex_y1);
	if((gl_VertexID+1)%6>2){
		point.x=x1;
		tex_coord.x=tex_x1; }
	if(gl_VertexID%2==1){
		point.y=y1;
		tex_coord.y=tex_y0; }
	point=rotate_point(point,pos,rot);
	gl_Position.xy=project(point); }

