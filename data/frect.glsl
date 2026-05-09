out vec4 color;
layout(location = 0) uniform vec2 res;
in vec2 tex_coord;
flat in vec4 _rect;
flat in float _depth;
flat in vec4 _fill_color;
flat in float _rounding;
void main(void) {
	vec2 pos = _rect.xy;
	vec2 size = _rect.zw;
	color = _fill_color;
	gl_FragDepth = _depth;
	return;
	vec2 p=gl_FragCoord.xy-res*0.5-pos;
	vec2 b=size/2-vec2(_rounding);
	vec2 d=abs(p)-b;
	float dist=length(max(d,0.0))+min(max(d.x,d.y),0.0);
	if(dist<_rounding) { color = _fill_color; }
	if(dist>(_rounding-2)) { color.xyz=vec3(1); }
	if(dist>(_rounding-1)) { color.xyz=vec3(0); } }
