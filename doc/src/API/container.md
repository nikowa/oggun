# Container

Various containers used throughout Willow.

### Types

#### `Two_Stack`


```c
Two_Stack :: struct($T: typeid) {
	buffer: [2]T,
	len: u8 }
```

### Procedures

#### `init`

```c
init :: proc(two_stack: ^Two_Stack($T))
```

#### `len`

```c
len :: proc(two_stack: ^Two_Stack($T)) -> int
```

#### `push`

```c
push :: push_top
```

#### `push_top`

```c
push_top :: proc(two_stack: ^Two_Stack($T), elem: T) -> bool
```

#### `push_bottom`

```c
push_bottom :: proc(two_stack: ^Two_Stack($T), elem: T) -> bool
```

#### `pop`

```c
pop :: pop_top
```

#### `pop_top`

```c
pop_top :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `pop_bottom`

```c
pop_bottom :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `peek`

```c
peek :: peek_top
```

#### `peek_top`

```c
peek_top :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `peek_bottom`

```c
peek_bottom :: proc(two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool)
```

#### `contains`

```c
contains :: proc(two_stack: ^Two_Stack($T), elem: T) -> (ok: bool)
```
