package willow
import "base:runtime"
import "core:time"
import "core:os"
import "core:mem"
import "core:io"
import "core:bytes"
import "core:slice"
import "core:log"
import "core:strings"
import "core:crypto/hash"
import "vendor:compress/lz4"
import "core:container/intrusive/list"

// (TODO): Do not compress/decompress individual entries, instead compress/decompress the whole database. //
// (TODO): Use linked list instead of dynamic array for entries. //
// (TODO): Decide whether or not entries should be referenced by URL or by pointer. //

URL :: distinct string

MAGIC_NUMBER :: 0b10110100_10010100_10011111_10111100
_Database_Binary_Header :: struct {
	magic_number: u32,
	modification_time: time.Time,
	last_autosave_time: time.Time,
	n_entries: u32 }

Database_Config :: struct {
	relpath: string,
	source_directory_relpath: string,
	autosave_interval: time.Duration,
	autosave_cap: u32 }

Database :: struct {
	using config: Database_Config,
	allocator: runtime.Allocator,
	last_autosave_time: time.Time,
	modification_time: time.Time,
	entries: list.List,
	entries_map: map[URL]^Entry }

Entry_Config :: struct {
	url: URL,
	modification_time: time.Time,
	data: []u8 }

Entry :: struct {
	using config: Entry_Config,
	node: list.Node,
	hash: u32 }

make_database :: proc(config: Database_Config, backing_allocator: runtime.Allocator) -> (database: Database) {
	database.config = config
	database.allocator = backing_allocator
	database.entries_map = make_map(map[URL]^Entry, database.allocator)
	return database }

make_entry :: proc(url: URL, data: []u8, modification_time: time.Time = { }) -> (entry: Entry) {
	entry = Entry{ url = url, data = data, modification_time = modification_time }
	entry_update_hash(&entry)
	return entry }

delete_entry :: proc(entry: Entry, allocator: runtime.Allocator) {
	delete_slice(entry.data, allocator) }

entry_equiv :: proc(entry_a: ^Entry, entry_b: ^Entry) -> bool {
	return (entry_a.url == entry_b.url) && slice.equal(entry_a.data, entry_b.data) }

get_entry :: proc(database: ^Database, url: URL) -> (entry: ^Entry) {
	// return database.entries_map[url] }
	iterator := database_iterator(database)
	for entry in list.iterate_next(&iterator) {
		if entry.url == url do return entry }
	return nil }

database_iterator :: proc(database: ^Database) -> list.Iterator(Entry) {
	return list.iterator_head(database.entries, Entry, "node") }

get_or_add_entry :: proc(database: ^Database, url: URL) -> (entry: ^Entry, existed: bool) {
	entry = get_entry(database, url)
	existed = (entry != nil)
	if ! existed do entry = add_entry(database, { url = url })
	return entry, existed }

contains_entry :: proc(database: ^Database, url: URL) -> bool {
	return url in database.entries_map }

log_database :: proc(database: ^Database) {
	log.infof("Database %s:", database.relpath)
	iterator := database_iterator(database)
	i: int = 0
	for entry in list.iterate_next(&iterator) {
		log.infof("%d --- %s", i, entry.url)
		i += 1 } }

entry_integrity :: proc(entry: ^Entry) -> (ok: bool) {
	ok = entry.hash == _entry_hash(entry)
	return ok }

add_entry :: proc(database: ^Database, config: Entry_Config) -> (entry: ^Entry) {
	if contains_entry(database, config.url) do return get_entry(database, config.url)
	entry = new(Entry, database.allocator)
	entry.config = config
	list.push_back(&database.entries, &entry.node)
	database.modification_time = time.now()
	entry_update_hash(entry)
	map_insert(&database.entries_map, entry.url, entry)
	return entry }

add_or_update_entry :: proc(database: ^Database, entry_config: Entry_Config) -> (entry: ^Entry) {
	if entry = get_entry(database, entry_config.url); entry != nil {
		update_entry(database, entry, entry_config)
		return entry }
	else do return add_entry(database, entry_config) }

