# Graphics

### Types

#### `Image`

```c
Image :: struct {
	url: db.URL,
	using image: im.Image }
```

#### `Thread_Data`

```c
Thread_Data :: struct {
	index: u32,
	... }
```

#### `image_equiv`

```c
image_equiv :: proc(
	a: ^Image,
	b: ^Image) -> bool
```

#### `import_or_retreive_image`

Get an image from the database by URL. If no such image exists, load it from file and add to the database.

```c
import_or_retreive_image :: proc(
	database: ^db.Database,
	url: db.URL,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```

#### `serialize`

Serialize an `Image` object.

```c
serialize :: proc(
	image: ^Image,
	allocator: rt.Allocator) -> (bytes: []u8, err: os.Error)
```

#### `deserialize`

Deserialize an `Image` object.

```c
deserialize :: proc(
	bytes: []u8,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```

#### `load_from_path`

```c
load_from_path :: proc(
	path: string,
	url: db.URL,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```
