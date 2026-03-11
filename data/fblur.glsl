layout (binding = 0) uniform sampler2D samp;
in vec2 tex_coord;
uniform float radius;
uniform vec2 scr_res;
out vec4 color;
const float dens = 0.12579480421023972;
float gaus(float x, float y, float r) {
	r = r / 6.0;
	float rx = float(x) / r;
	float ry = float(y) / r;
	return pow(2.0,(-rx*rx -ry*ry));
}
float rand(float n) {
	return fract(sin(n) * 43758.5453123);
}
void main(void) {
	vec2 uv=gl_FragCoord.xy/scr_res.xy;
	color=vec4(0.0,0.0,0.0,1.0);
	float total_mass=0.0;
	for(float i=0.0; i<radius; i+=1.0) {
		for(float j=0.0; j<radius; j+=1.0) {
			float x=i-radius*0.5;
			float y=j-radius*0.5;
			vec2 duv=vec2(x,y)/scr_res.xy;
			float mass=gaus(duv.x*scr_res.x,duv.y*scr_res.y,radius);
			color.xyz+=texture(samp,uv+duv).xyz*mass;
			total_mass+=mass;
		}
	}
	color.xyz/=total_mass;
}
