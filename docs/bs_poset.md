# bs/poset

### `Poset`

```odin
Poset :: struct {
	order: u32,
	size: u32,
	adjacency_matrix: Bit_Matrix }
```

A `Poset` is an unlabeled directed graph. For a labeled directed graph see [graph](bs_graph.md).

### `make_poset`

```odin
make_poset :: proc(
	order: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	poset: Poset,
	err: runtime.Allocator_Error) #optional_allocator_error
```

### `connect`

```odin
connect :: proc(
	poset: ^Poset,
	src, dest: u32)
```

### `simple_connect`

```odin
simple_connect :: proc(
	poset: ^Poset,
	src, dest: u32)
```

### `disconnect`

```odin
disconnect :: proc(
	poset: ^Poset,
	src, dest: u32)
```

### `simple_disconnect`

```odin
simple_disconnect :: proc(
	poset: ^Poset,
	src, dest: u32)
```

### `connected`

```odin
connected :: proc(
	poset: ^Poset,
	src, dest: u32) -> bool
```

### `simply_connected`

```odin
simply_connected :: proc(
	poset: ^Poset,
	src, dest: u32) -> bool
```

### `neighbors`

```odin
neighbors :: proc(
	poset: ^Poset,
	src: u32,
	allocator := context.allocator) -> []u32
```

### `reverse_neighbors`

```odin
reverse_neighbors :: proc(
	poset: ^Poset,
	dest: u32,
	allocator := context.allocator) -> []u32
```

### `simple_neighbors`

```odin
simple_neighbors :: proc(
	poset: ^Poset,
	src: u32,
	allocator := context.allocator) -> []u32
```

### `outdegree`

```odin
outdegree :: proc(
	poset: ^Poset,
	src: u32,
	allocator := context.allocator) -> (degree: u32)
```

### `indegree`

```odin
indegree :: proc(
	poset: ^Poset,
	dest: u32,
	allocator := context.allocator) -> (
	degree: u32)
```
