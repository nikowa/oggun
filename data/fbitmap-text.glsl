layout (binding = 0) uniform sampler2D samp;

layout (location = 0) uniform vec2 res;

in vec2 tex_coords;
flat in uint _symbol;
flat in vec4 _text_color;
out vec4 color;

void main(void) {
	color.w = 1.0;
	vec2 offset = vec2(_symbol % 16, _symbol / 16 - 15);
	vec2 uv = vec2(tex_coords.x, 1 - tex_coords.y);
	uv /= 16;
	uv.x += float(_symbol % 16) / 16;
	uv.y += float(_symbol / 16) / 16;
	color = texture(samp, uv);
	color *= _text_color; }
