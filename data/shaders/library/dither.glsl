/*
bool dither_mask(ivec2 uv,float t) {
	uv += ivec2(int(sin(t*123)*123),int(sin(t*321)*321));
	uv = ivec2(uv.x%3,uv.y%3);
	return (uv.x+uv.y)%2==0; }
ivec2 dither_map(ivec2 uv,float t) {
	uv += ivec2(int(sin(t*123)*123),int(sin(t*321)*321));
	uv = ivec2(uv.x%3,uv.y%3);
	return ivec2(
		int(sign(uv.y-1))*int(uv.x==1),
		int(-sign(uv.x-1))*int(uv.y==1)); }
*/
