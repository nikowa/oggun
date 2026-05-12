# Base

This is the base layer, responsible mainly for initialization, synchronization, and configuration.

### Constants

#### `WILLOW_VERSION`

```
WILLOW_VERSION: [3]u16 : { 0, 0, 1 }
```

### Types

#### `Tick_Manager`

```c
Tick_Manager :: struct {
	using tick_manager_config: Tick_Manager_Config,
	stopwatch:                 time.Stopwatch,
	tick_period_nsec:          i64,
	tick_period_sec:           f32,
	accumulation_to_now:       i64,
	accumulation_to_last_tick: i64,
	delta_time:                f32,
	frame_rate:                f32,
	flag:                      bool }
```

<details><summary>Description</summary>
Tick manager. Used for tracking frame-rate, calculating delta time, and limiting frame-rate. You can use this if you want something to happen at roughly equal time intervals, and to keep track of those intervals.
</details>

#### `Tick_Manager_Config`

```c
Tick_Manager_Config :: struct {
	tickrate_setting: Tickrate_Setting }
```

#### `Tickrate_Setting`

```c
Tickrate_Setting :: enum {
	LIMITED_30_FPS = 0,
	LIMITED_60_FPS,
	LIMITED_120_FPS,
	LIMITED_144_FPS,
	LIMITED_240_FPS,
	LIMITED_540_FPS,
	UNLIMITED }
```

#### `Settings_Manager`

```c
Settings_Manager :: struct {
	settings_path: string,
	_map: map[string]map[string]string }
```

<details><summary>Description</summary>
A helper class for game settings. Can compile an INI file from an arbitrary number of structs, and vice-versa.
</details>

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

#### `init_tick_manager`

```c
init_tick_manager :: proc(
	tick_man: ^Tick_Manager,
	config: Tick_Manager_Config)
```

#### `tick_manager_tick`

```c
tick_manager_tick :: proc(
	tick_man: ^Tick_Manager) -> bool
```

<details><summary>Description</summary>
Returns true if enough time has passed since the previous frame that a new frame should be processed. Must call <code>tick_manager_reset</code> after the frame has been processed.
</details>

#### `tick_manager_reset`

```c
tick_manager_reset :: proc(
	tick_man: ^Tick_Manager)
```

#### `zero_stopwatch`

```c
zero_stopwatch :: proc(
	timer: ^time.Stopwatch)
```

<details><summary>Description</summary>
Stopwatch helper function. Zeroes and starts the stopwatch.
</details>

#### `read_stopwatch`

```c
read_stopwatch :: proc(
	timer: ^time.Stopwatch) -> f32
```

<details><summary>Description</summary>
Stopwatch helper function. Reads the stopwatch, in seconds.
</details>

#### `init_settings_manager`

```c
init_settings_manager :: proc(
	settings: ^Settings_Manager,
	application_name: string)
```

<details><summary>Description</summary>
Initialize a <code>Settings_Manager</code>. <code>application_name</code> is the name of a folder in <code>~/AppData/Local</code> where the setting will be saved.
</details>

#### `settings_manager_write`

```c
settings_manager_write :: proc(
	settings: ^Settings_Manager,
	value: ^$Type) where intrinsics.type_is_struct(Type)
```

<details><summary>Description</summary>
Write the contents of an arbitrary struct to the settings. The settings will be added under a new section named after type <code>Type</code>.
</details>

#### `settings_manager_read`

```c
settings_manager_read :: proc(
	settings: ^Settings_Manager,
	value: ^$Type) where intrinsics.type_is_struct(Type)
```

#### `settings_manager_export`

```c
settings_manager_export :: proc(
	settings: ^Settings_Manager)
```

#### `settings_manager_import`

```c
settings_manager_import :: proc(
	settings: ^Settings_Manager)
```

#### `start`

```c
start :: proc(
	entry_point: Entry_Point,
	n_workers_override: Maybe(u32) = nil)
```

<details><summary>Description</summary>
Create and start a number of threads with the same entry procedure. The number of threads will be equal to the number of logical cores minus 3, however you can override this by setting <code>n_workers_override</code>.
</details>

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

<pre>
























</pre>
