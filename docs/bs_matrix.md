# bs/matrix

### `Matrix`

```odin
Matrix :: struct($T: typeid) {
	shape: [2]u32,
	backing: []T }
```

A generic 2-dimensional array. Unlike the built-in type `matrix`, this can hold data of any type.

### `make_matrix`

```odin
make_matrix :: proc(
	$T: typeid,
	shape: [2]u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	mx: Matrix(T),
	err: runtime.Allocator_Error) #optional_allocator_error
```

### `matrix_clone`

```odin
matrix_clone :: proc(
	mx: ^Matrix($T),
	allocator := context.allocator) -> (
	Matrix(T),
	runtime.Allocator_Error) #optional_allocator_error
```

### `matrix_size`

```odin
matrix_size :: proc(
	mx: ^Matrix($T)) -> u32
```

### `matrix_fill_random`

```odin
matrix_fill_random :: proc(
	mx: ^Matrix($T))
```

Fills the matrix with random bits.

### `matrix_fill`

```odin
matrix_fill :: proc(
	mx: ^Matrix($T),
	value: u8)
```

Sets all cells to the given value.

### `matrix_rank`

```odin
matrix_rank :: proc(
	mx: ^Matrix($T),
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `matrix_write`

```odin
matrix_write :: proc(
	mx: ^Matrix($T),
	index2: [2]u32,
	value: u8)
```

```odin
matrix_write :: proc(
	mx: ^Matrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32,
	value: Backing_Type)
```

Writes the given value to a given cell or range of cells.

### `matrix_read`

```odin
matrix_read :: proc(
	mx: ^Matrix($T),
	index2: [2]u32) -> u8
```

```odin
matrix_read :: proc(
	mx: ^Matrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32) -> Backing_Type
```

Retreive the value of a given cell or range of cells.

### `aprint_matrix`

```odin
aprint_matrix :: proc(
	mx: ^Matrix($T),
	allocator := context.allocator) -> string
```

Pretty-print the matrix.

<pre>
























</pre>
