# gx/core

## **Overview**

## **Types**

### **Graphics_Backend**

```odin
Graphics_Backend :: enum {
	WGPU,
	Vulkan,
	OpenGL }
```

The **OpenGL** backend is fully implemented. The **Vulkan** backend is a work-in-progress. The **WGPU** backend does not exist yet.

### **Graphics_Config**

```odin
Graphics_Config :: struct {
	clear_color: Color }
```

### **MSAA**

```odin
MSAA :: enum {
	Off,
	X2,
	X4,
	X8,
	X16 }
```

### **Graphics_Manager**

```odin
Graphics_Manager :: struct {
	using graphics_config: Graphics_Config,
	using backend: Graphics_Manager_Backend,
	command_buffer: Command_Buffer,
	window_closed: bool,
	active_resolution: [2]f32,
	stopwatch: time.Stopwatch,
	time: f32,
	shaders: [dynamic]^Shader,
	textures: [dynamic]Texture,
	image_shader: Shader,
	text_shader: Shader,
	buffer_shader: Shader,
	rect_shader: Shader,
	line_shader: Shader,
	arc_shader: Shader,
	model_shader: Shader,
	mesh_shader: Shader,
	canvas_texture_sequence: Texture_Sequence,
	frame_count: u32,
	vertex_array: u32,
	vertex_buffer: u32,
	clip_stack: [dynamic]Clip,
	depth_stack: [dynamic]f32 }
```

### **Graphics_Manager_Backend**

```odin
when GRAPHICS_BACKEND == .OpenGL do Graphics_Manager_Backend :: struct { }
else do { }
```

## **Constants**

### **GRAPHICS_BACKEND**

```odin
GRAPHICS_BACKEND: Graphics_Backend :
	#config(GRAPHICS_BACKEND, Graphics_Backend.OpenGL)
```

### **DEFAULT_GRAPHICS_CONFIG**

```odin
DEFAULT_GRAPHICS_CONFIG: Graphics_Config : {
	clear_color = BLACK }
```

## **Procedures**

<div style="height: 100vh;"></div>
