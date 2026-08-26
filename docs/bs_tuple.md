# bs/tuple

## Types

### `Tuple`

```odin
Tuple :: struct($E: typeid) {
	buffer: []u16
	len: u8 }
```

A `Tuple` is an ordered sequence of (up to `255`) elements from an indeterminate universe (of up to `65_535` elements). Use this when you want a compact array of pointers to elements of a slice. It is approximately $4$ times smaller than a dynamic array of pointers.

## Constants

### `TUPLE_CAP`

```odin
TUPLE_CAP :: 255
```

### `TUPLE_UNIVERSE_CAP`

```odin
TUPLE_UNIVERSE_CAP :: math_bits.U16_MAX
```

## Procedures

### `make_tuple`

```odin
make_tuple :: proc(
	tuple: Tuple($E),
	allocator := context.allocator,
	loc := #caller_location) -> (
	tuple: Tuple(E),
	err: Allocator_Error) #optional_allocator_error
```

### `tuple_append`

```odin
tuple_append :: proc(
	tuple: ^Tuple($E),
	arg: $E,
	loc := #caller_location) -> (
	num_appended: int,
	err: Allocator_Error) #optional_allocator_error
```

```odin
tuple_append :: proc(
	tuple: ^Tuple($E),
	args: ..E,
	loc := #caller_location) -> (
	num_appended: int,
	err: Allocator_Error) #optional_allocator_error
```

### `tuple_elem`

```odin
tuple_elem :: proc(
	tuple: ^Tuple($E),
	#any_int index: int) -> (
	elem: ^E,
	ok: bool) #optional_ok
```

<div style="height: 100vh;"></div>
