# bs/graph

### `Graph`

```odin
Graph :: struct($Label: typeid) {
	adjacency_matrix: Matrix(Label) }
```

A `Graph` is equivalent to a labeled undirected graph. `Label({})` must not be a valid label.

| shallow size | $24$ |
|--|--|
| deep size | $24 + \text{size}(\text{Label}) \cdot (\text{order}^2 + \text{order}) / 2$ |

!!! tip "Feature Suggestion"
	Implement a shortest path algorithm and use it to extend the `.Translate` asset op, allowing translations between non-adjacent representations.

### `make`

```odin
make_graph :: proc(
	$Label: typeid,
	order: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	graph: Graph(Label),
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Graph`.

### `size`

```odin
graph_size :: proc(graph: ^Graph) -> u32
```

Counts the number of edges.

### `order`

```odin
graph_order :: proc(graph: ^Graph) -> u32
```

Counts the number of vertices.


### `connect`

```odin
graph_connect :: proc(
	graph: ^Graph($Label),
	vert0, vert1: u32,
	label: Label)
```

Connects vertices `vert0` and `vert1`.

### `disconnect`

```odin
graph_disconnect :: proc(
	graph: ^Graph($Label),
	vert0, vert1: u32)
```

Disconnects vertices `vert0` and `vert1`.

### `connected`

```odin
graph_connected :: proc(
	graph: ^Graph($Label),
	src, dest: u32) -> (bool, Label)
```

Checks if vertices `vert0` and `vert1` are connected.

### `neighbors`

```odin
graph_neighbors :: proc(
	graph: ^Graph($Label),
	src: u32,
	allocator := context.allocator) -> []u32
```

Creates a list of the neighbors of `vert`.

### `degree`

```odin
graph_degree :: proc(
	graph: ^Graph($Label),
	dest: u32,
	allocator := context.allocator) -> (degree: u32)
```

Counts the number of neighbors of `vert`.

<pre>
























</pre>
