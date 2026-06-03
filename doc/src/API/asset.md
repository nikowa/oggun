# Asset

### Overview

![dataflow-image](../dataflow.png)

Database is an abstraction layer between the in-memory and on-disk representations of assets. It's purpose is to make it so you don't have to think about where the assets are coming from and to automate updating and reloading them.

Assets are identified by a string URL. The URL has the form `<kind>:<name>`. The intended way of managing assets is by registering their kinds at initialization time, then loading them and then saving them at deinitialization time; The database will automatically do the importing, reading, and writing for you. However, if you want, you can also import, read, or write manually.

By setting the `watch` field on `Asset_Manager_Config`, you can enable the asset manager to watch for changes and automatically read, import, or load assets. This can allow you to edit assets while the game is running and see changes in real time.

### Asset representations

An asset can have up to five representations. None of these is mandatory.

 - `Source_Directory` --- The source file from which the asset is imported.
 - `Database_File` --- The binary file where the database stores its contents.
 - `Database` --- The in-memory contents of the database.
 - `Main_Memory` --- The primary in-memory representation of the asset.
 - `GPU_Memory` --- The GPU representation of the asset.

### Asset commands

 - `Validate` --- Check if the asset is initialized with valid contents.
 - `Query_Location` --- Checks which locations Updates the `location` field with the current locationns of the asset.
 - `Import` --- Produces a database representation from a source representation.
 - `Export` --- Produces a source representation from a database representation.
 - `Load` --- Produces a default representation from a database representation.
 - `Save` --- Produces a database representation from a default representation.
 - `Upload` --- Produces a GPU representation from a default representation.
 - `Download` --- Produces a representation from a GPU representation.

### Making custom asset types

To make a custom asset type, you need to do these four things:

1. Define a struct type that derives from `Asset`.

```c
My_Asset :: ---
	... }
```

2. Call `init_assset` on the `Asset` field, whenever your custom asset type is initialized.

```c
init_my_asset :: proc(
		as_mngr: ^Asset_Manager,
		my_asset: ^My_Asset,
		config: Asset_Config) {
	init_asset(as_mngr, &string_asset.asset, config)
	... }
```

3. Define an `Asset_Command_Proc` procedure for your custom asset type.

```c
my_asset_command :: proc(
		as_mngr: ^Asset_Manager,
		asset: ^Asset,
		command: Asset_Command,
		watch: bool = false) -> (ok: bool) {
	my_asset := asset_object(asset, My_Asset, "asset")
	switch command {
	case .Validate: ...
	case .Query_Location: ...
	case .Import: ...
	case .Export: ...
	case .Load: ...
	case .Save: ...
	case .Upload: ...
	case .Download: ...
	return false }
```

4. Register your custom asset type.

```c
register_asset_kind(as_mngr, My_Asset, { command = my_asset_command })
```

### Database Binary Format

#### `Database`

| Name                | Type                      |
| :------------------ | :------------------------ |
| `header`            | `_Database_Binary_Header` |
| `entries`           | `[^]u8`                   |

#### `Entry`

| Name                | Type        |
| :------------------ | :---------- |
| `url_len`           | `u8`        |
| `url`               | `[^]u8`     |
| `modification_time` | `time.Time` |
| `data_len`          | `u32`       |
| `data`              | `[^]u8`     |

### Constants

#### `DEFAULT_AUTOSAVE_INTERVAL`

```c
DEFAULT_AUTOSAVE_INTERVAL :: 30 * tm.Minute
```

#### `DEFAULT_AUTOSAVE_CAP`

```c
DEFAULT_AUTOSAVE_CAP :: 10
```

### Types

#### `Asset_Manager_Config`

```c
Asset_Manager_Config :: Database_Config
```

#### `Asset_Manager`

```c
Asset_Manager :: struct {
	using database: Database,
	assets: [dynamic]^Asset,
	asset_kinds: map[typeid]Asset_Kind }
```

<details><summary>Description</summary>
Asset manager.
</details>

#### `Asset_Command`

