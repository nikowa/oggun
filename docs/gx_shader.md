# gx/shader

## **Overview**

A shader is a graphical GPU program.

## **Types**

### **Shader_Config**

```odin
Shader_Config :: struct {
	vert_url: URL,
	frag_url: URL,
	inputs_shape: Texture_Sequence_Shape,
	outputs_shape: Texture_Sequence_Shape }
```

### **Shader**

```odin
Shader :: struct {
	using asset: Asset,
	using shader_config: Shader_Config,
	vert_asset, frag_asset: String_Asset,
	handle: u32,
	last_modification_time: time.Time,
	compiled: bool }
```

### **Rect_Shader_Uniforms**

```odin
Rect_Shader_Uniforms :: enum {
	RES        = 0,
	DEPTH      = 1,
	FILL_COLOR = 2,
	ROUNDING   = 3 }
```

### **Line_Shader_Uniforms**

```odin
Line_Shader_Uniforms :: enum {
	RES = 0 }
```

### **Arc_Shader_Uniforms**

```odin
Arc_Shader_Uniforms :: enum {
	RES = 0 }
```

### **Model_Shader_Uniforms**

```odin
Model_Shader_Uniforms :: enum {
	MODEL_MATRIX             = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	CAMERA_POSITION          = 3,
	CAMERA_FAR_CLIP          = 4,
	HAZE_COLOR               = 5,
	METALLIC_FACTOR          = 6,
	ROUGHNESS_FACTOR         = 7 }
```

### **Effect_Shader_Uniforms**

```odin
Effect_Shader_Uniforms :: enum {
	NODE_MATRIX              = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	TIME                     = 3,
	CAMERA_FAR_CLIP          = 4,
	CAMERA_POSITION          = 5,
	ID                       = 6 }
```

### **Mesh_Shader_Uniforms**

```odin
Mesh_Shader_Uniforms :: enum {
	NODE_MATRIX              = 0,
	CAMERA_POSITION_MATRIX   = 1,
	CAMERA_PROJECTION_MATRIX = 2,
	CAMERA_FAR_CLIP          = 3 }
```

### **Buffer_Shader_Uniforms**

```odin
Buffer_Shader_Uniforms :: enum {
	RES = 0 }
```

### **Image_Shader_Uniforms**

```odin
Image_Shader_Uniforms :: enum {
	RES = 0 }
```

### **Text_Uniforms**

```odin
Text_Uniforms :: enum {
	RES = 0,
	SYMBOL_SIZE = 1,
	TIME = 2 }
```

### **GLSL_Builder**

```odin
GLSL_Builder :: struct {
	string_builder: strings.Builder,
	includes: [dynamic]string,
	uniform_variables: [dynamic][2]string,
	macros: [dynamic]string,
	global_variables: [dynamic][2]string }
```

## **Constants**

### **DEFAULT_SHADER_CONFIG**

```odin
DEFAULT_SHADER_CONFIG: Shader_Config : {
	vert_url = DEFAULT_URL,
	frag_url = DEFAULT_URL }
```

## **Procedures**

### **shader_init**

```odin
shader_init :: proc(
	shader: ^Shader,
	asset_config: Asset_Config,
	config: Shader_Config) -> (
	err: os.Error)
```

### **init_glsl_builder**

```odin
init_glsl_builder :: proc(
	glsl_builder: ^GLSL_Builder) -> (
	res: ^strings.Builder,
	err: runtime.Allocator_Error)
```

### **destroy_glsl_builder**

```odin
destroy_glsl_builder :: proc(
	glsl_builder: ^GLSL_Builder)
```

### **glsl_builder_to_string**

```odin
glsl_builder_to_string :: proc(
	glsl_builder: ^GLSL_Builder) ->
	string
```

### **shader_op**

```odin
shader_op :: proc(
	base: ^Asset,
	op: Asset_Op,
	dest: Asset_Location = .None,
	src: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> (
	ok: bool)
```

<div style="height: 100vh;"></div>
