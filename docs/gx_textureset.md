# **gx/textureset**

A `Textureset` is a set of `Texture`s (stored by reference). This is the basis for materials, as well as the outputs of shaders. `Textureset_Shape` describes the shape of a `Textueset`. Every shader is associated with a `Textureset_Shape` which describes it's output type. Before a shader is invoked, a `Textureset` of it's exact type must be bound to it. If no `Textureset` is bound, the shader draws directly to framebuffer `0`.

---

### **Textureset**

```odin
Textureset :: struct {
	using asset: Asset,
	textures: []^Texture,
	... }
```

### **Textureset_Shape**

```odin
Textureset_Shape :: []Texture_Shape
```

### **Material_Texture_Index**

```odin
Material_Texture_Index :: enum {
	Base_Color,
	Roughness,
	Metallic }
```

The names of the textures in the default material `Textureset`.

### **Canvas_Texture_Index**

```odin
Canvas_Texture_Index :: enum {
	Color,
	Emission,
	ID }
```

The names of the textures in the default canvas `Textureset`.

---

### **init**

```odin
textureset_init :: proc(
	textureset: ^Textureset,
	config: Asset_Config,
	shape: Textureset_Shape,
	flags: Texture_Create_Flags = {},
	allocator := context.allocator)
```

```odin
textureset_init :: proc(
	textureset: ^Textureset,
	config: Asset_Config,
	textures: []^Texture)
```

Initializes a `Textureset` asset.

### **shape**

```odin
textureset_shape :: proc(
	textureset: ^Textureset,
	allocator := context.allocator) -> (shape: Textureset_Shape)
```

Returns the shape of a textureset. Each texture contains its own shape field. The compound shape of a textureset is constructed on-demand, in order to reduce coupling and keep the data structure compact.

### **command**

```odin
textureset_op :: proc(
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

The asset command [asset command proc](../am_core/#asset_command_proc) of `Textureset`.

<div style="height: 100vh;"></div>
