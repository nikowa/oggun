# Rect

### Types

#### `Rect`

```c
Rect :: struct #packed {
	pos:  [2]f32,
	size: [2]f32 }
```

### Procedures

#### `make_rect`

```c
make_rect :: proc(pos_x, pos_y, size_x, size_y: f32) -> Rect
```

#### `left`

```c
left :: proc(rect: Rect) -> f32
```

<details><summary>Description</summary>
Get the x-coordinate of the left wall of the given rectangle.
</details>

#### `right`

```c
right :: proc(rect: Rect) -> f32
```

<details><summary>Description</summary>
Get the x-coordinate of the right wall of the given rectangle.
</details>

#### `bottom`

```c
bottom :: proc(rect: Rect) -> f32
```

<details><summary>Description</summary>
Get the y-coordinate of the bottom wall of the given rectangle.
</details>

#### `top`

```c
top :: proc(rect: Rect) -> f32
```

<details><summary>Description</summary>
Get the y-coordinate of the top wall of the given rectangle.
</details>

#### `contains_point`

```c
contains_point :: proc(rect: Rect, point: [2]f32) -> bool
```

<details><summary>Description</summary>
Check if a given point is either <i>in</i> or <i>on</i> the given rectangle.
</details>

<pre>
























</pre>
