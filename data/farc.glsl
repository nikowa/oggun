out vec4 color;
layout(location = 0) uniform vec2 res;
layout(pixel_center_integer) in vec4 gl_FragCoord;
flat in vec4 _line_color;
flat in float _depth;
flat in vec4 _clip;
flat in float _clip_radius;
flat in vec2 _center;
flat in float _radius;
flat in vec2 _angle_range;

#include <sdf>
#include <msaa>
#include <clip>

#define line_color _line_color
#define depth _depth
#define clip _clip
#define clip_radius _clip_radius
#define center _center
#define radius _radius
#define angle_range _angle_range

void main(void) {
	color = line_color; }
