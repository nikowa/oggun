layout (binding = 0) uniform sampler2D static_color_samp;
layout (binding = 7) uniform sampler2D effect_normal_samp;
layout (binding = 3) uniform sampler2D dynamic_color_samp;
layout (binding = 6) uniform sampler2D ui_shadow_samp;
uniform vec3 player_1;
uniform vec3 player_2;
uniform vec3 glare_spots[128];
uniform int n_glare_spots;
uniform float time;
uniform float res_scale;
in vec2 tex_coord;
out vec4 color;
uniform vec2 this_buffer_res;
uniform vec2 main_buffer_res;
const float PI = 3.14159265;
const float PLAYER_HEIGHT = 0.06;
const float GROUND_HEIGHT = 0.1;
vec4 texture_combine(sampler2D static_samp, sampler2D dynamic_samp, vec2 uv) {
	vec4 sta = texture(static_samp,uv);
	vec4 dyn = texture(dynamic_samp,uv);
	return mix(sta,dyn,int(sta.w>dyn.w)); }
float range_filter(float c, float range) {
	c = clamp(c, 0, 1);
	float lo = abs(c - 0.0);
	float hi = abs(1.0 - c);
	if((lo < range) || (hi < range)) {
		return 1.0;
	} else {
		return 0.0;
	}
}
vec3 czm_saturation(vec3 rgb, float adjustment) {
	const vec3 w = vec3(0.2125, 0.7154, 0.0721);
	vec3 intensity = vec3(dot(rgb, w));
	return mix(intensity, rgb, adjustment);
}
bool is_whiteish(vec3 a) {
	return (a.x + a.y + a.z >= 2.90);
}
vec3 luminance(vec3 a) {
	return pow(a, vec3(64.0));
}
float lum(vec3 v) {
	return v.x + v.y + v.z;
}
float mean3(vec3 vec) {
	return vec.x * 0.333 + vec.y * 0.333 + vec.z * 0.333;
}
vec3 tonemap(vec3 c) {
	return 2.5 * c / (1.0 + 1.5 * c);
}
float vec_angle(vec2 v) {
	v = normalize(v);
	if(v.y>0.0){ return acos(v.x); } else { return -acos(v.x); }
}
float starburst(vec2 uv, vec2 p, float s) {
	vec2 q = p - uv;
	float a = vec_angle(q) * 3. + sin(time*0.04);
	float w = 0.001 * s;
	a = (2.0 / w) * (pow(sin(a), 2.) - (1.0 - w)) * 1.0;
	float r = 1.0-clamp(length(q)*(2./s),0.,1.);
	float n = s*0.2*pow(2.,-pow(length(q*32.),2.));
	float m = mix(pow(r,16),pow(r,8),(1+sin(time*4))/2);
	return n + clamp(m * mix(a * 4., r * 10. * s, r), 0., 1.);
}
float gaus(float x,float y,float r) {
	r = r/6;
	float rx = float(x)/r;
	float ry = float(y)/r;
	return pow(2.0,(-rx*rx -ry*ry));
}
float rand(float n) {
	return fract(sin(n)*43758.5453123);
}
vec3 apply_blur(vec3 color,sampler2D samp) {
	vec2 uv = gl_FragCoord.xy/this_buffer_res.xy;
	color = vec3(0);
	float total_mass = 0;
	float radius = 32.0;
	for(float i=0; i<radius; i+=1) {
		for(float j=0; j<radius; j+=1) {
			float x=i-radius*0.5;
			float y=j-radius*0.5;
			vec2 duv=vec2(x,y)/this_buffer_res.xy;
			float mass=gaus(duv.x*this_buffer_res.x,duv.y*this_buffer_res.y,radius);
			color+=texture(samp,uv+duv).xyz*mass;
			total_mass+=mass;
		}
	}
	color/=total_mass;
	return color;
}
/*
vec3 apply_glare(vec3 color) {
	vec2 uv = gl_FragCoord.xy/main_buffer_res.xy;
	vec3 x = vec3(0,0,0);
	for(int i = 0; i < n_glare_spots; i += 1) {
		vec2 t = glare_spots[i].xy / this_buffer_res;
		vec2 o = vec2(sin(time * 0.0005), cos(time * 0.0004));
		t += o * 0.55;
		float l = glare_spots[i].z;
		l *= 1.2; // was 0.5
		x += starburst(uv, t, l) * mix(vec3(1),normalize(color),0.75);
		//x += cheap_star(uv, vec2(0,0), 1.0) * 0.01;
	}
	return color+x;
}
*/
vec3 apply_glare(vec3 color) {
	vec2 uv = gl_FragCoord.xy*res_scale/main_buffer_res.xy;
	vec3 x = vec3(0,0,0);
	for(int i = 0; i < n_glare_spots; i += 1) {
		vec2 t = glare_spots[i].xy;
		float l = glare_spots[i].z;
		l = max(l,0.6);
		l *= 0.6;
		x += starburst(uv,t,l)*mix(vec3(1),normalize(color),1.2);
    }
    return color+x;
}
vec3 apply_lens_flare(vec3 color) {
	float lux = mean3(color);
	vec2 scr_size = vec2(1280.0, 720.0);
	bool whiteish = false;
	float range = 8.0;
	float angle_delta = 3.14 * 2 / 6;
	float max_dist = length(vec2(range, range));
	float dist = max_dist;
	vec3 light = vec3(0.0, 0.0, 0.0);
	float scale = 1.0;
	for(float i = -range; i <= range; i += 1.0) {
		for(float angle = 0.0; angle < 3.14 * 2; angle += angle_delta) {
			vec2 offset = vec2(scale * i * sin(angle/* + time*/), scale * i * cos(angle/* + time*/));
			vec2 uv = tex_coord + offset / scr_size;
			vec3 this_light = texture(static_color_samp, uv).xyz;
			if(is_whiteish(this_light)) {
				float this_dist = length(offset) * 2.0;
				if(this_dist < dist) {
					dist = this_dist;
					light = this_light;
					whiteish = true;
				}
			}
		}
	}
	if(whiteish) {
		float alpha = pow((max_dist - dist) / max_dist, 0.5);
		return color + max(color, luminance(light) * alpha);
	} else {
		return color + vec3(0.0, 0.0, 0.0);
	}
}

