# Container

Various containers used throughout Oggun.

### Types

#### `Bary`

```c
Bary :: [3]f32
```

#### `Two_Stack`

```c
Two_Stack :: struct($T: typeid) {
	buffer: [2]T,
	len: u8 }
```

### Procedures

#### `bary_from_point`

```c
bary_from_point :: proc { bary_from_point2 }
bary_from_point2 :: proc(point: [2]f32, triangle: [3][2]f32) -> (bary: Bary)
```

<details><summary>Description</summary>
Convert Euclidean coordinates to barycentric coordinates relative to a given triangle.
</details>

#### `bary_to_point`

```c
bary_to_point :: proc { bary_to_point2, bary_to_point3 }
bary_to_point2 :: proc(bary: Bary, triangle: [3][2]f32) -> (point: [2]f32)
bary_to_point3 :: proc(bary: Bary, triangle: [3][3]f32) -> (point: [3]f32)
```

<details><summary>Description</summary>
Convert barycentric coordinates relative to a given triangle to Euclidean coordinates.
</details>

#### `bary_inside`

```c
bary_inside :: proc(bary: Bary) -> bool
```

<details><summary>Description</summary>
Check if the given barycentrric point is inside the triangle relative to which it is defined.
</details>

#### `point_inside_triangle`

```c
point_inside_triangle :: proc { point2_inside_triangle }
point2_inside_triangle :: proc(point: [2]f32, triangle: [3][2]f32) -> bool
```

<details><summary>Description</summary>
Check if the given Euclidean point is inside the given triangle.
</details>

#### `init`

```c
init :: proc(two_stack: ^Two_Stack($T))
```

#### `len`

```c
len :: proc(two_stack: ^Two_Stack($T)) -> int
```

#### `push`

```c
push :: push_top
```

#### `push_top`

```c
push_top :: proc(two_stack: ^Two_Stack($T), elem: T) -> bool
```

#### `push_bottom`

```c
push_bottom :: proc(two_stack: ^Two_Stack($T), elem: T) -> bool
```

#### `pop`

```c
pop :: pop_top
```

#### `pop_top`

```c
pop_top :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `pop_bottom`

```c
pop_bottom :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `peek`

```c
peek :: peek_top
```

#### `peek_top`

```c
peek_top :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `peek_bottom`

```c
peek_bottom :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `contains`

```c
contains :: proc(two_stack: ^Two_Stack($T), elem: T) -> (ok: bool)
```

<pre>
























</pre>
