# **gx/texture**

---

### **Texture**

```odin
Texture :: struct #packed {
	using asset: Asset,
	using shape: Texture_Shape,
	data: []u8,
	... }
```

A texture [asset](../am_core/#asset).

### **Texture_Shape**

```odin
Texture_Shape :: struct #packed {
	size: [2]u32,
	channels: u8,
	depth: u8 }
```

!!! warning "NOTE"
	Should there be a format (float, integer, normalized, etc.) field?

Describes the size, depth, and number of channels of a texture. This is used for (1) describing how texture data should be interpreted, and (2) constraining texture binding points.

### **Texture_Create_Flag**

```odin
Texture_Create_Flag :: enum {
	Allocate_Empty,
	Allocate_Render_Buffer }
```

### **Texture_Create_Flags**

```odin
Texture_Create_Flags :: bit_set[Texture_Create_Flag]
```

---

### **DEFAULT_IMAGE_SIZE**

```odin
DEFAULT_IMAGE_SIZE: [2]int : { 1024, 1024 }
```

---

### **init**

```odin
texture_init :: proc(
	texture: ^Texture,
	config: Asset_Config,
	shape: Texture_Shape = {},
	flags: Texture_Create_Flags = {})
```

Initializes a `Texture` asset.

### **equals**

```odin
texture_equals :: proc(
	texture0: ^Texture,
	texture1: ^Texture) -> bool
```

### **modification_time**

```odin
texture_modification_time :: proc(
	texture: ^Texture,
	location: Asset_Location) -> (modification_time: time.Time)
```

### **command**

```odin
texture_command :: proc(
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

### **is_empty**

```odin
texture_is_empty :: proc(
	texture: ^Texture) -> bool
```

### **serialize**

```odin
texture_serialize :: proc(
	texture: ^Texture,
	allocator: runtime.Allocator) -> (image_bytes: []u8, err: os.Error)
```

### **deserialize**

```odin
texture_deserialize :: proc(
	image_bytes: []u8,
	allocator: runtime.Allocator) -> (texture: Texture, err: os.Error)
```

### **make_image**

```odin
make_image :: proc(
	width: int,
	height: int,
	channels: int,
	allocator := context.allocator) -> (image: im.Image)
```

Helper function for image creation.

<div style="height: 100vh;"></div>