```c
Asset_Command :: enum {
	Validate,
	Query_Location,
	Import,
	Export,
	Load,
	Save,
	Upload,
	Download }
```

#### `Asset_Location`

```c
Asset_Location :: bit_set[Asset_Location_Field]
```

#### `Asset_Location_Field`

```c
Asset_Location_Field :: enum {
	Source_Directory,
	Database_File,
	Database,
	Main_Memory,
	GPU_Memory }
```

#### `Asset_Command_Proc`

```c
Asset_Command_Proc :: #type proc(
	manager: ^Asset_Manager,
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

#### `Asset_Config`

```c
Asset_Config :: struct {
	url: URL,
	derived_type: typeid }
```

#### `Asset`

```c
Asset :: struct {
	using asset_config: Asset_Config,
	location: Asset_Location }
```

#### `Asset_Kind`

```c
Asset_Kind :: struct {
	command: Asset_Command_Proc }
```

#### `String_Asset`

```c
String_Asset :: struct {
	using asset: Asset,
	str: string }
```

#### `URL`

```c
URL :: distinct string
```

#### `Database_Config`

```c
Database_Config :: struct {
	relpath: string,
	source_directory_relpath: string,
	autosave_interval: tm.Duration,
	autosave_cap: u32 }
```

#### `Database`

```c
Database :: struct {
	using config: Database_Config,
	allocator: runtime.Allocator,
	last_autosave_time: time.Time,
	modification_time: time.Time,
	entries: list.List,
	entries_map: map[URL]^Entry,
	spec_modified: bool
	_arena: mem.Arena }
```

<details><summary>Description</summary>
<code>allocator</code> — the allocator which allocates the entries<br>
<code>modification_time</code> — the last time an entry was added or removed, not counting the adding of entries on database reading
</details>

#### `Entry_Config`

```c
Entry_Config :: struct {
	url: URL,
	modification_time: tm.Time,
	compressed: b8,
	data: []u8 }
```

#### `Entry`

```c
Entry :: struct {
	using config: Entry_Config,
	hash: u32 }
```

#### `Watcher`

```c
Watcher :: struct {
	data: rawptr,
	outdated_proc: Outdated_Proc,
	update_proc: Update_Proc }