remove_entry :: proc(database: ^Database, entry: ^Entry) {
	list.remove(&database.entries, &entry.node)
	delete_key(&database.entries_map, entry.url)
	free(entry) }

clone_entry :: proc(entry: ^Entry, allocator: runtime.Allocator) -> (entry_clone: Entry) {
	entry_clone = entry^
	entry_clone.url = cast(URL)strings.clone(cast(string)entry.url, allocator)
	entry_clone.data = slice.clone(entry.data, allocator)
	return entry_clone }

clone_database :: proc(database: ^Database, allocator: runtime.Allocator) -> (database_clone: Database) {
	database_clone = database^
	database_clone.allocator = allocator
	iterator := database_iterator(database)
	for entry in list.iterate_next(&iterator) {
		add_entry(&database_clone, entry.config) }
	return database_clone }

equiv :: proc(database_a, database_b: ^Database) -> bool {
	if list_len(database_a.entries, Entry, "node") != list_len(database_b.entries, Entry, "node") do return false
	iterator_a := database_iterator(database_a)
	iterator_b := database_iterator(database_b)
	for entry_a in list.iterate_next(&iterator_a) {
		entry_b, _ := list.iterate_next(&iterator_b)
		bytes_a: []u8 = slice.to_bytes(entry_a.data[:])
		bytes_b: []u8 = slice.to_bytes(entry_b.data[:])
		if ! slice.equal(bytes_a, bytes_b) do return false }
	return true }

relpath_to_source_path :: proc(database: ^Database, relpath: string, allocator: runtime.Allocator) -> (path: string) {
	path, _ = os.join_path({ relpath_to_path(database.source_directory_relpath, allocator), relpath }, allocator = allocator)
	return path }

make_or_read_database :: proc(config: Database_Config, allocator: runtime.Allocator) -> (database: Database) {
	if os.exists(relpath_to_path(config.relpath, context.temp_allocator)) do return database_read(config, allocator)
	else do return make_database(config, allocator) }

