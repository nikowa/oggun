# **dr/core**

The main type of `dr/core` is the *draw command*. Draw commands follow the naming pattern `Draw_*_Command`, and they derive from `Generic_Command`. A draw command is a record of data corresponding to a single shader program invocation. A draw command instance determines the sources of the inputs and the destinations of the outputs for the invocation.

Draw commands have *params* and *group params*. Instances of the same command that have identical group params are bundled in a batch, to reduce the number of draw calls. Batching is done automatically using reflection, by doing a shallow compare on the `group_params` field.

Draw commands follow this general pattern:

```odin
Draw_*_Command :: struct {
	using base: Generic_Command,
	using params: *,
	using group_params: * }
```

---

### **Draw_Rect_Command**

```odin
Draw_Rect_Command :: struct {
	using base: Generic_Command,
	using params: struct {
		rect: Rect,
		fill_color: Color,
		radius: f32,
		depth: f32,
		stroke: f32,
		stroke_color: Color,
		clip: Clip },
	using group_params: struct {
		output_texture_sequence: ^Texture_Sequence } }
```

### **Draw_Image_Command**

```odin
Draw_Image_Command :: struct {
	using base: Generic_Command,
	using params: struct {
		rect: Rect,
		depth: f32,
		clip: Clip },
	using group_params: struct {
		output_texture_sequence: ^Texture_Sequence = nil,
		image: ^Texture } }
```

!!! warning "NOTE"
	There should be no reason for `params` and `group_params` to have named types. An anonymous struct should be sufficient for the command scheduler to do it's job.

---

### **dr_rect**

```odin
dr_rect :: proc(
	rect: Rect,
	fill_color: Color = BLACK,
	stroke_color: Color = GRAY,
	radius: f32 = 0.0,
	stroke: f32 = 0.0,
	output_texture_sequence: ^Texture_Sequence = nil,
	integer: bool = true)
```

### **dr_line**

```odin
dr_line :: proc(
	points: [2][2]f32,
	color: Color,
	integer: bool = true)
```

### **dr_arc**

```odin
dr_arc :: proc(
	center: [2]f32,
	radius: f32,
	angle_range: [2]f32,
	color: Color,
	integer: bool = true)
```

### **dr_image**

```odin
dr_image :: proc(
	image: ^Texture,
	rect: Rect,
	output_texture_sequence: ^Texture_Sequence,
	integer: bool = true)
```

### **dr_text_box**

```odin
dr_text_box :: proc(
	text: string,
	rect: Rect,
	background_color: Color=0,
	h_align: UI_H_Align = .CENTER,
	v_align: UI_V_Align = .CENTER,
	ratio: f32 = 3.0,
	origin: bit_set[Compass] = {},
	margins: f32 = 4,
	overflow: UI_Overflow = .EXTEND,
	clamp_rect: Rect = {},
	integer: bool = true,
	debug: bool = false) ->
	Rect
```

<div style="height: 100vh;"></div>
