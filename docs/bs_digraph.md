# bs/digraph

### `Digraph`

```odin
Digraph :: struct($Label: typeid) {
	adjacency_matrix: Bit_Matrix }
```

A `Digraph` is equivalent to a labeled directed graph.

| shallow size | $24$ |
|--|--|
| deep size | $24 + \text{order}^2 \cdot \text{size}(\text{Label})$ |

### `make`

```odin
make_digraph :: proc(
	order: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	digraph: Digraph($Label),
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Digraph($Label)`.

### `size`

```odin
digraph_size :: proc(digraph: ^Digraph($Label)) -> u32
```

Counts the number of edges.

### `order`

```odin
digraph_order :: proc(digraph: ^Digraph($Label)) -> u32
```

Counts the number of vertices.

### `connect`

```odin
connect :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32,
	label: Label)
```

Adds an edge from `vert0` to `vert1`.

### `biconnect`

```odin
biconnect :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32,
	label: Label)
```

Adds an edge from `vert0` to `vert1` and an edge from `vert1` to `vert0`.

### `disconnect`

```odin
disconnect :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32)
```

Removes the edge from `vert0` to `vert1`, if it exists.

### `bidisconnect`

```odin
bidisconnect :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32)
```

Removes the edge from `vert0` to `vert1` and the egde from `vert1` to `vert0`, if they exist.

### `connected`

```odin
connected :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32) -> (bool, Label)
```

Checks if there is an edge from `vert0` to `vert1`.

### `biconnected`

```odin
biconnected :: proc(
	digraph: ^Digraph($Label),
	vert0, vert1: u32) -> (bool, Label, Label)
```

Checks if there is an edge from `vert0` to `vert1` or from `vert1` to `vert0`.

### `neighbors`

```odin
neighbors :: proc(
	digraph: ^Digraph($Label),
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of the neighbors of `vert`.

### `outneighbors`

```odin
outneighbors :: proc(
	digraph: ^Digraph($Label),
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of all verts that are the destination of an edge starting at `vert`.

### `inneighbors`

```odin
inneighbors :: proc(
	digraph: ^Digraph($Label),
	vert: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of all verts that are the source of an edge ending at `vert`.

### `outdegree`

```odin
outdegree :: proc(
	digraph: ^Digraph($Label),
	vert: u32,
	allocator := context.allocator) -> (degree: u32)
```

Counts the number of edges starting at `vert`.

### `indegree`

```odin
indegree :: proc(
	digraph: ^Digraph($Label),
	vert: u32,
	allocator := context.allocator) -> (
	degree: u32)
```

Counts the number of edges ending at `vert`.

<pre>
























</pre>
