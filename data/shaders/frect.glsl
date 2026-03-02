out vec4 color;
uniform vec4 fill_color;
uniform vec2 pos;
uniform vec2 size;
uniform vec2 res;
uniform float rounding;
uniform float time;
in vec2 tex_coord;


void main(void) {
	color = fill_color;
	return;
	vec2 p=gl_FragCoord.xy-res*0.5-pos;
	vec2 b=size/2-vec2(rounding);
	vec2 d=abs(p)-b;
	float dist=length(max(d,0.0))+min(max(d.x,d.y),0.0);
	if(dist<rounding) {
		color=fill_color;
		color.xyz+=0.5*(p.y+0.5*size.y+sin(2*time+8*tex_coord.x)*4+cos(-3*time-3*tex_coord.x))/size.y; }
	if(dist>(rounding-2)) {
		color.xyz=vec3(1); }
	if(dist>(rounding-1)) {
		color.xyz=vec3(0); } }

