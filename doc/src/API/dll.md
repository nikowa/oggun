# DLL

```c
import dll "willow/dll"
```

A helper library for managing DLLs and hot-reloading.

## Example

Create a struct that derives from `dll.DLL`, and has a field for each proc exported by your DLL package:

```c
My_DLL :: struct {
	using base: dll.DLL,
	my_dll_proc: proc() }
```

Create an object of your derived DLL type by `dll.make_dll` and give it the relative path to the source of your DLL:

```c
example_dll: Example_DLL
example_dll, err = dll.make_dll(Example_DLL, "example-dll/example-dll.odin")
```

To check if the DLL source has been modified and reload the DLL if necessary, call `dll.watch_dll` with a pointer to the instance of your derived DLL type:

```c
dll.watch_dll(&example_dll)
```

While the DLL is being reloaded, the proc pointers in it will become temporarily invalid. Thus make sure this isn't called while any of those procs is in use.

### Types

#### `DLL`

```c
DLL :: struct {
	lib: dl.Library,
	source_relpath: string,
	dll_relpath: string,
	modification_time: tm.Time }
```

### Procedures

#### `make_dll`

```c
make_dll :: proc(
	$T: typeid,
	source_relpath: string) -> (dll_object: T, err: os.Error)
```

<details><summary>Description</summary>
Create an instance of a type derived from dll.DLL, while compiling and loading the requested package as a DLL.
</details>

#### `compile_dll`

```c
compile_dll :: proc(
	source_relpath: string,
	dll_relpath: string)
```

<details><summary>Description</summary>
Issue an Odin build command to compile a DLL.
</details>

#### `dll_was_modified`

```c
dll_was_modified :: proc(
	dll_object: ^$T) -> (was_modified: bool)
```

<details><summary>Description</summary>
Check if the source of a given DLL has been modified.
</details>

#### `reload_dll`

```c
reload_dll :: proc(
	dll_object: ^$T) -> (ok: bool)
```

<details><summary>Description</summary>
Reload a given DLL.
</details>

#### `watch_dll`

```c
watch_dll :: proc(
	dll_object: ^$T) -> (ok: bool)
```

<details><summary>Description</summary>
Check if the source of a given DLL has been modified, and if it has, reload it and return true.
</details>
