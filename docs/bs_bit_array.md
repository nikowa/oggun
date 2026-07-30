# bs/bit_array

### `Bit_Array`

```odin
Bit_Array :: struct {
	len: u32,
	buffer: []Backing_Type }
```

A `Bit_Array` is a one-dimensional array of bits.

### `make_bit_array`

```odin
make_bit_array :: proc(
	#any_int len: u32,
	allocator := context.allocator,
	loc := #caller_location) -> (
	array: Bit_Array,
	err: runtime.Allocator_Error) #optional_allocator_error
```

### `clone`

```odin
clone :: proc(
	array: ^Bit_Array,
	allocator := context.allocator) -> (
	Bit_Array,
	runtime.Allocator_Error) #optional_allocator_error
```

### `fill_random`

```odin
fill_random :: proc(
	array: ^Bit_Array)
```

### `fill`

```odin
fill :: proc(
	array: ^Bit_Array,
	value: u8)
```


