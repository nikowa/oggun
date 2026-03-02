layout (location = 0) in vec3 position;
out vec2 texCoord;
in vec4 InVertex;
uniform int x;
uniform int y;
uniform int sprite_width;
uniform int sprite_height;
uniform float time;
uniform float time_birth;
uniform float time_death;
uniform int window_width;
uniform int window_height;
void main(void) {
	float x0 = float(x - sprite_width) / window_width;
	float x1 = float(x + sprite_width) / window_width;
	float y0 = float(y - sprite_height) / window_height;
	float y1 = float(y + sprite_height) / window_height;
	if(gl_VertexID == 0) {
 		gl_Position = vec4(x0, y1, 0.0, 1.0);
		texCoord = vec2(0,1);
	}
	else if(gl_VertexID == 1) {
		gl_Position = vec4(x0, y0, 0.0, 1.0);
		texCoord = vec2(0,0);
	}
	else if(gl_VertexID == 2) {
	 	gl_Position = vec4(x1, y1, 0.0, 1.0);
		texCoord = vec2(1,1);
	}
	else if(gl_VertexID == 3) {
		gl_Position = vec4(x1, y0, 0.0, 1.0);
		texCoord = vec2(1,0);
	}
	else if(gl_VertexID == 4) {
	 	gl_Position = vec4(x1, y1, 0.0, 1.0);
		texCoord = vec2(1,1);
	}
	else {
		gl_Position = vec4(x0, y0, 0.0, 1.0);
		texCoord = vec2(0,0);
	}
}
