layout(binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
out vec4 color;
flat in float _depth;
flat in vec4 _rect;

#include <msaa>

#define rect _rect

void main(void) {

	msaa8_scope_begin(color, 2 * rect.zw)
		color += texture(samp, tex_coord + 1 * msaa8_off);
	msaa8_scope_end(color)

	// color = texture(samp, tex_coord);
	gl_FragDepth = _depth;
	if (color.w == 0.0) {
		gl_FragDepth = 1.0; } }
