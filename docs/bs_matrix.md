# bs/matrix

### `Matrix`

```odin
Matrix :: struct($T: typeid, $triangular: bool) {
	shape: [2]u32,
	backing: []T }
```

### `make_matrix`

```odin
make_matrix :: proc(
	shape: [2]u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	matrix: Matrix($T, $triangular),
	err: runtime.Allocator_Error) #optional_allocator_error
```

### `clone`

```odin
clone :: proc(
	matrix: ^Matrix($T, $triangular),
	allocator := context.allocator) -> (
	Matrix(T),
	runtime.Allocator_Error) #optional_allocator_error
```

### `size`

```odin
size :: proc(
	matrix: ^Matrix($T, $triangular)) -> u32
```

### `fill_random`

```odin
fill_random :: proc(
	matrix: ^Matrix($T, $triangular))
```

Fills the matrix with random bits.

### `fill`

```odin
fill :: proc(
	matrix: ^Matrix($T, $triangular),
	value: u8)
```

Sets all cells to the given value.

### `rank`

```odin
rank :: proc(
	matrix: ^Matrix($T, $triangular),
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `write`

```odin
write :: proc(
	matrix: ^Matrix($T, $triangular),
	index2: [2]u32,
	value: u8)
```

```odin
write :: proc(
	matrix: ^Matrix($T, $triangular),
	first_index2: [2]u32,
	last_index2: [2]u32,
	value: Backing_Type)
```

Writes the given value to a given cell or range of cells.

### `read`

```odin
read :: proc(
	matrix: ^Matrix($T, $triangular),
	index2: [2]u32) -> u8
```

```odin
read :: proc(
	matrix: ^Matrix($T, $triangular),
	first_index2: [2]u32,
	last_index2: [2]u32) -> Backing_Type
```

Retreive the value of a given cell or range of cells.

### `aprint`

```odin
aprint :: proc(
	matrix: ^Matrix($T, $triangular),
	allocator := context.allocator) -> string
```

Pretty-print the matrix.
