layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 size;
layout(location = 0) uniform vec2 res;
// layout(location = 0) uniform vec2 pos;
// layout(location = 1) uniform vec2 size;
// layout(location = 2) uniform vec2 res;
out vec2 tex_coord;

void main(void) {
	float x0 = (float(pos.x - size.x / 2) / res.x) * 2;
	float x1 = (float(pos.x + size.x / 2) / res.x) * 2;
	float y0 = (float(pos.y - size.y / 2) / res.y) * 2;
	float y1 = (float(pos.y + size.y / 2) / res.y) * 2;
	gl_Position = vec4(x0, y0, 0, 1);
	if(gl_VertexID == 0) {
		gl_Position.xy = vec2(x0, y1);
		tex_coord = vec2(0,0);
	}
	if(gl_VertexID == 1) {
		gl_Position.xy = vec2(x0, y0);
		tex_coord = vec2(0,1);
	}
	if(gl_VertexID == 2) {
		gl_Position.xy = vec2(x1, y0);
		tex_coord = vec2(1,1);
	}
	if(gl_VertexID == 3) {
		gl_Position.xy = vec2(x0, y1);
		tex_coord = vec2(0,0);
	}
	if(gl_VertexID == 4) {
		gl_Position.xy = vec2(x1, y0);
		tex_coord = vec2(1,1);
	}
	if(gl_VertexID == 5) {
		gl_Position.xy = vec2(x1, y1);
		tex_coord = vec2(1,0);
	}
}
