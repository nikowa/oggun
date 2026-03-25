out vec4 color;
layout(location = 0) uniform vec2 pos;
layout(location = 1) uniform vec2 size;
layout(location = 2) uniform vec2 res;
layout(location = 3) uniform vec4 fill_color;
layout(location = 4) uniform float rounding;
in vec2 tex_coord;



void main(void) {
	color = fill_color;
	return;
	vec2 p=gl_FragCoord.xy-res*0.5-pos;
	vec2 b=size/2-vec2(rounding);
	vec2 d=abs(p)-b;
	float dist=length(max(d,0.0))+min(max(d.x,d.y),0.0);
	if(dist<rounding) { color=fill_color; }
	if(dist>(rounding-2)) { color.xyz=vec3(1); }
	if(dist>(rounding-1)) { color.xyz=vec3(0); } }

