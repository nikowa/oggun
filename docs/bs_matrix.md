# bs/matrix

### `Matrix`

```odin
Matrix :: struct($T: typeid) {
	shape: [2]u32,
	backing: []T }
```

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

### `clone`

```odin
clone :: proc(
	mx: ^Matrix($T),
	allocator := context.allocator) -> (
	Matrix(T),
	runtime.Allocator_Error) #optional_allocator_error
```

### `size`

```odin
size :: proc(
	mx: ^Matrix($T)) -> u32
```

### `fill_random`

```odin
fill_random :: proc(
	mx: ^Matrix($T))
```

Fills the matrix with random bits.

### `fill`

```odin
fill :: proc(
	mx: ^Matrix($T),
	value: u8)
```

Sets all cells to the given value.

### `rank`

```odin
rank :: proc(
	mx: ^Matrix($T),
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `write`

```odin
write :: proc(
	mx: ^Matrix($T),
	index2: [2]u32,
	value: u8)
```

```odin
write :: proc(
	mx: ^Matrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32,
	value: Backing_Type)
```

Writes the given value to a given cell or range of cells.

### `read`

```odin
read :: proc(
	mx: ^Matrix($T),
	index2: [2]u32) -> u8
```

```odin
read :: proc(
	mx: ^Matrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32) -> Backing_Type
```

Retreive the value of a given cell or range of cells.

### `aprint`

```odin
aprint :: proc(
	mx: ^Matrix($T),
	allocator := context.allocator) -> string
```

Pretty-print the matrix.
