# Base

This is the base layer, responsible mainly for initialization, synchronization, and configuration.

### Types

#### `Thread_Data`

```c
Thread_Data :: struct {
	index: u32,
	... }
```

#### `Lock`

```c
Lock :: ...
```

The default mutex type.

### Procedures

#### `make_thread_data`

```c
make_thread_data :: proc(
	entry_point: Entry_Point,
	index: u32) -> (thread_data: ^Thread_Data)
```

#### `get_thread_data`

```c
get_thread_data :: proc() -> (thread_data: ^Thread_Data)
```

#### `lock_acquire_unmanaged`

```c
lock_acquire_unmanaged :: proc(
	lock: ^Lock)
```

#### `lock_release_unmanaged`

```c
lock_release_unmanaged :: proc(
	lock: ^Lock)
```

#### `lock_guard_unmanaged`

```c
lock_guard_unmanaged :: proc(
	lock: ^Lock)
```

#### `lock_acquire`

If there is a free lock register in the current thread context, acquire the given lock and add it to a register. Return `false` if there is no free lock register.

```c
lock_acquire :: proc(
	lock: ^Lock) -> bool
```

#### `lock_release`

If the given lock is in a lock register in the current thread context, release it and remove it from the register. Return `false` if the given lock wasn't in a lock register.

```c
lock_release :: proc(
	lock: ^Lock) -> bool
```

#### `lock_acquire_release`

Call `lock_acquire` on the given lock. At the end of scope, call `lock_release` on the same lock.

```c
@(deferred_in=lock_release)
lock_acquire_release :: proc(
	lock: ^Lock) -> bool
```

#### `lock_release_acquire`

Call `lock_release` on the given lock. At the end of scope, call `lock_acquire` on the same lock.

```c
@(deferred_in=lock_acquire)
lock_release_acquire :: proc(
	lock: ^Lock) -> bool
```

#### `lock_push`

If the given lock is in a lock register in the current thread context, release it, remove it from the register, and push it to the lock stack. If the lock isn't in a lock register, do nothing and return `false`.

```c
lock_push :: proc(
	lock: ^Lock) -> bool
```

#### `lock_pop`

```c
lock_pop :: proc() -> bool
```

If the lock stack in the current thread context is not empty and there is an empty register in the current thread context, pop the top lock from it, acquire it, and

#### `lock_push_pop`

Call `lock_push` on the given lock. At the end of scope, call `lock_pop`.

```c
@(deferred_in=lock_pop)
lock_push_pop :: proc(
	lock: ^Lock) -> bool
```




