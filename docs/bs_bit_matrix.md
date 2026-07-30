# bs/bit_matrix

### `Bit_Matrix`

```odin
Bit_Matrix :: struct {
	shape: [2]u32,
	backing: Bit_Array }
```

### `make_bit_matrix`

```odin
make_bit_matrix :: proc(
	shape: [2]u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	bit_matrix: Bit_Matrix,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Allocates a bit matrix.

### `clone`

```odin
clone :: proc(
	bit_matrix: ^Bit_Matrix,
	allocator := context.allocator) -> (
	Bit_Matrix,
	runtime.Allocator_Error) #optional_allocator_error
```

### `size`

```odin
size :: proc(
	bit_matrix: ^Bit_Matrix) -> u32
```

### `fill_random`

```odin
fill_random :: proc(
	bit_matrix: ^Bit_Matrix)
```

Fills the matrix with random bits.

### `fill`

```odin
fill :: proc(
	bit_matrix: ^Bit_Matrix,
	value: u8)
```

Sets all cells to the given value.

### `rank`

```odin
rank :: proc(
	bit_matrix: ^Bit_Matrix,
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `write`

```odin
write :: proc(
	bit_matrix: ^Bit_Matrix,
	index2: [2]u32,
	value: u8)
```

```odin
write :: proc(
	bit_matrix: ^Bit_Matrix,
	first_index2: [2]u32,
	last_index2: [2]u32,
	value: Backing_Type)
```

Writes the given value to a given cell or range of cells.

### `read`

```odin
read :: proc(
	bit_matrix: ^Bit_Matrix,
	index2: [2]u32) -> u8
```

```odin
read :: proc(
	bit_matrix: ^Bit_Matrix,
	first_index2: [2]u32,
	last_index2: [2]u32) -> Backing_Type
```

Retreive the value of a given cell or range of cells.

### `aprint`

```odin
aprint :: proc(
	bit_matrix: ^Bit_Matrix,
	allocator := context.allocator) -> string
```

Pretty-print the matrix.
