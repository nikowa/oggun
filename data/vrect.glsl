
// (TODO): Add a @permeating attribute, which automates the passing of variables to the fragment stage. //

layout(location = 0) in vec4 rect;
layout(location = 1) in float depth;
layout(location = 2) in vec4 fill_color;
layout(location = 3) in float rounding;
layout(location = 4) in float stroke;
layout(location = 5) in vec4 stroke_color;
layout(location = 6) in vec4 clip;
layout(location = 7) in float clip_radius;
layout(location = 0) uniform vec2 res;

#include <rect>
#include <mesh>

out vec2 tex_coord;
flat out vec4 _rect;
flat out float _depth;
flat out vec4 _fill_color;
flat out float _rounding;
flat out float _stroke;
flat out vec4 _stroke_color;
flat out vec4 _clip;
flat out float _clip_radius;

void main(void) {
	_rect = rect;
	_depth = depth;
	_fill_color = fill_color;
	_rounding = rounding;
	_stroke = stroke;
	_stroke_color = stroke_color;
	_clip = clip;
	_clip_radius = clip_radius;
	gl_Position.zw = vec2(0, 1);
	gl_Position.xy = mh_rect_uved(gl_VertexID % 6, rect.xy / res, rect.zw / res, tex_coord); }
