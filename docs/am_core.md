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

### `DEFAULT_ASSET_MANAGER_CONFIG`

```odin
DEFAULT_ASSET_MANAGER_CONFIG: Asset_Manager_Config : {
	relpath = "Data.bin",
	source_directory_relpath = "../data",
	autosave_interval = 30 * time.Minute,
	autosave_cap = 10,
	watch = true }
```
