# Scene

A scene determines how 3D entities should be rendered. To render any 3D entity, you need a scene and a camera. A scene conotains a scene tree, which can be used to arrange any arbitrary objects in a hierarchy of 3D transforms. The scene tree is optional.

### Types

#### `Scene_Config`

```c
Scene_Config :: struct {
	url: db.URL,
	haze_color: [3]f32 }
```

#### `Scene`

```c
Scene :: struct {
	using config: Scene_Config,
	tree: Tree }
```

#### `Tree`

```c
Tree :: struct {
	root: ^Node }
```

#### `Node_Render_Proc`

```c
Node_Render_Proc :: #type proc(
	graphics_context: ^gx.Graphics_Context,
	scene: ^Scene,
	camera_node: ^Camera_Node,
	node: ^Node)
```

#### `Node_Tick_Proc`

```c
Node_Tick_Proc :: #type proc(
	node: ^Node)
```

#### `Node_Config`

```c
Node_Config :: struct {
	name: string,
	render_proc: Node_Render_Proc,
	tick_proc: Node_Tick_Proc,
	translate: [3]f32,
	rotate: quaternion128,
	scale: [3]f32,
	visible: bool }
```

#### `Node`

```c
Node :: struct {
	using config: Node_Config,
	parent: ^Node,
	first_child: ^Node,
	last_child: ^Node,
	first_sibling: ^Node,
	next_sibling: ^Node,
	prev_sibling: ^Node }
```

#### `Tree_Iterator`

```c
Tree_Iterator :: struct {
	curr: ^Node }
```

#### `Camera_Config`

```c
Camera_Config :: struct {
	focal_length: f32,
	sensor_size: [2]f32,
	near_clip: f32,
	far_clip: f32 }
```

#### `Camera`

```c
Camera :: struct {
	using config: Camera_Config,
	view_matrix: matrix[4, 4]f32,
	projection_matrix: matrix[4, 4]f32,
	camera_matrix: matrix[4, 4]f32,
	local_matrix: matrix[4, 4]f32 }
```

#### `Camera_Node`

```c
Camera_Node :: struct {
	node: Node,
	using camera: ^Camera }
```

#### `Model_Node`

```c
Model_Node :: struct {
	node: Node,
	using model: ^gx.Model }
```

### Procedures

#### `make_scene`

The intended way to construct a `Scene`.

```c
make_scene :: proc(
	url: db.URL) -> (scene: Scene)
```

#### `scene_attach`

Attach node as a last sibling to the root node of the given scene.

```c
scene_attach :: proc(
	scene: ^Scene,
	child: ^Node)
```

#### `default_node_config`

```c
default_node_config :: proc(
	name: string) -> (node_config: Node_Config)
```

#### `render_node`

Call the render proc on the given node, if hooked.

```c
render_node :: proc(
	graphics_context: ^gx.Graphics_Context,
	scene: ^Scene,
	camera_node: ^Camera_Node,
	node: ^Node)
```

#### `tick_node`

Call the tick proc on the given node, if hooked.

```c
tick_node :: proc(
	node: ^Node)
```

#### `render_scene`

Render a whole scene with the given camera. This renders all nodes, in breadth-first order.

```c
render_scene :: proc(
	graphics_context: ^gx.Graphics_Context,
	scene: ^Scene,
	camera_node: ^Camera_Node)
```

#### `tick_scene`

Tick the whole scene. This calls the tick procs on all nodes, in breadth-first order.

```c
tick_scene :: proc(
	scene: ^Scene)
```

#### `init_node`

```c
init_node :: proc(
	node: ^Node,
	config: Node_Config)
```

#### `make_node`

```c
make_node :: proc(
	config: Node_Config,
	allocator: rt.Allocator) -> (node: ^Node)
```

#### `tree_attach_root`

Set a node as the root of a given tree.

```c
tree_attach_root :: proc(
	tree: ^Tree,
	node: ^Node)
```

#### `node_attach_sibling`

Add a sibling to a given node.

```c
node_attach_sibling :: proc(
	node: ^Node,
	sibling: ^Node)
```

#### `node_attach_child`

Add a child to a given node.

```c
node_attach_child :: proc(
	node: ^Node,
	child: ^Node)
```

#### `node_detach`

Detach a given node from its tree. Its siblings are attached to one another and its children remain on the detached node.

```c
node_detach :: proc(
	node: ^Node)
```

#### `node_object`

Get an object from a point to its node field.

```c
node_object :: proc(
	node: ^Node,
	$T: typeid,
	$field_name: string) -> (^T)
```

#### `tree_iterator_root`

Create a tree iterator, starting at the root.

```c
tree_iterator_root :: proc(
	tree: ^Tree) -> Tree_Iterator
```

#### `tree_iterator_node`

Create a tree iterator, starting from a given node.

```c
tree_iterator_node :: proc(
	node: ^Node) -> Tree_Iterator
```

#### `tree_iterate_next`

```c
tree_iterate_next :: proc "contextless" (
	iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool)
```

#### `tree_iterate_prev`

```c
tree_iterate_prev :: proc "contextless" (
	iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool)
```

#### `tree_iterate_next_sibling`

```c
tree_iterate_next_sibling :: proc "contextless" (
	iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool)
```

#### `tree_iterate_prev_sibling`

```c
tree_iterate_prev_sibling :: proc "contextless" (
	iterator: ^Tree_Iterator) -> (node: ^Node, ok: bool)
```

#### `tree_search_by_name`

```c
tree_search_by_name :: proc(
	tree: ^Tree,
	name: string) -> (result: ^Node)
```

#### `tree_search_by_proc`

```c
tree_search_by_proc :: proc(
	tree: ^Tree,
	condition_proc: proc(node: ^Node, user_data: $T) -> bool,
	user_data: T) -> (result: ^Node)
```

#### `make_camera_node`

```c
make_camera_node :: proc(
	node_config: Node_Config,
	camera: ^Camera,
	allocator: rt.Allocator) -> (camera_node: ^Camera_Node)
```

#### `render_camera_node`

```c
render_camera_node :: proc(
	graphics_context: ^gx.Graphics_Context,
	scene: ^Scene,
	camera_node: ^Camera_Node,
	node: ^Node)
```

#### `tick_camera_node`

```c
tick_camera_node :: proc(
	node: ^Node)
```

#### `make_model_node`

```c
make_model_node :: proc(
	node_config: Node_Config,
	model: ^gx.Model,
	allocator: rt.Allocator) -> (model_node: ^Model_Node)
```

#### `render_model_node`

```c
render_model_node :: proc(
	graphics_context: ^gx.Graphics_Context,
	scene: ^Scene,
	camera_node: ^Camera_Node,
	node: ^Node)
```
