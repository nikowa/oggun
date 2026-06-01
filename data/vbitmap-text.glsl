layout(location = 0) in uint symbol;
layout(location = 1) in vec4 text_color;
layout(location = 2) in float scale_factor;
layout(location = 3) in vec3 position;
layout(location = 4) in uint italic;
layout(location = 5) in uint bold;
layout(location = 6) in float angle;
layout(location = 7) in vec2 uv_offset;
layout(location = 8) in vec4 clip;

layout(location = 0) uniform vec2 res;
layout(location = 1) uniform vec2 symbol_size;
layout(location = 2) uniform float time;

out vec4 gl_Position;

out vec2 tex_coords;
flat out uint _symbol;
flat out vec4 _text_color;
flat out vec2 quad_size;
flat out uint _bold;
flat out vec2 _uv_offset;
flat out vec4 _clip;

void main(void) {
	_symbol = symbol;
	_text_color = text_color;
	_bold = bold;
	_clip = clip;

	int j = gl_VertexID / 6;
	float w = (symbol_size.x / res.x) * 2 * scale_factor;
	float h = (symbol_size.y / res.y) * 2 * scale_factor;
	float x = (float(position.x) / res.x) * 2 + w / 2;
	float y = (float(position.y) / res.y) * 2 + h / 2;
	float z = position.z;
	quad_size = vec2(w, h) * res;
	_uv_offset = uv_offset;
	tex_coords = vec2(0, 0);
	float italic_offset = float(italic) * 0.16 * h;
	mat2 angle_mat = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	vec2 vertex;
	if((gl_VertexID % 6) == 0) {
		vertex = vec2(-1, 1);
		tex_coords = vec2(0, 0); }
	else if((gl_VertexID % 6) == 1) {
		vertex = vec2(-1, -1);
		tex_coords = vec2(0, 1); }
	else if((gl_VertexID % 6) == 2) {
		vertex = vec2(1, -1);
		tex_coords = vec2(1, 1); }
	else if((gl_VertexID % 6) == 3) {
		vertex = vec2(-1, 1);
		tex_coords = vec2(0, 0); }
	else if((gl_VertexID % 6) == 4) {
		vertex = vec2(1, -1);
		tex_coords = vec2(1, 1); }
	else if((gl_VertexID % 6) == 5) {
		vertex = vec2(1, 1);
		tex_coords = vec2(1, 0); }
	vertex *= angle_mat;
	vertex *= vec2(w, h) / 2;
	vertex += vec2(x, y);
	gl_Position.xy = vertex;
	gl_Position.z = z;
	gl_Position.w = 1;
	tex_coords.y = 1.0 - tex_coords.y; }
