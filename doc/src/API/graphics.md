# Graphics

### Types

#### `Image`

```c
Image :: struct {
	url: db.URL,
	using image: im.Image }
```

### Procedures

#### `image_equiv`

```c
image_equiv :: proc(
	a: ^Image,
	b: ^Image) -> bool
```

#### `import_or_retreive_image`

```c
import_or_retreive_image :: proc(
	database: ^db.Database,
	url: db.URL,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```

<details><summary>Description</summary>
Get an image from the database by URL. If no such image exists, load it from file and add to the database.
</details>

#### `image_serialize`

```c
image_serialize :: proc(
	image: ^Image,
	allocator: rt.Allocator) -> (bytes: []u8, err: os.Error)
```

<details><summary>Description</summary>
Serialize an `Image` object.
</details>

#### `image_deserialize`

```c
image_deserialize :: proc(
	bytes: []u8,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```

<details><summary>Description</summary>
Deserialize an `Image` object.
</details>

#### `load_from_path`

```c
load_from_path :: proc(
	path: string,
	url: db.URL,
	allocator: rt.Allocator) -> (image: Image, err: os.Error)
```

#### `upload_image`

```c
upload_image :: proc(
	image: ^Image) -> bool
```

<details><summary>Description</summary>
Upload image to GPU memory.
</details>

#### `download_image`

```c
download_image :: proc(
	image: ^Image)
```

<details><summary>Description</summary>
Release the GPU memory associated with the image.
</details>

#### `image_loaded`

```c
image_loaded :: proc(
	image: ^Image) -> bool
```

<details><summary>Description</summary>
Check if the image has been uploaded to the GPU.
</details>
