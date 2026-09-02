# gx/texture

## **Types**

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
	Should there be a component type (float, integer, normalized, etc.) field?

Describes the size, depth, and number of channels of a texture. This is used for (1) describing how texture data should be interpreted, and (2) constraining texture binding points.

## **Constants**

### **DEFAULT_TEXTURE_SIZE**

```odin
DEFAULT_TEXTURE_SIZE: [2]int : {
	1024,
	1024 }
```

## **Procedures**

### **texture_init**

```odin
texture_init :: proc(
	texture: ^Texture,
	config: Asset_Config,
	shape: Texture_Shape = {})
```

Initializes a **Texture** with the given shape.

### **texture_equals**

```odin
texture_equals :: proc(
	texture0: ^Texture,
	texture1: ^Texture) -> bool
```

Checks if the two **Texture**s are equal, by comparing their shapes and pixels.

### **texture_op**

```odin
texture_op :: proc(
	asset: ^Asset,
	op: Asset_Op,
	dest: Asset_Location = .None,
	src: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> (
	ok: bool)
```

The **Asset** op command of **Texture**. See [am/core](../am_core/) for more info.

### **serialize**

```odin
@require_results
texture_serialize :: proc(
	texture: ^Texture,
	allocator: runtime.Allocator) -> (
	image_bytes: []u8,
	err: os.Error)
```

Serializes a **Texture**. Used by the **Translate** op.

### **deserialize**

```odin
@require_results
texture_deserialize :: proc(
	image_bytes: []u8,
	allocator: runtime.Allocator) -> (
	texture: Texture,
	err: os.Error)
```

Deserializes a **Texture**. Used by the **Translate** op.

### **texture_shapes_compatible**

```odin
texture_shapes_compatible :: proc(
	shape0: Texture_Shape,
	shape1: Texture_Shape) ->
	bool
```

Checks if two **Texture Shapes** are compatible. That is, if they have the same depth, the same number of channels, and the same size (size is not compared if one of the shapes has no size).

### **default_texture_shape**

```odin
default_texture_shape :: proc(
	size: [2]u32 = { 0, 0 },
	channels: u8 = 4,
	depth: u8 = 1) ->
	Texture_Shape
```

<div style="height: 100vh;"></div>
