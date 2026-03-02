layout(binding=0) uniform sampler2D background_samp;
layout(binding=1) uniform sampler2D normal_corner_pack;
uniform vec2 res;
uniform vec2 pos;
uniform vec2 size;
in vec2 tex_coord;
out vec4 color;
#define range 2
float specular(vec3 normal,vec3 light_direction,float exponent) {
	return pow(max(dot(vec3(0,0,-1),normalize(reflect(normalize(light_direction),normal))),0),exponent)*exponent; }
float sd_box(vec2 p,vec2 b,vec4 r) {
	r.xy = (p.x>0.0)?r.xy : r.zw;
	r.x  = (p.y>0.0)?r.x  : r.y;
	vec2 q = abs(p)-b+r.x;
	return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x; }
void main(void) {
	vec2 coord=(gl_FragCoord.xy-pos)-res/2;
	vec2 background_uv=gl_FragCoord.xy/res;
	vec2 uv=gl_FragCoord.xy/res.y;
	float d=-sd_box(coord,size/2,vec4(8));
	color.w = 1;
	vec3 color_sum = vec3(0);
	float weight_sum = 0.0;
	for (int x = -range; x<=range; x+=1) for (int y = -range; y<=range; y+=1) {
		color_sum += texture2D(background_samp, uv + vec2(x,y)/res).xyz;
		weight_sum += 1; }
	color.xyz = color_sum / weight_sum;
	color.xyz = mix(color.xyz, vec3(0), 0.333);
	color=texture(normal_corner_pack,10*uv);
	color.xyz=vec3(0);
	uv=tex_coord*size/8;
	vec3 normal=vec3(0);
	if (coord.x<-size.x/2+8) {
		if (coord.y<-size.y/2+8) {
			normal=texture(normal_corner_pack,(uv+vec2(0,0))/3).xyz;
			color.w=(length(coord+vec2(size.x,size.y)/2-vec2(8,8))/8>1)?0:1; }
		else if (coord.y>size.y/2-8) {
			normal=texture(normal_corner_pack,(uv+vec2(0,2))/3).xyz;
			color.w=(length(coord+vec2(size.x,-size.y)/2-vec2(8,-8))/8>1)?0:1; }
		else {
			normal=texture(normal_corner_pack,(vec2(uv.x,0)+vec2(0,1))/3).xyz;
			 }
	}
	else if (coord.x>size.x/2-8) {
		if (coord.y<-size.y/2+8) {
			normal=texture(normal_corner_pack,(uv+vec2(1,0))/3).xyz;
			color.w=(length(coord+vec2(-size.x,size.y)/2-vec2(-8,8))/8>1)?0:1;
			// normal=vec3(1,0,0);
			}
		else if (coord.y>size.y/2-8) {
			normal=texture(normal_corner_pack,(uv+vec2(1,2))/3).xyz;
			color.w=(length(coord+vec2(-size.x,-size.y)/2-vec2(-8,-8))/8>1)?0:1; }
		else {
			normal=texture(normal_corner_pack,(vec2(uv.x,0)+vec2(1,1))/3).xyz; }
			}
	else if (coord.y>size.y/2-8) {
		normal=texture(normal_corner_pack,(vec2(0,uv.y)+vec2(2,2))/3).xyz; }
	else if (coord.y<-size.y/2+8) {
		normal=texture(normal_corner_pack,(vec2(0,uv.y)+vec2(2,0))/3).xyz;
		}
	else {
		normal=texture(normal_corner_pack,(fract(uv/2-vec2(0.5))+vec2(1,1))/3).xyz;
		}
	normal=(normal-vec3(0.5,0.5,0.0))*vec3(2,2,1);
	normal=clamp(normal,vec3(-1),vec3(1));
	// color.xyz=normal;
	color.xyz=mix(texture2D(background_samp,background_uv+0.1*normal.xy).xyz,vec3(0,1,0),0.25);
	color.xyz+=0.2*vec3(specular(normal,vec3(0.0,0.1,1),8));
	// color.xyz=vec3(0);
	if (d<=2) {
		color.xyz=vec3(0,0.25,0);
		color.w*=0.75;
	}
}