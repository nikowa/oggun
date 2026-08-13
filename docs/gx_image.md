# gx/image

### `Image_Asset`

```odin
Image_Asset :: struct {
	using asset: Asset,
	using image: im.Image,
	... }
```

### `DEFAULT_IMAGE_SIZE`

```odin
DEFAULT_IMAGE_SIZE: [2]int : { 1024, 1024 }
```

### `init`

```odin
image_asset_init :: proc(
	image: ^Image_Asset,
	config: Asset_Config,
	allocate_empty: bool = false,
	add_render_buffer: bool = false)
```

```
Image_Params
Image_Ephems
```

### `make_image`

```odin
make_image :: proc(
	width: int,
	height: int,
	$channels: int,
	allocator := context.allocator) -> (image: im.Image)
```

!!! note "TODO"
	Make `channels` non-comptime.

Helper function for image creation.

<pre>























</pre>
