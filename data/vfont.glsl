layout(location = 0) in float symbol;
layout(location = 1) in vec3 position;
layout(location = 2) in float scale_factor;
layout(location = 3) in vec4 text_color;
layout(location = 0) uniform vec2 symbol_size;
layout(location = 1) uniform vec2 res;
out vec2 tex_coords;
out float frag_symbol;
flat out vec4 frag_text_color;
flat out vec2 quad_size;
void main(void) {
	frag_symbol = symbol;
	frag_text_color = text_color;
	int j = gl_VertexID / 6;
	float x = (float(position.x) / res.x) * 2;
	float y = (float(position.y) / res.y) * 2;
	float z = position.z;
	float w = (symbol_size.x / res.x) * 2 * scale_factor;
	float h = (symbol_size.y / res.y) * 2 * scale_factor;
	quad_size = vec2(w, h) * res;
	float half_w = 0.5 * w;
	float half_h = 0.5 * h;
	tex_coords = vec2(0, 0);
	if((gl_VertexID % 6) == 0) {
		gl_Position = vec4(x, y + h, z, 1);
		tex_coords = vec2(0, 0); }
	else if((gl_VertexID % 6) == 1) {
		gl_Position = vec4(x, y, z, 1);
		tex_coords = vec2(0, 1); }
	else if((gl_VertexID % 6) == 2) {
		gl_Position = vec4(x + w, y, z, 1);
		tex_coords = vec2(1, 1); }
	else if((gl_VertexID % 6) == 3) {
		gl_Position = vec4(x, y + h, z, 1);
		tex_coords = vec2(0, 0); }
	else if((gl_VertexID % 6) == 4) {
		gl_Position = vec4(x + w, y, z, 1);
		tex_coords = vec2(1, 1); }
	else if((gl_VertexID % 6) == 5) {
		gl_Position = vec4(x + w, y + h, z, 1);
		tex_coords = vec2(1, 0); }
	tex_coords.y = 1.0 - tex_coords.y; }
