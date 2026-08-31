# bs/index

*Test coverage: 100%*

## **Overview**

`Index` is a compact index type, with helper functions for using it safely. It helps with converting pointers to indexes and indexes to pointers, and it helps indicate what type is being indexed, as it is dependent on it.

## **Example**

The following example shows how to create an 8-bit index into a universe of 100 :material-spider:s, how to make it point to the 10-th :material-spider:, and how to retreive the 10-th :material-spider: using the index.

```odin
	spiders := make([]Spider, 100)
	index: og.Index([]Spider, i8) = og.make_index([]Spider, i8)
	assert(og.index_is_nil(&index))
	assert(og.index_set(&index, spiders, &spiders[10]))
	spider_10, ok := og.index_get(&index, spiders)
	assert(ok)
	assert(spider_10 == &spiders[10])
```

## **Types**

### Index

```odin
Index :: struct($S: typeid, $B: typeid)
	where intrinsics.type_is_slice(S) &&
	      intrinsics.type_is_integer(B) &&
	      ! intrinsics.type_is_unsigned(B) {
	value: B }
```

The **Index** type. `S` is the type of it's universe, which must be a slice. `B` is the backing type, which stores the index, and must have a capacity no smaller than the length of the universe. `B` must be signed, because a value of `-1` indicates an index pointing to nothing, ie. a nil index.

## **Procedures**

### make_index

```odin
make_index :: proc "contextless" (
	$S: typeid,
	$B: typeid) ->
	Index(S, B)
```

Creates an **Index** and initializes it to nil. Note that an uninitialized **Index** points to the 0th element of it's universe.

### index_get

```odin
index_get :: proc "contextless" (
	ix: ^$I/Index($S, $B),
	universe: S) -> (
	ptr: ^intrinsics.type_elem_type(S),
	ok: bool)
```

Produces a pointer to the element of the universe which the **Index** points to. Returns `nil, false` if the **Index** was nil or out of bounds of the given universe.

### index_set

```odin
index_set :: proc "contextless" (
	ix: ^$I/Index($S, $B),
	universe: S,
	arg: ^intrinsics.type_elem_type(S)) -> (
	ok: bool)
```

Sets the **Index** to point to the given element of the universe. Returns `false` if the **Index** is nil or out of bounds of the given universe.

### index_is_nil

```odin
index_is_nil :: proc "contextless" (
	ix: ^$I/Index($S, $B)) -> bool
```

Checks if the **Index** points to nothing.

### index_set_nil

```odin
index_set_nil :: proc "contextless" (
	ix: ^$I/Index($S, $B))
```

Sets the **Index** to point to nothing.

<div style="height: 100vh;"></div>
