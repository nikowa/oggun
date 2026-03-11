# Base

This is the base layer, responsible mainly for initialization, synchronization, and configuration.

### `Thread_Data`

```c
Thread_Data :: struct {
	magic_number: u32,
	entry_point: Entry_Point,
	index: u32,
	locks: ts.Two_Stack(^Arena_Lock) }
```

#### `make_thread_data`

```c
make_thread_data :: proc(entry_point: Entry_Point, index: u32) -> (thread_data: ^Thread_Data)
```

#### `get_thread_data`

```c
get_thread_data :: proc() -> (thread_data: ^Thread_Data)
```

### `Lock`

```c
Lock :: ...
```

The default mutex type.

#### `lock_acquire`

```c
lock_acquire :: ...
```

#### `lock_release`

```c
lock_release :: ...
```

#### `lock_guard`

```c
lock_guard :: ...
```

### `Arena_Lock`

```c
Arena_Lock :: struct {
	lock: Lock,
	size: u32 }
```

<!---An ordered mutex type. Acquisition succeeds only if the last mutex acquired by the same thread was of a lower rank.--->

#### `arena_lock_acquire_unsafe`

```c
arena_lock_acquire_unsafe :: proc(arena_lock: ^Arena_Lock)
```

#### `arena_lock_release_unsafe`

```c
arena_lock_release_unsafe :: proc(arena_lock: ^Arena_Lock)
```

#### `arena_lock_guard_unsafe`

```c
arena_lock_guard_unsafe :: proc(arena_lock: ^Arena_Lock) -> bool
```

#### `arena_locks_ordered`

```c
arena_locks_ordered :: proc(arena_lock_a, arena_lock_b: ^Arena_Lock) -> bool
```

#### `arena_lock_push`

```c
arena_lock_push :: proc(arena_lock: ^Arena_Lock) -> (ok: bool)
```

