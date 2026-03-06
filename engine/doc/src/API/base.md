# Base

This is the base layer.

### `Lock`

```c
Lock :: struct { ... }
```

An ordered mutex type. Acquisition succeeds only if the last mutex acquired by the same thread was of a lower rank.

#### `lock_acquire`

```c
lock_acquire :: #force_inline proc "contextless" (lock: ^Lock)
```

#### `lock_release`

```c
lock_release :: #force_inline proc "contextless" (lock: ^Lock)
```

#### `lock_guard`

```c
lock_guard :: proc "contextless" (lock: ^Lock) -> bool
```

