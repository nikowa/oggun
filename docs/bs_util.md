# bs/util

## **Types**

### ID

```odin
ID :: uintptr
```

### Range

```odin
Range :: struct($T: typeid) {
	x: [2]T,
	y: [2]T }
```

## **Procedures**

### index2_to_index

```odin
index2_to_index :: proc(shape: [2]u32, index2: [2]u32) -> u32
```

### index2_to_index_triangular

```odin
index2_to_index_triangular :: proc(shape: [2]u32, index2: [2]u32) -> u32
```

### index2_triangulate

```odin
index2_triangulate :: proc(index2: [2]u32) -> [2]u32
```

If the indexed cell is above the main diagonal, returns the same index. Otherwise, returns the mirrored index.

<pre>
























</pre>
