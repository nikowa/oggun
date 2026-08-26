# bs/setoid

### `Set`

```odin
Set :: distinct Bit_Array
```

`Set` is a structural equivalent of `Bit_Array` and a functional equivalent of `SSet` (sparse set). They both represent a set of elements from some universe `universe: []U`. To save space, the universe is stored separately, but it has to be passed to some procedures. The universe has a capacity limit of `65_535`.

```odin
SSet :: struct($T: typeid) #packed {
	elements: []T,
	len: u16,
	cap: u16 }
```

`Set` and `SSet` have the same procedures. They both represent a set of elements from some domain.

### `Setoid`

```odin
Setoid :: struct {
	adjacency_matrix: Bit_TMatrix }
```

A `Setoid` is equivalent to an unlabeled undirected graph.

| shallow size | $24$ |
|--|--|
| deep size | $24 + (\text{order}^2 + \text{order}) / 16$ |

### `make`

```odin
make_setoid :: proc(
	order: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	setoid: Setoid,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Setoid`.

### `size`

```odin
setoid_size :: proc(
	setoid: ^Setoid) -> u32
```

Counts the number of edges.

### `order`

```odin
setoid_order :: proc(
	setoid: ^Setoid) -> u32
```

Counts the number of vertices.

### `connect`

```odin
setoid_connect :: proc(
	setoid: ^Setoid,
	vert0, vert1: u32)
```

Connects vertices `vert0` and `vert1`.

### `disconnect`

```odin
setoid_disconnect :: proc(
	setoid: ^Setoid,
	vert0, vert1: u32)
```

Disconnects vertices `vert0` and `vert1`.

### `connected`

```odin
setoid_connected :: proc(
	setoid: ^Setoid,
	vert0, vert1: u32) -> bool
```

Checks if vertices `vert0` and `vert1` are connected.

### `neighbors`

```odin
setoid_neighbors :: proc(
	setoid: ^Setoid,
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of the neighbors of `vert`.

### `degree`

```odin
setoid_degree :: proc(
	setoid: ^Setoid,
	vert: u32,
	allocator := context.allocator) -> (degree: u32)
```

Counts the number of neighbors of `vert`.

<pre>
























</pre>
