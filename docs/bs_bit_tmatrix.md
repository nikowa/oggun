# bs/bit_tmatrix

### `Bit_TMatrix`

```odin
Bit_TMatrix :: struct {
	shape: u32,
	backing: Bit_Array }
```

A triangular bit matrix. All the cells below the main diagonal are `0`. This takes approximately half as much memory as a regular matrix.

### `make`

```odin
make_bit_tmatrix :: proc(
	shape: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	bit_tmatrix: Bit_TMatrix,
	err: runtime.Allocator_Error) #optional_allocator_error
```

### `clone`

```odin
clone_bit_tmatrix :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	allocator := context.allocator) -> (
	Bit_TMatrix,
	runtime.Allocator_Error) #optional_allocator_error
```

### `size`

```odin
bit_tmatrix_size :: proc(
	bit_tmatrix: ^Bit_TMatrix) -> u32
```

### `fill_random`

```odin
bit_tmatrix_fill_random :: proc(
	bit_tmatrix: ^Bit_TMatrix)
```

Fills the matrix with random bits.

### `fill`

```odin
bit_tmatrix_fill :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	value: u8)
```

Sets all cells to the given value.

### `rank`

```odin
bit_tmatrix_rank :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `write`

```odin
bit_tmatrix_write :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	index2: [2]u32,
	value: u8)
```

Writes the given value to a given cell or range of cells.

### `read`

```odin
bit_tmatrix_read :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	index2: [2]u32) -> u8
```

Retreive the value of a given cell or range of cells.

### `aprint`

```odin
bit_tmatrix_aprint :: proc(
	bit_tmatrix: ^Bit_TMatrix,
	allocator := context.allocator) -> string
```

Pretty-print the matrix.

<pre>
























</pre>
