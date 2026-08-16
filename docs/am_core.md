# am/core

### `URL`

```odin
URL :: distinct string
```

Every asset has a distinct URL, which it's identified by.

### `Asset_Manager_Config`

```odin
Asset_Manager_Config :: struct {
	relpath: string,
	source_directory_relpath: string,
	autosave_interval: time.Duration,
	autosave_cap: u32,
	watch: bool }
```

The configuration parameters of `Asset_Manager`. `relpath` is the path where the database binary will be stored. `source_directory_relpath` is the path to the root directory for asset source files. `watch` enables hot-reloading.

### `Asset_Manager`

```odin
Asset_Manager :: struct {
	using config: Asset_Manager_Config,
	... }
```

### `Asset_Command`

```odin
Asset_Command :: enum {
	Validate,
	Query_Location,
	Serialize,
	Deserialize,
	Read,
	Write,
	Deserialize,
	Serialize,
	Upload,
	Download }
```

See [asset flowchart](../architecture/#asset-flowchart).

### `Asset_Locations`

```odin
Asset_Locations :: bit_set[Asset_Location]
```

### `Asset_Location`

```odin
Asset_Location :: enum {
	Source_Directory,
	Database_File,
	Database,
	Main_Memory,
	GPU_Memory }
```

### `Asset_Command_Proc`

```odin
Asset_Command_Proc :: #type proc(
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

The type of the generic asset command procedure.

### `Asset_Config`

```odin
Asset_Config :: struct {
	url: URL,
	derived_type: typeid }
```

The configuration parameters of `Asset`. `url` is the asset's identifier.

### `Asset`

```odin
Asset :: struct {
	using asset_config: Asset_Config,
	... }
```

Abstract class from which asset classes are derived.

### `Asset_Kind`

```odin
Asset_Kind :: struct {
	command: Asset_Command_Proc }
```

### `DEFAULT_ASSET_MANAGER_CONFIG`

```odin
DEFAULT_ASSET_MANAGER_CONFIG: Asset_Manager_Config : {
	relpath = "Data.bin",
	source_directory_relpath = "../data",
	autosave_interval = 30 * time.Minute,
	autosave_cap = 10,
	watch = true }
```

### `DEFAULT_URL`

```odin
DEFAULT_URL :: "unknown:unnamed"
```

### `DEFAULT_ASSET_CONFIG`

```odin
DEFAULT_ASSET_CONFIG: Asset_Config : {
	url = DEFAULT_URL,
	derived_type = string }
```

<pre>























</pre>
