# Input

```c
package input_sys
```

### Overview

The `willow/input_sys` module is for storing and processing inputs. There are two kinds of inputs: _scalar_ inputs (ie, mouse position, mouse position delta, mouse scroll delta, etc.), and _boolean_ inputs (ie, keyboard buttons, mouse buttons, etc.). The former are stored transparently, while the latter are stored opaquely.

The input system needs inputs to process. You do this by triggering events. You have three options:
- Let the window collect and trigger events. To do this, simply pass a pointer to an initialized `Input_Manager` to `graphics_sys.init`.
- Use the raw input API to collect and trigger events. To do this, simply call `input_sys.raw_input_tick` before `input_sys.process`.
- Collect and trigger events manually. To trigger an event, call `input_sys.trigger`.

After the inputs system has collected all the inputs, they need to be processed. You do this by calling `input_sys.process`.

Once the inputs have been processed, you can query information about them `input_sys.query`.

---

### Examples

To check if WASD are pressed down:

```c
w, a, s, d := input_down(.W), input_down(.A), input_down(.S), input_down(.D)
```

To check if the mouse buttons were pressed during the current tick:

```c
lmb, rmb := input_pressed(.Mouse_Left), input_pressed(.Mouse_Right)
```

To process window input:

```c
graphics_sys.tick(&gx_mngr)
input_sys.process(&in_mngr)
```

To process raw input:

```c
input_sys.raw_input_tick(&in_mngr)
input_sys.process(&in_mngr)
```

```c
input_sys.query(.W, .Up)
```

---

### Types

#### `Input_Manager`

```c
Input_Manager :: struct {
	mouse_position: [2]f32,
	mouse_delta: [2]f32,
	scroll_delta: f32,
	focused: bool,
	using _private: Input_Manager_Private }
```

#### `Input`

```c
Input :: enum uint {
	Space = 32,
	Apostrophe = 39,
	Comma = 44,
	Minus = 45,
	Period = 46,
	Slash = 47,
	Num_0 = 48,
	Num_1 = 49,
	Num_2 = 50,
	Num_3 = 51,
	Num_4 = 52,
	Num_5 = 53,
	Num_6 = 54,
	Num_7 = 55,
	Num_8 = 56,
	Num_9 = 57,
	Semicolon = 59,
	Equal = 61,
	A = 65,
	B = 66,
	C = 67,
	D = 68,
	E = 69,
	F = 70,
	G = 71,
	H = 72,
	I = 73,
	J = 74,
	K = 75,
	L = 76,
	M = 77,
	N = 78,
	O = 79,
	P = 80,
	Q = 81,
	R = 82,
	S = 83,
	T = 84,
	U = 85,
	V = 86,
	W = 87,
	X = 88,
	Y = 89,
	Z = 90,
	Left_Bracket = 91,
	Backslash = 92,
	Right_Bracket = 93,
	Backtick = 96,
	Escape = 256,
	Enter = 257,
	Tab = 258,
	Backspace = 259,
	Insert = 260,
	Delete = 261,
	Right = 262,
	Left = 263,
	Down = 264,
	Up = 265,
	Page_Up = 266,
	Page_Down = 267,
	Home = 268,
	End = 269,
	Caps_Lock = 280,
	Scroll_Lock = 281,
	Num_Lock = 282,
	Print_Screen = 283,
	Pause = 284,
	F1 = 290,
	F2 = 291,
	F3 = 292,
	F4 = 293,
	F5 = 294,
	F6 = 295,
	F7 = 296,
	F8 = 297,
	F9 = 298,
	F10 = 299,
	F11 = 300,
	F12 = 301,
	F13 = 302,
	F14 = 303,
	F15 = 304,
	F16 = 305,
	F17 = 306,
	F18 = 307,
	F19 = 308,
	F20 = 309,
	F21 = 310,
	F22 = 311,
	F23 = 312,
	F24 = 313,
	F25 = 314,
	Numpad_0 = 320,
	Numpad_1 = 321,
	Numpad_2 = 322,
	Numpad_3 = 323,
	Numpad_4 = 324,
	Numpad_5 = 325,
	Numpad_6 = 326,
	Numpad_7 = 327,
	Numpad_8 = 328,
	Numpad_9 = 329,
	Numpad_Decimal = 330,
	Numpad_Divide = 331,
	Numpad_Multiply = 332,
	Numpad_Subtract = 333,
	Numpad_Add = 334,
	Numpad_Enter = 335,
	Numpad_Equal = 336,
	Left_Shift = 340,
	Left_Control = 341,
	Left_Alt = 342,
	Left_Super = 343,
	Mouse_Left = INDEX_MOUSE_LEFT,
	Mouse_Right = INDEX_MOUSE_RIGHT }
```

#### `Input_State`

```c
Input_State :: enum {
	Up,
	Down }
```

#### `Action`

```c
Action :: enum {
	Press,
	Release }
```

#### `Query_Variant`

```c
Query_Variant :: enum {
	Up,
	Down,
	Pressed,
	Released }
```

### Procedures

#### `process`

```c
process :: proc(
	im: ^Input_Manager)
```

#### `trigger`

```c
trigger :: proc(
	im: ^Input_Manager,
	input: Input,
	action: Action)
```

#### `query`

```c
query :: proc(
	im: ^Input_Manager,
	input: Input,
	$variant: Query_Variant) -> bool
```

#### `init`

```c
init :: proc(
	im: ^Input_Manager,
	window: glfw.WindowHandle)
```
