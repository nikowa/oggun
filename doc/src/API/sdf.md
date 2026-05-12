# SDF

## Constants

#### `SDF_CLEAR`

```c
SDF_CLEAR :: 1000000
```

#### `COLLISION_EPSILON`

```c
COLLISION_EPSILON :: 0.05
```

## Types

#### `Distance`

```c
Distance :: f32
```

#### `SDF_ID`

```c
SDF_ID :: enum {
	PLANE           = 0,
	SPHERE          = 1,
	CAPSULE_Z       = 2,
	GROUND_TRIANGLE = 3,
	GROUND          = 4,
	MESH            = 5 }
```

#### `SDF_Surface`

```c
SDF_Surface :: union {
	SDF_Plane,
	SDF_Sphere,
	SDF_Capsule_Z,
	SDF_Triangle,
	SDF_Triangle_Mesh,
	SDF_Plane_Mesh }
```

#### `SDF_Plane`

```c
SDF_Plane :: struct {
	c: [3]f32,
	n: [3]f32,
	h: f32 }
```

<details><summary>Description</summary>
A plane defined by a center point <code>c</code>, a normal vector <code>n</code>, and an offset <code>h</code> along the normal.
</details>

#### `SDF_Sphere`

```c
SDF_Sphere :: struct {
	c: [3]f32,
	r: f32 }
```

<details><summary>Description</summary>
A sphere defined by a center point <code>c</code>, and a radius <code>r</code>.
</details>

#### `SDF_Capsule_Z`

```c
SDF_Capsule_Z :: struct {
	c: [3]f32,
	r: f32,
	l: f32 }
```

<details><summary>Description</summary>
A capsule oriented along the Z axis, defined by a center point <code>c</code>, a radius <code>r</code>, and a length <code>l</code>.
</details>

#### `SDF_Triangle`

```c
SDF_Triangle :: struct {
	a: [3]f32,
	b: [3]f32,
	c: [3]f32 }
```

<details><summary>Description</summary>
A triangle defined by three points.
</details>

#### `SDF_Triangle_Mesh`

```c
SDF_Triangle_Mesh :: struct {
	triangles: []SDF_Triangle }
```

<details><summary>Description</summary>
A hollow triangular mesh, defined as the union of a set of triangles.
</details>

#### `SDF_Plane_Mesh`

```c
SDF_Plane_Mesh :: struct {
	planes: []SDF_Plane }
```

<details><summary>Description</summary>
A solid convex mesh, defined as the intersection of a set of planes.
</details>

#### `Collider`

```c
Collider :: struct {
	surface: SDF_Surface,
	bounds:  SDF_Sphere }
```

<details><summary>Description</summary>
A surface with a bounding sphere.
</details>

## Procedures

#### `sdf_plane`

```c
sdf_plane :: proc(
	p: [3]f32,
	plane: SDF_Plane) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Plane</code>.
</details>

#### `sdf_sphere`

```c
sdf_sphere :: proc(
	p: [3]f32,
	sphere: SDF_Sphere) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Sphere</code>.
</details>

#### `sdf_capsule_z`

```c
sdf_capsule_z :: proc(
	p: [3]f32,
	capsule: SDF_Capsule_Z) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Capsule_Z</code>.
</details>

#### `sdf_triangle`

```c
sdf_triangle :: proc(
	p: [3]f32,
	triangle: SDF_Triangle) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Triangle</code>.
</details>

#### `sdf_triangle_mesh`

```c
sdf_triangle_mesh :: proc(
	p: [3]f32,
	mesh: SDF_Triangle_Mesh) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Triangle_Mesh</code>.
</details>

#### `sdf_plane_mesh`

```c
sdf_plane_mesh :: proc(
	p: [3]f32,
	mesh: SDF_Plane_Mesh) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Plane_Mesh</code>.
</details>

#### `sdf_surface`

```c
sdf_surface :: proc(
	p: [3]f32,
	surface: SDF_Surface) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to an <code>SDF_Surface</code>.
</details>

#### `sdf_collision_surfaces`

```c
sdf_collision_surfaces :: proc(
	p: [3]f32,
	collision_surfaces: ^[dynamic]SDF_Surface) -> Distance
```

<details><summary>Description</summary>
Compute the signed distance from a point to the union of a set of <code>SDF_Surface</code>s.
</details>

#### `nf_collision_surfaces`

```c
nf_collision_surfaces :: proc(
	p: [3]f32,
	collision_surfaces: ^[dynamic]SDF_Surface) -> [3]f32
```

<details><summary>Description</summary>
Compute the normal of the union of a set of <code>SDF_Surface</code>s at the nearest point to point <code>p</code>.
</details>

#### `sdf_inside`

```c
sdf_inside :: proc(
	d: Distance) -> bool
```

<details><summary>Description</summary>
Is point inside surface?
</details>

#### `sdf_outside`

```c
sdf_outside :: proc(
	d: Distance) -> bool
```

<details><summary>Description</summary>
Is point outside surface?
</details>

#### `sdf_sect`

```c
sdf_sect :: proc(
	d_a, d_b: Distance) -> Distance
```

<details><summary>Description</summary>
Intersection.
</details>

#### `sdf_smooth_sect`

```c
sdf_smooth_sect :: proc(
	d_a, d_b: Distance, k: f32) -> Distance
```

<details><summary>Description</summary>
Smooth intersection.
</details>

#### `sdf_union`

```c
sdf_union :: proc(
	d_a, d_b: Distance) -> Distance
```

<details><summary>Description</summary>
Union.
</details>

#### `sdf_smooth_union`

```c
sdf_smooth_union :: proc(
	d_a, d_b: Distance,
	k: f32) -> Distance
```

<details><summary>Description</summary>
Smooth union.
</details>

#### `sdf_diff`

```c
sdf_diff :: proc(
	d_a, d_b: Distance) -> Distance
```

<details><summary>Description</summary>
Difference.
</details>

#### `sdf_smooth_diff`

```c
sdf_smooth_diff :: proc(
	d_a, d_b: Distance,
	k: f32) -> Distance
```

<details><summary>Description</summary>
Smooth difference.
</details>

#### `sdf_round`

```c
sdf_round :: proc(
	d: Distance,
	r: f32) -> Distance
```

<details><summary>Description</summary>
Rounding.
</details>
