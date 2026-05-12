#+feature using-stmt
package sdf
import "core:fmt"
import "core:math"
import "core:math/linalg"

Distance :: f32

SDF_ID :: enum {
	PLANE           = 0,
	SPHERE          = 1,
	CAPSULE_Z       = 2,
	GROUND_TRIANGLE = 3,
	GROUND          = 4,
	MESH            = 5 }

SDF_Surface :: union {
	SDF_Plane,
	SDF_Sphere,
	SDF_Capsule_Z,
	SDF_Triangle,
	SDF_Triangle_Mesh,
	SDF_Plane_Mesh }

SDF_Plane :: struct {
	c: [3]f32,
	n: [3]f32, // Must be normalized.
	h: f32 }

SDF_Sphere :: struct {
	c: [3]f32,
	r: f32 }

SDF_Capsule_Z :: struct {
	c: [3]f32,
	r: f32,
	l: f32 }

SDF_Triangle :: struct {
	a: [3]f32,
	b: [3]f32,
	c: [3]f32 }

SDF_Triangle_Mesh :: struct {
	triangles: []SDF_Triangle } // Unioned.

SDF_Plane_Mesh :: struct {
	planes: []SDF_Plane } // Intersected.

Collider :: struct {
	surface: SDF_Surface,
	bounds:  SDF_Sphere }

SDF_CLEAR :: 1000000
COLLISION_EPSILON :: 0.05

sdf_plane :: proc(p: [3]f32, plane: SDF_Plane) -> Distance {
	p := p - plane.c
	return linalg.dot(p, plane.n) + plane.h }

sdf_sphere :: proc(p: [3]f32, sphere: SDF_Sphere) -> Distance {
	p := p - sphere.c
	return linalg.length(p) - sphere.r }

sdf_capsule_z :: proc(p: [3]f32, capsule: SDF_Capsule_Z) -> Distance {
	p := p - capsule.c
	p.z = math.sign(p.z) * math.clamp(math.abs(p.z) - capsule.l, 0, 1)
	return linalg.length(p) - capsule.r }

sdf_triangle :: proc(p: [3]f32, triangle: SDF_Triangle) -> Distance {
	a:    [3]f32
	b:    [3]f32
	c:    [3]f32
	n:    [3]f32
	o:    [3]f32
	z:    [3]f32 : { 0, 0, 1 }
	ab_n: [3]f32
	bc_n: [3]f32
	ca_n: [3]f32
	d:    Distance

	a = triangle.a
	b = triangle.b
	c = triangle.c
	n = linalg.normalize(linalg.cross(b - a, c - b))
	o = (a + b + c) / 3.0
	ab_n = linalg.normalize(linalg.cross(b - a, z))
	bc_n = linalg.normalize(linalg.cross(c - b, z))
	ca_n = linalg.normalize(linalg.cross(a - c, z))
	d = sdf_plane(p, SDF_Plane{ c = o, n = n, h = 0 })
	d = sdf_sect(d, sdf_plane(p, SDF_Plane{ c = (a + b) / 2, n = ab_n, h = 0 }))
	d = sdf_sect(d, sdf_plane(p, SDF_Plane{ c = (b + c) / 2, n = bc_n, h = 0 }))
	d = sdf_sect(d, sdf_plane(p, SDF_Plane{ c = (c + a) / 2, n = ca_n, h = 0 }))
	return sdf_round(d, COLLISION_EPSILON) }

sdf_triangle_mesh :: proc(p: [3]f32, mesh: SDF_Triangle_Mesh) -> Distance {
	d: Distance

	d = SDF_CLEAR
	for _, i in mesh.triangles do d = sdf_union(d, sdf_triangle(p, mesh.triangles[i]))
	return d }

sdf_plane_mesh :: proc(p: [3]f32, mesh: SDF_Plane_Mesh) -> Distance {
	d: Distance

	d = SDF_CLEAR
	for _, i in mesh.planes do d = sdf_sect(d, sdf_plane(p, mesh.planes[i]))
	return d }

sdf_surface :: proc(p: [3]f32, surface: SDF_Surface) -> Distance {
	switch variant in surface {
	case SDF_Plane:           return sdf_plane(p, variant)
	case SDF_Sphere:          return sdf_sphere(p, variant)
	case SDF_Capsule_Z:       return sdf_capsule_z(p, variant)
	case SDF_Triangle:        return sdf_triangle(p, variant)
	case SDF_Triangle_Mesh:   return sdf_triangle_mesh(p, variant)
	case SDF_Plane_Mesh:            return sdf_plane_mesh(p, variant) }
	return SDF_CLEAR }

sdf_collision_surfaces :: proc(p: [3]f32, collision_surfaces: ^[dynamic]SDF_Surface) -> Distance {
	d: Distance

	d = SDF_CLEAR
	for surface in collision_surfaces do d = sdf_union(d, sdf_surface(p, surface))
	return d }

nf_collision_surfaces :: proc(p: [3]f32, collision_surfaces: ^[dynamic]SDF_Surface) -> [3]f32 {
	DELTA :: 0.01
	return linalg.normalize([3]f32{
		sdf_collision_surfaces(p + { DELTA, 0, 0 }, collision_surfaces) -
		sdf_collision_surfaces(p - { DELTA, 0, 0 }, collision_surfaces),
		sdf_collision_surfaces(p + { 0, DELTA, 0 }, collision_surfaces) -
		sdf_collision_surfaces(p - { 0, DELTA, 0 }, collision_surfaces),
		sdf_collision_surfaces(p + { 0, 0, DELTA }, collision_surfaces) -
		sdf_collision_surfaces(p - { 0, 0, DELTA }, collision_surfaces) }) }

sdf_inside :: proc(d: Distance) -> bool {
	return d <= 0 }

sdf_outside :: proc(d: Distance) -> bool {
	return d > 0 }

sdf_sect :: proc(d_a, d_b: Distance) -> Distance {
	return max(d_a, d_b) }

sdf_smooth_sect :: proc(d_a, d_b: Distance, k: f32) -> Distance {
	h: f32

	h = math.clamp(0.5 - 0.5 * (d_b - d_a) / k, 0, 1)
	return math.lerp(d_b, d_a, h) + k * h * (1 - h) }

sdf_union :: proc(d_a, d_b: Distance) -> Distance {
	return min(d_a, d_b) }

sdf_smooth_union :: proc(d_a, d_b: Distance, k: f32) -> Distance {
	h: f32

	h = math.clamp(0.5 + 0.5 * (d_b - d_a) / k, 0, 1)
	return math.lerp(d_b, d_a, h) - k * h * (1 - h) }

sdf_diff :: proc(d_a, d_b: Distance) -> Distance {
	return max(d_a, -d_b) }

sdf_smooth_diff :: proc(d_a, d_b: Distance, k: f32) -> Distance {
	h: f32

	h = clamp(0.5 - 0.5 * (d_b + d_a) / k, 0, 1)
	return math.lerp(d_a, -d_b, h) + k * h * (1 - h) }

sdf_round :: proc(d: Distance, r: f32) -> Distance {
	return d - r }
