layout (binding = 0) uniform sampler2D samp;
uniform int symbol;
uniform vec4 text_color;
in vec2 tex_coords;
out vec4 color;
vec2 invert_y(vec2 vec) {
	return vec2(vec.x,1-vec.y); }
vec2 offset=vec2(symbol%16,symbol/16-15);
vec2 sample_bitmap(vec2 uv) {
	return texture(samp,(vec2(uv.x/16,1-uv.y/16)+offset/16)).xw; }
void main(void) {
	//color=text_color;
	vec2 bitmap_sample=sample_bitmap(tex_coords);
	color.xyz=vec3(bitmap_sample.x)*text_color.xyz;
	color.w=bitmap_sample.y; }