```

#### `Outdated_Proc`

```c
Outdated_Proc :: #type proc(data: rawptr) -> bool
```

#### `Update_Proc`

```c
Update_Proc :: #type proc(data: rawptr)
```

### Procedures

#### `asset_command`

```c
asset_command :: proc(
	manager: ^Asset_Manager,
	Asset_Type: typeid,
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

<details><summary>Description</summary>
Execute an asset command. <code>Asset_Type</code> must be a type that derives from <code>Asset</code>, and <code>asset</code> must be a pointer to a field in an object of that type. If <code>watch</code> is true, the command will be exucted only if the source is more recent than the target.
</details>

#### `asset_commands`

```c
asset_commands :: proc(
	manager: ^Asset_Manager,
	Asset_Type: typeid,
	asset: ^Asset,
	commands: []Asset_Command,
	watch: bool = false) -> (ok: bool)
```

#### `init_asset`

```c
@(deferred_in=_init_asset_end)
init_asset :: proc(
	manager: ^Asset_Manager,
	Asset_Type: typeid,
	asset: ^Asset,
	config: Asset_Config)
```

<details><summary>Description</summary>
Initialize the asset <code>asset</code> with the config <code>config</code> and add it to the internal collection of assets in <code>as_mngr</code>. <code>_init_asset_end</code> executes the <code>.Validate</code> and <code>.Query_Location</code> asset commands.
</details>

#### `asset_object`

```c
asset_object :: proc(
	asset: ^Asset,
	$T: typeid,
	$field_name: string) -> (^T)
```

<details><summary>Description</summary>
If <code>asset</code> is a pointer to a field named <code>field_name</code> in a struct of type <code>T</code>, produce a pointer to the object whose field this is.
</details>

#### `make_asset_manager`

```c
make_asset_manager :: proc(
	config: Asset_Manager_Config,
	allocator: runtime.Allocator) -> (asset_manager: Asset_Manager)
```

<details><summary>Description</summary>
The <code>Asset_Manager</code> constructor.
</details>

#### `register_asset_kind`

```c
register_asset_kind :: proc(
	manager: ^Asset_Manager,
	$Type: typeid,
	kind: Asset_Kind)
```

<details><summary>Description</summary>
Register a new asset kind. An asset kind must be registered for any asset type before asset commands can be executed on instances of that type.
</details>

#### `watch_assets`

```c
watch_assets :: proc(
	manager: ^Asset_Manager)
```

<details><summary>Description</summary>
Check all registered assets for updates. If the source is more recent than the database entry, the asset will be imported; If the database entry is more recent than the asset object, the asset will be loaded. Internally, it works by executing the <code>.Import</code> command and then the <code>.Load</code> command, with <code>watch=true</code>.
</details>

#### `asset_manager_autosave`

```c
asset_manager_autosave :: proc(
	asset_manager: ^Asset_Manager)
```

#### `init_string_asset`

```c
init_string_asset :: proc(
	asset_manager: ^Asset_Manager,
	string_asset: ^String_Asset,
	config: Asset_Config)
```

#### `string_asset_command`

```c
string_asset_command :: proc(
	as_mngr: ^Asset_Manager,
	asset: ^Asset,
	command: Asset_Command,
	watch: bool = false) -> (ok: bool)
```

#### `register_builtin_asset_kinds`

```c
register_builtin_asset_kinds :: proc(
	as_mngr: ^Asset_Manager)
```

#### `make_database`

Database constructor.

```c
make_database :: proc(
	config: Database_Config,
	allocator: rt.Allocator) -> (database: Database)
```

#### `delete_database`

Database destructor.

```c
delete_database :: proc(
	database: Database,
	allocator: runtime.Allocator)
```

#### `make_entry`

Entry constructor.

```c
make_entry :: proc(
	url: URL,
	data: []u8,
	modification_time: time.Time = { },
	compressed: b8 = false) -> (entry: Entry)
```

#### `delete_entry`

Entry destructor.

```c
delete_entry :: proc(
	entry: Entry,
	allocator: runtime.Allocator)
```

#### `entry_equiv`

Check if two entries are equivalent (equivalent URL, equivalent data, equivalent compressedness state).

```c
entry_equiv :: proc(
	entry_a: ^Entry,
	entry_b: ^Entry)
```

#### `entry_from_url`

Retreive entry from database by URL.

```c
entry_from_url :: proc(
	database: ^Database,
	url: URL) -> (entry: ^Entry, ok: bool)
```

#### `get_entry`

```c
get_entry :: proc(
	database: ^Database,
	url: URL) -> (entry: ^Entry, ok: bool)
```

#### `get_or_make_entry`

```c
get_or_make_entry :: proc(
	database: ^Database,
	url: URL) -> (entry: ^Entry, existed: bool)
```

#### `contains_entry`

Check if database contains entry with given URL.

```c
contains_entry :: proc(
	database: ^Database,
	url: URL) -> bool
```

#### `log_database`

```c
log_database :: proc(
	database: ^Database)
```

#### `entry_integrity`

```c
entry_integrity :: proc(
	entry: ^Entry) -> (ok: bool)
```

#### `add_entry`

Add entry to database.

```c
add_entry :: proc(
	database: ^Database,
	entry_config: Entry_Config,
	modified: bool) -> (entry_ptr: ^Entry, err: os.Error)
```

#### `add_or_update_entry`

Add entry to database; If exists, update it.

```c
add_or_update_entry :: proc(
	database: ^Database,
	entry_config: Entry_Config,
	modified: bool) -> (entry_ptr: ^Entry, err: os.Error)
```

#### `remove_entry`

Remove entry from database.

```c
remove_entry :: proc(
	database: ^Database,
	entry: ^Entry)
```

#### `clone_entry`

Clone an entry.

```c
clone_entry :: proc(
	entry: ^Entry,
	allocator: rt.Allocator) -> (entry_clone: Entry)
```

#### `clone`

Clone a database.

```c
clone :: proc(
	database: ^Database,
	allocator: rt.Allocator) -> (database_clone: Database)
```

#### `equiv`

Check if two databases are equivalent (have equivalent entries).

```c
equiv :: proc(
	database_a,
	database_b: ^Database) -> bool
```

#### `relpath_to_path`

Convert a relative path string (relative to the directory of the executable) to an absolute path string.

```c
relpath_to_path :: proc(
	relpath: string,
	allocator: rt.Allocator) -> (path: string)
```

#### `relpath_to_source_path`

Convert a relative path string (relative to the source directory of the database) to an absolute path string.

```c
relpath_to_source_path :: proc(
	database: ^Database,
	relpath: string,
	allocator: rt.Allocator) -> (path: string)
```

#### `path_to_relpath`

Convert an absolute path string to a relative path string (relative to the directory of the executable).

```c
path_to_relpath :: proc(
	path: string,
	allocator: rt.Allocator) -> (relpath: string)
```

#### `make_or_read_database`

Check if a database exists at the given relative path. If it exists, read it; If it does not exist, construct a new one.

```c
make_or_read_database :: proc(
	config: Database_Config,
	allocator: rt.Allocator) -> (database: Database)
```

#### `read`

Read the database at the given relative path.

```c
read :: proc(
	config: Database_Config,
	allocator: runtime.Allocator,
	relpath_override: string = "") -> (database: Database)
```

#### `write`

```c
write :: proc(
	database: ^Database,
	allocator: runtime.Allocator,
	relpath_override: string = "")
```

#### `remove_database`

Remove the database file from disk.

```c
remove_database :: proc(
	database: ^Database) -> (err: os.Error)
```

#### `url_join`

```c
url_join :: proc(
	urls: []URL,
	allocator: rt.Allocator) -> URL
```

#### `url_split`

```c
url_split :: proc(
	url: URL,
	allocator: rt.Allocator) -> (res: []string)
```

#### `relpath_from_url`

Get the relative path (relative to the source directory of the database) of the source of the entry with the given URL.

```c
relpath_from_url :: proc(
	database: ^Database,
	url: URL,
	allocator: rt.Allocator) -> (path: string)
```

#### `path_from_url`

Get the absolute path of the source of the entry with the given URL.

```c
path_from_url :: proc(
	database: ^Database,
	url: URL,
	allocator: rt.Allocator) -> (path: string)
```

#### `entry_was_modified`

Check if the source of the given entry has been updated since the entry was imported to the database.

```c
entry_was_modified :: proc(
	database: ^Database,
	entry: ^Entry) -> (outdated: bool)
```

#### `update_entry`

Update the contents of an entry.

```c
update_entry :: proc(
	database: ^Database,
	entry: ^Entry,
	config: Entry_Config,
	modified: bool)
```

#### `url_search_source`

```c
url_search_source :: proc(
	database: ^Database,
	url: URL,
	allocator: rt.Allocator) -> (path: string, err: os.Error)
```

<details><summary>Description</summary>
Get the path of the first file in the database's source directory that has the a name matching the given URL.
</details>

#### `file_was_modified`

```c
file_was_modified :: proc(
	relpath: string,
	modification_time: ^tm.Time) -> (was_modified: bool)
```

<details><summary>Description</summary>
Watch a given file for modifications. The modification_time parameter is where the latest modification time is stored. Whenever the file is modified, this function will return `true`. This will happen only once per modification. Example:

```
modification_time: tm.Time
for {
	game_tick()
	if file_was_modified(relpath, &modification_time) do do_something() }
```

</details>

#### `remove_file`

```c
remove_file :: proc(
	relpath: string,
	allocator: runtime.Allocator) -> (err: os.Error)
```

#### `rename_file`

```c
rename_file :: proc(
	old_relpath: string,
	new_relpath: string,
	allocator: runtime.Allocator) -> (err: os.Error)
```

#### `watcher_tick`

```c
watcher_tick :: proc(watcher: ^Watcher)
```

<pre>
























</pre>