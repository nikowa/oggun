# bs/tmatrix

### `TMatrix`

```odin
TMatrix :: struct($T: typeid) {
	shape: u32,
	backing: []T }
```

A generic triangular matrix. All the cells below the main diagonal are `0`. This takes approximately half as much memory as a regular matrix.

### `make`

```odin
make_tmatrix :: proc(
	$T: typeid,
	shape: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	mx: TMatrix(T),
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `TMatrix`.

### `clone`

```odin
tmatrix_clone :: proc(
	mx: ^TMatrix($T),
	allocator := context.allocator) -> (
	TMatrix(T),
	runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `TMatrix` by copying an existing one.

### `size`

```odin
tmatrix_size :: proc(
	mx: ^TMatrix($T)) -> u32
```

Counts the number of cells.

### `fill_random`

```odin
tmatrix_fill_random :: proc(
	mx: ^TMatrix($T))
```

Fills all cells in and above the main diagonal with random bits.

### `fill`

```odin
tmatrix_fill :: proc(
	mx: ^TMatrix($T),
	value: u8)
```

Sets all cells in and above the main diagonal with the given value.

### `rank`

```odin
tmatrix_rank :: proc(
	mx: ^TMatrix($T),
	value: u8) -> (
	rank: u32)
```

Counts the number of occurrences of the given value.

### `write`

```odin
tmatrix_write :: proc(
	mx: ^TMatrix($T),
	index2: [2]u32,
	value: u8)
```

```odin
tmatrix_write :: proc(
	mx: ^TMatrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32,
	value: Backing_Type)
```

Writes the given value to a given cell or range of cells.

### `read`

```odin
tmatrix_read :: proc(
	mx: ^TMatrix($T),
	index2: [2]u32) -> u8
```

```odin
tmatrix_read :: proc(
	mx: ^TMatrix($T),
	first_index2: [2]u32,
	last_index2: [2]u32) -> Backing_Type
```

Retreive the value of a given cell or range of cells.

### `aprint`

```odin
aprint_tmatrix :: proc(
	mx: ^TMatrix($T),
	allocator := context.allocator) -> string
```

Pretty-print the matrix.

<pre>
























</pre>
