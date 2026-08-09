# bs/bit_array

**test coverage** 100%


### `Bit_Array`

```odin
Bit_Array :: struct {
	len: u32,
	buffer: []Backing_Type }
```

A `Bit_Array` is a one-dimensional array of bits.

### `make`

```odin
make_bit_array :: proc(
	#any_int len: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Bit_Array`, allocating a buffer with the provided allocator.

```odin
make_bit_array :: proc(
	#any_int len: u32,
	buffer: []Backing_Type) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Bit_Array`, using an existing buffer.

### `clone`

```odin
clone_bit_array :: proc(
	array: ^Bit_Array,
	allocator := context.allocator) -> (
	Bit_Array,
	runtime.Allocator_Error) #optional_allocator_error
```

Creates a new `Bit_Array` by copying the contents of an existing one.

### `fill_random`

```odin
bit_array_fill_random :: proc(
	array: ^Bit_Array)
```

Fills the array with random bits.

### `fill`

```odin
bit_array_fill :: proc(
	array: ^Bit_Array,
	value: u8)
```

Fills the array with the given value, truncated to $[0, 1]$.

### `rank`

```odin
bit_array_rank :: proc(
	array: ^Bit_Array,
	value: u8) -> (rank: u32)
```

Counts the number of occurrences of the given value in the array.

### `aprint`

```odin
aprint_bit_array :: proc(
	array: ^Bit_Array,
	allocator := context.allocator) -> string
```

Pretty-prints the array.

### `delete`

```odin
delete_bit_array :: proc(
	array: ^Bit_Array,
	allocator := context.allocator)
```

### `equals`

```odin
bit_array_equal :: proc(
	array0, array1: ^Bit_Array) -> bool
```

Compares two bit arrays.

### `set`

```odin
bit_array_set :: proc(
	array: ^Bit_Array,
	#any_int j: u32)
```

### `zero`

```odin
bit_array_zero :: proc(
	array: ^Bit_Array,
	#any_int j: u32)
```

```odin
bit_array_zero :: proc(
	array: ^Bit_Array,
	range: [2]u32)
```

### `read`

```odin
bit_array_read :: proc(
	array: ^Bit_Array,
	#any_int j: u32) -> u8
```

```odin
bit_array_read :: proc(
	array: ^Bit_Array,
	range: [2]u32) -> Backing_Type
```

### `write`

```odin
bit_array_write :: proc(
	array: ^Bit_Array,
	#any_int j: u32,
	value: u8)
```

```odin
bit_array_write :: proc(
	array: ^Bit_Array,
	range: [2]u32,
	value: Backing_Type)
```

### `or`

```odin
bit_array_or :: proc(
	a, b: Bit_Array,
	result: ^Bit_Array)
```

```odin
bit_array_or :: proc(
	a, b: Bit_Array,
	allocator := context.allocator) -> (result: Bit_Array)
```

### `xor`

```odin
bit_array_xor :: proc(
	a, b: Bit_Array,
	result: ^Bit_Array)
```

```odin
bit_array_xor :: proc(
	a, b: Bit_Array,
	allocator := context.allocator) -> (result: Bit_Array)
```

### `and`

```odin
bit_array_and :: proc(
	a, b: Bit_Array,
	result: ^Bit_Array)
```

```odin
bit_array_and :: proc(
	a, b: Bit_Array,
	allocator := context.allocator) -> (result: Bit_Array)
```

### `and_not`

```odin
bit_array_and_not :: proc(
	a, b: Bit_Array,
	result: ^Bit_Array)
```

```odin
bit_array_and_not :: proc(
	a, b: Bit_Array,
	allocator := context.allocator) -> (result: Bit_Array)
```

### `not`

```odin
bit_array_not :: proc(
	bit_array: Bit_Array,
	result: ^Bit_Array)
```

```odin
bit_array_not :: proc(
	bit_array: Bit_Array,
	allocator := context.allocator) -> (result: Bit_Array)
```

### `copy`

```odin
bit_array_copy :: proc(
	dest, src: ^Bit_Array)
```

Copies one array into another array.

### `copy_range`

```odin
bit_array_copy_range :: proc(
	dest, src: ^Bit_Array,
	dest_range, src_range: [2]u32)
```

Copies a range of one array into a range of another array.

### `resize`

```odin
bit_array_resize :: proc(
	bit_array: ^Bit_Array,
	len: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (err: runtime.Allocator_Error)
```

Resizes the given array. If the backing buffer is insufficient or excessive, it is reallocated.

### `extend`

```odin
bit_array_extend :: proc(
	bit_array: ^Bit_Array,
	pre, post: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (err: runtime.Allocator_Error)
```

Extends the given array by prepending `pre` number of zeroes and appending `post` number of zeroes.

### `slice`

```odin
bit_array_slice :: proc(
	array: ^Bit_Array,
	range: [2]u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new array by copying an range of bits from `array`.

### `cat`

```odin
bit_array_cat :: proc(
	array0, array1: ^Bit_Array,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a new array by concatenating two existing arrays.

### `stack`

```odin
bit_array_stack :: proc(
	arrays, []^Bit_Array,
	orientation: Orientation,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Creates a `Bit_Matrix` by stacking several `Bit_Array`s. If `orientation` is `.Horizontal`, the arrays are treated as rows; and if it's `.Vertical`, they are treated as columns.

### `split`

```odin
bit_array_split :: proc(
	array: ^Bit_Array,
	index: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array0, array1: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

Splits an array in two, such that the 2nd array start at `index`.

<pre>
























</pre>
