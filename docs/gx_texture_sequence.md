# **gx/texture_sequence**

A `Texture_Sequence` is a set of `Texture`s (stored by reference). This is the basis for materials, as well as the outputs of shaders. `Texture_Sequence_Shape` describes the shape of a `Textueset`. Every shader is associated with a `Texture_Sequence_Shape` which describes it's output type. Before a shader is invoked, a `Texture_Sequence` of it's exact type must be bound to it. If no `Texture_Sequence` is bound, the shader draws directly to framebuffer `0`.

---

### **Texture_Sequence**

```odin
Texture_Sequence :: struct {
	using asset: Asset,
	textures: []^Texture,
	... }
```

### **Texture_Sequence_Shape**

```odin
Texture_Sequence_Shape :: []Texture_Shape
```

### **Material_Texture_Index**

```odin
Material_Texture_Index :: enum {
	Base_Color,
	Roughness,
	Metallic }
```

The names of the textures in the default material `Texture_Sequence`.

### **Canvas_Texture_Index**

```odin
Canvas_Texture_Index :: enum {
	Color,
	Emission,
	ID }
```

The names of the textures in the default canvas `Texture_Sequence`.

---

### **texture_sequence_init**

```odin
texture_sequence_init :: proc(
	texture_sequence: ^Texture_Sequence,
	config: Asset_Config,
	shape: Texture_Sequence_Shape,
	flags: Texture_Create_Flags = {},
	allocator := context.allocator)
```

```odin
texture_sequence_init :: proc(
	texture_sequence: ^Texture_Sequence,
	config: Asset_Config,
	textures: []^Texture)
```

Initializes a `Texture_Sequence` asset.

### **texture_sequence_shape**

```odin
texture_sequence_shape :: proc(
	texture_sequence: ^Texture_Sequence,
	allocator := context.allocator) -> (shape: Texture_Sequence_Shape)
```

Returns the shape of a texture_sequence. Each texture contains its own shape field. The compound shape of a texture_sequence is constructed on-demand, in order to reduce coupling and keep the data structure compact.

### **texture_sequence_op**

```odin
texture_sequence_op :: proc(
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

The asset command [asset command proc](../am_core/#asset_command_proc) of `Texture_Sequence`.

### **texture_sequence_shape_compatible**

```odin
texture_sequence_shape_compatible :: proc(
	texture_sequence: ^Texture_Sequence,
	shape: Texture_Sequence_Shape) ->
	bool
```

Checks if the given **Texture Sequence** is compatible with the given **Texture Sequence Shape**.

<div style="height: 100vh;"></div>
