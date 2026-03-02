out vec4 color;
uniform vec2 this_buffer_res;
uniform vec4 line_color;
uniform vec4 line;
uniform vec4 mask;
uniform int dashed;
uniform int animate;
uniform float time;
void main(void) {
	if (dashed == 1) {
		vec2 pos = gl_FragCoord.xy;
		vec2 a = vec2(line.x, line.y);
		vec2 b = vec2(line.z, line.w);
		vec2 d = abs(b - a);
		float l = length(d);
		float alpha_h = float(int(pos.x * (l / d.x) + time * 32 * animate) % 16 > 8);
		float alpha_v = float(int(pos.y * (l / d.y) + time * 32 * animate) % 16 > 8);
		color = line_color;
		if (d.x > d.y) {
			color.w = alpha_h;
		}
		else {
			color.w = alpha_v;
		}
	}
	else {
		color = line_color;
	}
	vec2 coords = gl_FragCoord.xy - this_buffer_res / 2;
	/*
	if ((coords.x < mask.x - mask.z / 2) || (coords.x > mask.x + mask.z / 2)) {
		color.w = 0.0;
		//color = vec4(1.0, 0.0, 0.0, 1.0);
	}
	if ((coords.y < mask.y - mask.w / 2) || (coords.y > mask.y + mask.w / 2)) {
		color.w = 0.0;
		//color = vec4(1.0, 0.0, 0.0, 1.0);
	}
	*/
}