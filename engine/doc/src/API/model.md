# Model

### Types

#### `Model`

```c
Model :: struct {
	... }
```

#### `import_or_retreive_model`

Get a model from the database by URL. If no such model exists, load it from file and add to the database.

```c
import_or_retreive_model :: proc(
	database: ^db.Database,
	url: db.URL,
	allocator: rt.Allocator) -> (model: Model, err: os.Error)
```

#### `model_serialize`

Serialize an `Model` object.

```c
model_serialize :: proc(
	model: ^Model,
	allocator: rt.Allocator) -> (bytes: []u8, err: os.Error)
```

#### `model_deserialize`

Deserialize an `model` object.

```c
model_deserialize :: proc(
	bytes: []u8,
	allocator: rt.Allocator) -> (model: Model, err: os.Error)
```

#### `load_from_path`

```c
load_from_path :: proc(
	path: string,
	url: db.URL,
	allocator: rt.Allocator) -> (model: Model, err: os.Error)
```

#### `upload_model`

Upload model to GPU memory.

```c
upload_model :: proc(
	graphics_context: ^Graphics_Context,
	model: ^Model) -> bool
```

#### `download_model`

Release the GPU memory associated with the model.

```c
download_model :: proc(
	model: ^Model)
```

#### `model_loaded`

Check if the model has been uploaded to the GPU.

```c
model_loaded :: proc(
	model: ^Model) -> bool
```

