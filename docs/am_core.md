# am/core

## **Overview**

```mermaid
---
config:
	flowchart:
		nodeSpacing: 5
		rankSpacing: 80
		subGraphTitleMargin: { "top": 0, "bottom": 15 }
		padding: 8
---
flowchart LR
	VRAM -- download --> RAM
	RAM -- upload --> VRAM
	RAM -- serialize --> Database
	Database -- deserialize --> RAM
	Source -- import --> RAM
	RAM -- export --> Source
	Database -- write --> Storage
	Storage -- read --> Database
	VRAM@{ shape: notch-rect }
	RAM@{ shape: das }
	Database@{ shape: das }
	Source@{ shape: cyl }
	Storage@{ shape: cyl }
```

**Asset** is an abstract class for things that have multiple representations in your game project (eg. images, sounds, models, levels, etc). The main purpose is to allow heterogenous assets to be processed in bulk by generic procedures. The hot-reloading system makes use of this feature.

- **Make** — Allocate the `dest` representation.
- **Delete** — Deallocate the `dest` representation.
- **Initialize** — Initialize the `dest` representation.
- **Exists** — Check if the `dest` representation is allocated.
- **Translate** — Convert the `src` representation to the `dest` representation.
- **Outdated** — Check if the `dest` representation is older than the `src` representation.

!!! tip "Feature Suggestion"
	Add a **Pull** op which takes one argument, `dest`, and searches for the nearest upstream representation, and translates from that representation to `dest`.

---

## **Types**

### **URL**

```odin
URL :: distinct string
```

Every asset has a distinct URL, which it's identified by.

### **Asset_Manager_Config**

```odin
Asset_Manager_Config :: struct {
	relpath: string,
	source_directory_relpath: string,
	autosave_interval: time.Duration,
	autosave_cap: u32,
	watch: bool }
```

The configuration parameters of `Asset_Manager`. `relpath` is the path where the database binary will be stored. `source_directory_relpath` is the path to the root directory for asset source files. `watch` enables hot-reloading.

### **Asset_Manager**

```odin
Asset_Manager :: struct {
	using config: Asset_Manager_Config,
	... }
```

### **Asset_Op**

```odin
Asset_Op :: enum {
	Make,
	Delete,
	Initialize,
	Exists,
	Translate,
	Outdated }
```

See [asset flowchart](../architecture/#asset-flowchart).

### **Asset_Locations**

```odin
Asset_Locations :: bit_set[Asset_Location]
```

### **Asset_Location**

```odin
Asset_Location :: enum {
	Source,
	Storage,
	Database,
	RAM,
	VRAM }
```

### **Asset_Op_Proc**

```odin
Asset_Op_Proc :: #type proc(
	asset: ^Asset,
	op: Asset_Op,
	dest: Asset_Location = .None,
	src: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> (ok: bool)
```

The type of the generic asset command procedure.

### **Asset_Config**

```odin
Asset_Config :: struct {
	url: URL,
	derived_type: typeid }
```

The configuration parameters of `Asset`. `url` is the asset's identifier.

### **Asset**

```odin
Asset :: struct {
	using asset_config: Asset_Config,
	... }
```

Abstract class from which asset classes are derived.

### **Asset_Kind**

```odin
Asset_Kind :: struct {
	command: Asset_Op_Proc }
```

---

## **Constants**

### **DEFAULT_ASSET_MANAGER_CONFIG**

```odin
DEFAULT_ASSET_MANAGER_CONFIG: Asset_Manager_Config : {
	relpath = "Data.bin",
	source_directory_relpath = "../data",
	autosave_interval = 30 * time.Minute,
	autosave_cap = 10,
	watch = true }
```

### **DEFAULT_URL**

```odin
DEFAULT_URL :: "unknown:unnamed"
```

### **DEFAULT_ASSET_CONFIG**

```odin
DEFAULT_ASSET_CONFIG: Asset_Config : {
	url = DEFAULT_URL,
	derived_type = string }
```

---

## **Procedures**

### **am_op**

```odin
am_op :: proc(
	Asset_Type: typeid,
	asset: ^Asset,
	op: Asset_Op,
	dest: Asset_Location = .None,
	src: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> (ok: bool)
```

Invokes the asset op proc of the given asset type, with the given arguments.

!!! warning "Note"
	Perhaps reduce the first 2 args to a pointer to the derived type, a la `asset_make` and the like.

### `asset_make`

```odin
asset_make :: proc(
	this: ^Derived,
	dest: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Make` op on the given asset.

### `asset_delete`

```odin
asset_delete :: proc(
	this: ^Derived,
	dest: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Delete` op on the given asset.

### `asset_initialize`

```odin
asset_initialize :: proc(
	this: ^$Derived,
	dest: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Initialize` op on the given asset.

### `asset_exists`

```odin
asset_exists :: proc(
	this: ^$Derived,
	dest: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Exists` op on the given asset.

### `asset_translate`

```odin
asset_translate :: proc(
	this: ^$Derived,
	dest: Asset_Location = .None,
	src: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Translate` op on the given asset.

### `asset_outdated`

```odin
asset_outdated :: proc(
	this: ^$Derived,
	dest: Asset_Location = .None,
	arg: rawptr = nil,
	location := #caller_location) -> bool
```

Executes the `.Outdated` op on the given asset.

<div style="height: 100vh;"></div>
