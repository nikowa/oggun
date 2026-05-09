layout(location = 0) in vec4 rect;
layout(location = 1) in float depth;
layout(location = 2) in vec4 fill_color;
layout(location = 3) in float rounding;
layout(location = 0) uniform vec2 res;
out vec2 tex_coord;
flat out vec4 _rect;
flat out float _depth;
flat out vec4 _fill_color;
flat out float _rounding;
void main(void) {
	_rect = rect;
	_depth = depth;
	_fill_color = fill_color;
	_rounding = rounding;
	vec2 pos = rect.xy;
	vec2 size = rect.zw;
	float x0 = (float(pos.x - size.x / 2) / res.x) * 2;
	float x1 = (float(pos.x + size.x / 2) / res.x) * 2;
	float y0 = (float(pos.y - size.y / 2) / res.y) * 2;
	float y1 = (float(pos.y + size.y / 2) / res.y) * 2;
	gl_Position = vec4(x0, y0, 0, 1);
	if(gl_VertexID % 6 == 0) {
		gl_Position.xy = vec2(x0, y1);
		tex_coord = vec2(0,0);
	}
	if(gl_VertexID % 6 == 1) {
		gl_Position.xy = vec2(x0, y0);
		tex_coord = vec2(0,1);
	}
	if(gl_VertexID % 6 == 2) {
		gl_Position.xy = vec2(x1, y0);
		tex_coord = vec2(1,1);
	}
	if(gl_VertexID % 6 == 3) {
		gl_Position.xy = vec2(x0, y1);
		tex_coord = vec2(0,0);
	}
	if(gl_VertexID % 6 == 4) {
		gl_Position.xy = vec2(x1, y0);
		tex_coord = vec2(1,1);
	}
	if(gl_VertexID % 6 == 5) {
		gl_Position.xy = vec2(x1, y1);
		tex_coord = vec2(1,0);
	}
}