database_read :: proc(config: Database_Config, allocator: runtime.Allocator, relpath_override: string = "") -> (database: Database) {
	database = make_database(config, allocator)
	database.config = config
	path := relpath_to_path((relpath_override != "") ? relpath_override : config.relpath, allocator)
	compressed_data, err := os.read_entire_file_from_path(path, allocator = context.temp_allocator)
	data := decompress(compressed_data, context.allocator)
	// (TODO) ^ should I use context.temp_allocator here?

	assert(err == nil)
	reader: bytes.Reader
	bytes.reader_init(&reader, data)
	binary_header: _Database_Binary_Header
	bytes.reader_read_ptr(&reader, &binary_header, size_of(binary_header))
	assert(binary_header.magic_number == MAGIC_NUMBER)
	database.last_autosave_time = binary_header.last_autosave_time
	log.warn("Reading Database.")
	for i in 0 ..< binary_header.n_entries {
		entry: Entry
		url_len: u8
		_, err = bytes.reader_read_ptr(&reader, &url_len, size_of(url_len)); assert(err == nil)
		url: []u8 = make([]u8, url_len, allocator)
		_, err = bytes.reader_read_slice(&reader, url); assert(err == nil)
		entry.url = cast(URL)url
		_, err = bytes.reader_read_ptr(&reader, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		data_len: u32
		_, err = bytes.reader_read_ptr(&reader, &data_len, size_of(data_len)); assert(err == nil)
		entry.data = make([]u8, data_len, allocator)
		_, err = bytes.reader_read_slice(&reader, entry.data); assert(err == nil)
		// log.infof("Reading entry \"%s\".", entry.url)
		add_entry(&database, entry)
		if ! entry_integrity(&entry) do log.errorf("Entry %s is invalid.", entry.url) }
	database.modification_time = binary_header.modification_time
	return database }

database_write :: proc(database: ^Database, allocator: runtime.Allocator, relpath_override: string = "") {
	err: io.Error
	buffer: bytes.Buffer
	binary_header: _Database_Binary_Header
	path: string

	log.warn("Writing Database.")
	bytes.buffer_init_allocator(&buffer, 0, 32 * mem.Megabyte, allocator = allocator)
	binary_header.magic_number = MAGIC_NUMBER
	binary_header.last_autosave_time = database.last_autosave_time
	binary_header.n_entries = cast(u32)list_len(database.entries, Entry, "node")
	_, err = bytes.buffer_write_ptr(&buffer, &binary_header, size_of(binary_header)); assert(err == nil)
	iterator := database_iterator(database)
	i: int = 0
	for entry in list.iterate_next(&iterator) {
		defer i += 1
		if ! entry_integrity(entry) do log.errorf("Entry %s is invalid.", entry.url)
		url_len: u8 = cast(u8)len(entry.url)
		_, err = bytes.buffer_write_ptr(&buffer, &url_len, size_of(url_len)); assert(err == nil)
		_, err = bytes.buffer_write_string(&buffer, cast(string)entry.url); assert(err == nil)
		_, err = bytes.buffer_write_ptr(&buffer, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		data_len: u32 = cast(u32)len(entry.data)
		_, err = bytes.buffer_write_ptr(&buffer, &data_len, size_of(data_len)); assert(err == nil)
		_, err = bytes.buffer_write_slice(&buffer, entry.data); assert(err == nil) }
	path = relpath_to_path((relpath_override != "") ? relpath_override : database.relpath, context.temp_allocator)
	data: []u8 = compress(buffer.buf[:], context.temp_allocator)
	assert(os.write_entire_file_from_bytes(path, data) == nil) }

remove_database :: proc(database: ^Database) -> (err: os.Error) {
	return os.remove(relpath_to_path(database.relpath, context.temp_allocator)) }

url_join :: proc(urls: []URL, allocator: runtime.Allocator) -> URL {
	return cast(URL)strings.join(transmute([]string)urls, sep = ":", allocator = allocator) }

url_split :: proc(url: URL, allocator: runtime.Allocator) -> (res: []string) {
	res, _ = strings.split(cast(string)url, ":")
	return res }

relpath_from_url :: proc(database: ^Database, url: URL, allocator: runtime.Allocator) -> (path: string) {
	url_components: []string = url_split(url, allocator)
	working_directory, _ := os.get_executable_directory(allocator)
	filename := url_components[1]
	path, _ = os.join_path({ database.source_directory_relpath, filename }, allocator)
	return path }

path_from_url :: proc(database: ^Database, url: URL, allocator: runtime.Allocator) -> (path: string) {
	relpath: string = relpath_from_url(database, url, allocator)
	return relpath_to_path(relpath, allocator) }

entry_was_modified :: proc(database: ^Database, entry: ^Entry) -> (outdated: bool) {
	if entry == nil do return true
	assert(entry.url != "")
	path := path_from_url(database, entry.url, context.temp_allocator)
	modification_time, err := os.modification_time_by_path(path)
	if err != nil do return false
	outdated = time.diff(entry.modification_time, modification_time) > 0
	if outdated do log.infof("Source of entry \"%s\" was modified.", entry.url)
	return outdated }

_entry_hash :: proc(entry: ^Entry) -> (hashed: u32) {
	digest := hash.hash_bytes(.Insecure_MD5, entry.data, context.temp_allocator)
	return slice.reinterpret([]u32, digest)[0] }

entry_update_hash :: proc(entry: ^Entry) {
	entry.hash = _entry_hash(entry) }

update_entry :: proc(database: ^Database, entry: ^Entry, config: Entry_Config) {
	if len(entry.data) > 0 do delete(entry.data)
	entry.config = config
	entry_update_hash(entry)
	database.modification_time = time.now() }
