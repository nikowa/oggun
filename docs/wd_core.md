# wd/core

### `Window_Backend`

```odin
Window_Backend :: enum {
	Win32,
	GLFW }
```

### `Window_Config`

```odin
Window_Config :: struct #all_or_none {
	position: [2]f32,
	size: [2]f32,
	fullscreen: bool,
	cursor: Cursor }
```

### `Cursor`

```odin
Cursor :: enum {
	Arrow,
	Hand,
	Move,
	Disabled }
```

### `Window_Manager`

```odin
when WINDOW_BACKEND == .GLFW do Window_Manager :: struct {
	handle: rawptr,
	using window_config: Window_Config,
	cursors: [len(Cursor)]glfw.CursorHandle }
else do Window_Manager :: struct {
	handle: rawptr,
	using window_config: Window_Config,
	cursors: [len(Cursor)]win32.HCURSOR,
	device_context: win32.HDC }
```

### `WINDOW_BACKEND`

```odin
WINDOW_BACKEND: Window_Backend : #config(WINDOW_BACKEND, Window_Backend.GLFW)
```

### `DEV_WINDOW_CONFIG`

```odin
DEV_WINDOW_CONFIG: Window_Config : {
	position = [2]f32{ -480, -270 },
	size = { 960, 540 },
	fullscreen = false,
	cursor = .Arrow }
```

### `DEFAULT_WINDOW_CONFIG`

```odin
DEFAULT_WINDOW_CONFIG: Window_Config : {
	position = [2]f32{ 0, 0 },
	size = { 1664, 936 },
	fullscreen = false,
	cursor = .Arrow }
```

### `wd_init`

```odin
wd_init :: proc(window_config: Window_Config)
```

### `wd_customize`

```odin
wd_customize :: proc(header_color, border_color: Color)
```

### `wd_update_size`

```odin
wd_update_size :: proc()
```

### `wd_get_display_size`

```odin
wd_get_display_size :: proc() -> [2]f32
```

### `wd_set_pos`

```odin
wd_set_pos :: proc(position: [2]f32)
```

### `wd_tick`

```odin
wd_tick :: proc()
```

### `wd_set_cursor`

```odin
wd_set_cursor :: proc(cursor: Cursor)
```

### `wd_set_cursor_immediate`

```odin
wd_set_cursor_immediate :: proc(cursor: Cursor)
```

<pre>
























</pre>
