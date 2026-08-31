# bs/tuple

*Test coverage: 100%*

## **Overview**

A `Tuple` is an ordered sequence of elements from another ordered sequence (a universe). It is the compact equivalent to a slice of pointers. `E` is the element type. `U` is the largest unsigned integer type that can contain the size of the universe. `B` is the largest unsigned integer type that can contain the length of the array.

## **Example**

The following code creates a cave of 8000 :material-spider:s (the universe of the tuple), then it creates a tuple that can store up to 4 :material-spider:s from a cave no larger than 32767. Then it puts :material-spider:s number 1512, 5616, 3946, and 1082 in that tuple. Then it checks to confirm that there are 4 :material-spider:s in the tuple and that they are the :material-spider:s we intended to put in the tuple.

```odin
spider_cave := make([]Spider, 8000)
spider_group: og.make_tuple(Spider, i16, u8, 0, 4)
og.tuple_append(&spider_group, 1512, spider_cave)
og.tuple_append(&spider_group, 5616, spider_cave)
og.tuple_append(&spider_group, 3946, spider_cave)
og.tuple_append(&spider_group, 1082, spider_cave)
assert(og.tuple_len(&spider_group) == 4)
assert(og.tuple_get(&spider_group, 0) == &spider_cave[1512])
assert(og.tuple_get(&spider_group, 1) == &spider_cave[5616])
assert(og.tuple_get(&spider_group, 2) == &spider_cave[3946])
assert(og.tuple_get(&spider_group, 3) == &spider_cave[1082])
```

If the spiders were stored in a slice of pointers, each :material-spider: would have taken up 8 bytes. Instead, when you use a tuple, each :material-spider: takes only 1 byte. Also, the `len` component of the tuple scales logarithmically with the size of the spider cave, so the smaller the cave, the smaller each group. If you have dozens or hundreds of groups, you can save several kilobytes by using a smaller integer type for `B`.

## **Types**

### Tuple

```odin
Tuple :: struct(
	$E: typeid,
	$U: typeid,
	$B: typeid) {
	indexes: Index([]E, U),
	len: B }
```

## **Procedures**

### make_tuple

```odin
make_tuple :: proc {
	make_tuple_len,
	make_tuple_len_cap,
	make_tuple_from_ptrs,
	make_tuple_from_indexes }
```

### make_tuple_len

```odin
make_tuple_len :: proc(
	$E: typeid,
	$U: typeid,
	$B: typeid,
	#any_int len: u8,
	allocator := context.allocator,
	loc := #caller_location) -> (
	tuple: Tuple(E, U, B),
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### make_tuple_len_cap

```odin
make_tuple_len_cap :: proc(
	$E: typeid,
	$U: typeid,
	$B: typeid,
	#any_int len: u8,
	#any_int cap: u8,
	allocator := context.allocator,
	loc := #caller_location) -> (
	tuple: Tuple(E, U, B),
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### make_tuple_from_ptrs

```odin
make_tuple_from_ptrs :: proc(
	$E: typeid,
	$U: typeid,
	$B: typeid,
	elems: []^E,
	universe: []E,
	allocator := context.allocator,
	loc := #caller_location) -> (
	tuple: Tuple(E, U, B),
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### make_tuple_from_indexes

```odin
make_tuple_from_indexes :: proc(
	$E: typeid,
	$U: typeid,
	$B: typeid,
	indexes: []U,
	universe: []E,
	allocator := context.allocator,
	loc := #caller_location) -> (
	tuple: Tuple(E, U, B),
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### delete_tuple

```odin
delete_tuple :: proc(
	tuple: ^Tuple($E, $U, $B),
	allocator := context.allocator,
	loc := #caller_location) -> (
	err: runtime.Allocator_Error)
```

### tuple_append

```odin
tuple_append :: proc {
	tuple_append_by_ptr,
	tuple_append_by_index }
```

### tuple_append_by_ptr

```odin
tuple_append_by_ptr :: proc(
	tuple: ^Tuple($E, $U, $B),
	arg: ^E,
	universe: []E,
	loc := #caller_location) -> (
	n: int,
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### tuple_append_by_index

```odin
tuple_append_by_index :: proc(
	tuple: ^Tuple($E, $U, $B),
	index: int,
	universe: []E,
	loc := #caller_location) -> (
	n: int,
	err: runtime.Allocator_Error)
	#optional_allocator_error
```

### tuple_get

```odin
tuple_get :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B),
	universe: []E,
	#any_int index: u8) -> (
	elem: ^E,
	ok: bool)
	#optional_ok
```

### tuple_set

```odin
tuple_set :: proc {
	tuple_set_by_index,
	tuple_set_by_ptr }
```

### tuple_set_by_index

```odin
tuple_set_by_index :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B),
	#any_int i: u8,
	index: int,
	universe: []E)
```

### tuple_set_by_ptr

```odin
tuple_set_by_ptr :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B),
	#any_int i: u8,
	arg: ^E,
	universe: []E)
```

### tuple_len

```odin
tuple_len :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B)) ->
	int
```

### tuple_cap

```odin
tuple_cap :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B)) ->
	int
```

### tuple_iterate

```odin
tuple_iterate :: proc "contextless" (
	tuple: ^Tuple($E, $U, $B),
	universe: []E, i: ^B) -> (
	elem: ^E,
	ok: bool)
```

<div style="height: 100vh;"></div>
