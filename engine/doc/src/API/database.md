# Database

A database is a collection of bite slices, accessed by a string URL.

### Types

#### `URL`

```c
URL :: distinct string
```

#### `Database_Config`

```c
Database_Config :: struct {
	relpath: string,
	source_directory_relpath: string }
```

#### `Database`

```c
Database :: struct {
	using config: Database_Config,
	entries: [dynamic]Entry,
	entries_map: map[URL]^Entry }
```

#### `Entry`

```c
Entry :: struct {
	url: URL,
	modification_time: tm.Time,
	compressed: b8,
	data: []u8 }
```

#### `make_database`

Database constructor.

```c
make_database :: proc(config: Database_Config, allocator: rt.Allocator) -> (database: Database)
```

#### `delete_database`

Database destructor.

```c
delete_database :: proc(database: Database, allocator: rt.Allocator)
```

#### `make_entry`

Entry constructor.

```c
make_entry :: proc(url: URL, data: []u8, modification_time: tm.Time = { }, compressed: b8 = false) -> (entry: Entry)
```

#### `delete_entry`

Entry destructor.

```c
delete_entry :: proc(entry: Entry, allocator: rt.Allocator)
```

#### `entry_equiv`

Check if two entries are equivalent (equivalent URL, equivalent data, equivalent compressedness state).

```c
entry_equiv :: proc(entry_a: ^Entry, entry_b: ^Entry)
```

#### `entry_from_url`

Retreive entry from database by URL.

```c
entry_from_url :: proc(database: ^Database, url: URL) -> (entry: ^Entry, ok: bool)
```

#### `contains_entry`

Check if database contains entry with given URL.

```c
contains_entry :: proc(database: ^Database, url: URL) -> bool
```

#### `add_entry`

Add entry to database.

```c
add_entry :: proc(database: ^Database, entry: Entry) -> (entry_ptr: ^Entry, err: os.Error)
```

#### `remove_entry`

Remove entry from database.

```c
remove_entry :: proc(database: ^Database, entry: ^Entry)
```

#### `clone_entry`

Clone an entry.

```c
clone_entry :: proc(entry: ^Entry, allocator: rt.Allocator) -> (entry_clone: Entry)
```

#### `clone`

Clone a database.

```c
clone :: proc(database: ^Database, allocator: rt.Allocator) -> (database_clone: Database)
```

#### `equiv`

Check if two databases are equivalent (have equivalent entries).

```c
equiv :: proc(database_a, database_b: ^Database) -> bool
```

#### `relpath_to_path`

Convert a relative path string (relative to the directory of the executable) to an absolute path string.

```c
relpath_to_path :: proc(relpath: string, allocator: rt.Allocator) -> (path: string)
```

#### `relpath_to_source_path`

Convert a relative path string (relative to the source directory of the database) to an absolute path string.

```c
relpath_to_source_path :: proc(database: ^Database, relpath: string, allocator: rt.Allocator) -> (path: string)
```

#### `path_to_relpath`

Convert an absolute path string to a relative path string (relative to the directory of the executable).

```c
path_to_relpath :: proc(path: string, allocator: rt.Allocator) -> (relpath: string)
```

#### `make_or_read_database`

Check if a database exists at the given relative path. If it exists, read it; If it does not exist, construct a new one.

```c
make_or_read_database :: proc(config: Database_Config, allocator: rt.Allocator) -> (database: Database)
```

#### `read`

Read the database at the given relative path.

```c
read :: proc(relpath: string, allocator: rt.Allocator) -> (database: Database)
```

#### `write`

```c
compress_and_write :: proc(database: ^Database, allocator: rt.Allocator)
```

#### `remove_database`

Remove the database file from disk.

```c
remove_database :: proc(database: ^Database) -> (err: os.Error)
```

#### `url_join`

```c
url_join :: proc(urls: []URL, allocator: rt.Allocator) -> URL
```

#### `url_split`

```c
url_split :: proc(url: URL, allocator: rt.Allocator) -> (res: []string)
```

#### `relpath_from_url`

Get the relative path (relative to the source directory of the database) of the source of the entry with the given URL.

```c
relpath_from_url :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string)
```

#### `path_from_url`

Get the absolute path of the source of the entry with the given URL.

```c
path_from_url :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string)
```

#### `entry_outdated`

Check if the source of the given entry has been updated since the entry was imported to the database.

```c
entry_outdated :: proc(database: ^Database, entry: ^Entry) -> (outdated: bool)
```

#### `entry_update`

Update the contents of an entry.

```c
entry_update :: proc(entry: ^Entry, data: []u8, modification_time: tm.Time)
```

#### `url_search_source`

Get the path of the first file in the database's source directory that has the a name matching the given URL.

```c
url_search_source :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string, err: os.Error)
```
