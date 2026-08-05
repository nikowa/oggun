# bs/poset

### `Poset`

```odin
Poset :: struct {
	adjacency_matrix: Bit_Matrix }
```

A `Poset` is equivalent to an unlabeled directed graph.

| shallow size | $24$ |
|--|--|
| deep size | $24 + \text{order}^2 / 8$ |

### `make`

```odin
make_poset :: proc(
	order: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	poset: Poset,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Poset`.

### `size`

```odin
poset_size :: proc(poset: ^Poset) -> u32
```

Counts the number of edges.

### `order`

```odin
poset_order :: proc(poset: ^Poset) -> u32
```

Counts the number of vertices.

### `connect`

```odin
poset_connect :: proc(
	poset: ^Poset,
	vert0, vert1: u32)
```

Adds an edge from `vert0` to `vert1`.

### `biconnect`

```odin
poset_biconnect :: proc(
	poset: ^Poset,
	vert0, vert1: u32)
```

Adds an edge from `vert0` to `vert1` and an edge from `vert1` to `vert0`.

### `disconnect`

```odin
poset_disconnect :: proc(
	poset: ^Poset,
	vert0, vert1: u32)
```

Removes the edge from `vert0` to `vert1`, if it exists.

### `bidisconnect`

```odin
poset_bidisconnect :: proc(
	poset: ^Poset,
	vert0, vert1: u32)
```

Removes the edge from `vert0` to `vert1` and the egde from `vert1` to `vert0`, if they exist.

### `connected`

```odin
poset_connected :: proc(
	poset: ^Poset,
	vert0, vert1: u32) -> bool
```

Checks if there is an edge from `vert0` to `vert1`.

### `biconnected`

```odin
poset_biconnected :: proc(
	poset: ^Poset,
	vert0, vert1: u32) -> bool
```

Checks if there is an edge from `vert0` to `vert1` or from `vert1` to `vert0`.

### `neighbors`

```odin
poset_neighbors :: proc(
	poset: ^Poset,
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of the neighbors of `vert`.

### `outneighbors`

```odin
poset_outneighbors :: proc(
	poset: ^Poset,
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of all verts that are the destination of an edge starting at `vert`.

### `inneighbors`

```odin
poset_inneighbors :: proc(
	poset: ^Poset,
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of all verts that are the source of an edge ending at `vert`.

### `outdegree`

```odin
poset_outdegree :: proc(
	poset: ^Poset,
	vert: u32,
	allocator := context.allocator) -> (degree: u32)
```

Counts the number of edges starting at `vert`.

### `indegree`

```odin
poset_indegree :: proc(
	poset: ^Poset,
	vert: u32,
	allocator := context.allocator) -> (
	degree: u32)
```

Counts the number of edges ending at `vert`.

<pre>
























</pre>