float select(vec3 c) {
	float lux = c.x + c.y + c.z;
	if(lux >= 2.8) {
		return 1.0;
	} else {
		return 0.0;
	}
	return lux;
}

float flat_step(float e0, float e1, float x) {
	return clamp((x - e0) / (e1 - e0), 0.0, 1.0);
}

vec4 display_normal(vec3 n) {
	n = normalize(n);
	return vec4(vec3(0.5) + n * vec3(0.5),1);
}

void main(void) {
	vec2 portal_pos = vec2(0,0);
	//color = texture(effect_normal_samp,tex_coord/2-portal_pos/4+vec2(0.25)); return;
	vec3 n = vec3(tex_coord,1);
	float t = (sin(time*16)+1);
	float speed = t*0.005;
	for(int i=0; i<8; i+= 1) {
		vec3 delta = texture(effect_normal_samp,n.xy/2-portal_pos/4+vec2(0.25)).xyz;
		delta = (delta-vec3(0.5))*2;
		//color = vec4(delta,1);
		//return;
		n += delta * speed;
	}
	//color = vec4(n,1);
	color = mix(
		texture_combine(static_color_samp,dynamic_color_samp,n.xy),
		vec4(0),
		0);
	//color = texture_combine(static_color_samp,dynamic_color_samp,tex_coord+((sin(time)+1)*n.xy));
	//return;
	color = texture_combine(static_color_samp,dynamic_color_samp,tex_coord);
	float lum = length(color.xyz);
	color.xyz = czm_saturation(color.xyz,1.0);
//	color.xyz = mix(czm_saturation(color.xyz,2.0),czm_saturation(color.xyz,4.0),1-mask_low);
	color.w = 1.0;
	//color.xyz = apply_blur(color.xyz,static_color_samp);
//	color.xyz = apply_lens_flare(color.xyz);
//	vec3 shadow = texture(ui_shadow_samp, tex_coord).xyz;
//	color.xyz *= (1.0-length(shadow));
//	color.xyz -= shadow * 1.6;
	float s = select(color.xyz);
	color.xyz = apply_glare(color.xyz);
//	for(int i=0;
}
