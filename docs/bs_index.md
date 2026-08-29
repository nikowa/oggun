# bs/index

*Test coverage: 100%*

## **Overview**

`Index` is a compact index type, with helper functions for using it safely. It helps with converting pointers to indexes and indexes to pointers, and it helps indicate what type is being indexed, as it is dependent on it.

## **Example**

The following example shows how to create an 8-bit index into an array of 100 :material-spider:s, how to make it point to the 10-th :material-spider:, and how to retreive the 10-th :material-spider: using the index.

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

## **Procedures**

### make_index

```odin
make_index :: proc "contextless" (
	$S: typeid,
	$B: typeid) -> Index(S, B)
```

### index_get

```odin
index_get :: proc "contextless" (
	ix: ^$I/Index($S, $B),
	array: S) -> (ptr: ^intrinsics.type_elem_type(S), ok: bool)
```

### index_set

```odin
index_set :: proc "contextless" (
	ix: ^$I/Index($S, $B),
	array: S,
	arg: ^intrinsics.type_elem_type(S)) -> (ok: bool)
```

### index_is_nil

```odin
index_is_nil :: proc "contextless" (
	ix: ^$I/Index($S, $B)) -> bool
```

### index_set_nil

```odin
index_set_nil :: proc "contextless" (
	ix: ^$I/Index($S, $B))
```

<div style="height: 100vh;"></div>
