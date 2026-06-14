
vec2 mh_rect(int index, vec2 position, vec2 size) {
	vec2 vertex = vec2(0);
	float x0 = (2 * position.x - size.x);
	float x1 = (2 * position.x + size.x);
	float y0 = (2 * position.y - size.y);
	float y1 = (2 * position.y + size.y);
	if(index == 0) vertex = vec2(x0, y1);
	if(index == 1) vertex = vec2(x0, y0);
	if(index == 2) vertex = vec2(x1, y0);
	if(index == 3) vertex = vec2(x0, y1);
	if(index == 4) vertex = vec2(x1, y0);
	if(index == 5) vertex = vec2(x1, y1);
	return vertex; }

vec2 mh_rect_uved(int index, vec2 position, vec2 size, out vec2 uv) {
	vec2 vertex = vec2(0);
	float x0 = (2 * position.x - size.x);
	float x1 = (2 * position.x + size.x);
	float y0 = (2 * position.y - size.y);
	float y1 = (2 * position.y + size.y);
	if(index == 0) { vertex = vec2(x0, y1); uv = vec2(0, 0); }
	if(index == 1) { vertex = vec2(x0, y0); uv = vec2(0, 1); }
	if(index == 2) { vertex = vec2(x1, y0); uv = vec2(1, 1); }
	if(index == 3) { vertex = vec2(x0, y1); uv = vec2(0, 0); }
	if(index == 4) { vertex = vec2(x1, y0); uv = vec2(1, 1); }
	if(index == 5) { vertex = vec2(x1, y1); uv = vec2(1, 0); }
	return vertex; }
