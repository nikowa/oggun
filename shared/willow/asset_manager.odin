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

URL :: distinct string

MAGIC_NUMBER :: 0b10110100_10010100_10011111_10111100
_Asset_Manager_Binary_Header :: struct {
	magic_number: u32,
	modification_time: time.Time,
	last_autosave_time: time.Time,
	n_entries: u32 }

Asset_Manager_Config :: struct {
	relpath: string,
	source_directory_relpath: string,
	autosave_interval: time.Duration,
	autosave_cap: u32,
	watch: bool }

// (TODO): Remove "DEFAULT_AUTOSAVE_INTERVAL" and "DEFAULT_AUTOSAVE_CAP"

DEFAULT_ASSET_MANAGER_CONFIG: Asset_Manager_Config : {
	relpath = "Data.bin",
	source_directory_relpath = "../data",
	autosave_interval = DEFAULT_AUTOSAVE_INTERVAL,
	autosave_cap = DEFAULT_AUTOSAVE_CAP,
	watch = true }

Asset_Manager :: struct {
	using config: Asset_Manager_Config,
	initialized: bool,
	backing_allocator: runtime.Allocator,
	last_autosave_time: time.Time,
	modification_time: time.Time,
	entries: list.List,
	entries_map: map[URL]^Entry,
	assets: [dynamic]^Asset,
	asset_kinds: map[typeid]Asset_Kind }

Asset_Command :: enum {
	Validate,
	Query_Location,
	Import,
	Export,
	Load,
	Save,
	Upload,
	Download }

Asset_Location :: bit_set[Asset_Location_Field]

Asset_Location_Field :: enum {
	Source_Directory,
	Database_File,
	Database,
	Main_Memory,
	GPU_Memory }

Asset_Command_Proc :: #type proc(asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool)

Asset_Config :: struct {
	url: URL,
	derived_type: typeid }

DEFAULT_URL :: "unknown:unnamed"

DEFAULT_ASSET_CONFIG: Asset_Config : {
	url = DEFAULT_URL,
	derived_type = string }

// (NOTE): All types that derive from asset must be remain at the same memory address after initialization by "init_asset".
Asset :: struct {
	using asset_config: Asset_Config,
	location: Asset_Location }

Asset_Kind :: struct {
	command: Asset_Command_Proc }

Entry_Config :: struct {
	url: URL,
	modification_time: time.Time,
	data: []u8 }

DEFAULT_ENTRY_CONFIG: Entry_Config : {
	url = DEFAULT_URL,
	modification_time = {},
	data = {} }

Entry :: struct {
	using config: Entry_Config,
	node: list.Node,
	hash: u32 }

asset_manager_init :: proc(config: Asset_Manager_Config, backing_allocator: runtime.Allocator = context.allocator) {
	context.allocator = backing_allocator
	engine.asset_manager.config = config
	engine.asset_manager.backing_allocator = backing_allocator
	engine.asset_manager.entries_map = make_map(map[URL]^Entry)
	engine.asset_manager.asset_kinds = make(map[typeid]Asset_Kind)
	engine.asset_manager.assets = make_dynamic_array_len_cap([dynamic]^Asset, 0, 32)
	register_builtin_asset_kinds()
	engine.asset_manager.initialized = true }

asset_command :: proc(Asset_Type: typeid, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	asset_kind, registered := engine.asset_manager.asset_kinds[Asset_Type]
	if ! registered do log.errorf("Type %v not registered!", Asset_Type)
	when ODIN_DEBUG do asset_kind.command(asset, .Validate, false)
	assert(asset_kind.command != nil)
	return asset_kind.command(asset, command, watch) }

asset_commands :: proc(Asset_Type: typeid, asset: ^Asset, commands: []Asset_Command, watch: bool = false) -> (ok: bool) {
	ok = true
	for command in commands do ok &&= asset_command(Asset_Type, asset, command, watch)
	return ok }

@(deferred_in=_init_asset_end)
init_asset :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	_init_asset_begin(Asset_Type, asset, config) }

@private
_init_asset_begin :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	asset.asset_config = config
	append(&engine.asset_manager.assets, asset) }

@private
_init_asset_end :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	asset_commands(Asset_Type, asset, { .Validate, .Query_Location }) }

asset_object :: proc(asset: ^Asset, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(asset) - offset) }

register_asset_kind :: proc($Type: typeid, kind: Asset_Kind) {
	// log.info("Registering type ", type_info_of(Type).id)
	engine.asset_manager.asset_kinds[Type] = kind }

tick_asset_manager :: proc() {
	if ! engine.asset_manager.watch do return
	for asset in engine.asset_manager.assets {
		asset_kind, ok := engine.asset_manager.asset_kinds[asset.derived_type]
		assert(ok)
		asset_kind.command(asset, .Import, true)
		asset_kind.command(asset, .Load, true)
		asset_kind.command(asset, .Upload, true) } }

make_entry :: proc(url: URL, data: []u8, modification_time: time.Time = { }) -> (entry: Entry) {
	entry = Entry{ url = url, data = data, modification_time = modification_time }
	entry_update_hash(&entry)
	return entry }

delete_entry :: proc(entry: Entry, allocator: runtime.Allocator) {
	delete_slice(entry.data, allocator) }

entry_equiv :: proc(entry_a: ^Entry, entry_b: ^Entry) -> bool {
	return (entry_a.url == entry_b.url) && slice.equal(entry_a.data, entry_b.data) }

get_entry :: proc(url: URL) -> (entry: ^Entry) {
	// return asset_manager.entries_map[url] }
	iterator := asset_manager_iterator()
	for entry in list.iterate_next(&iterator) {
		if entry.url == url do return entry }
	return nil }

asset_manager_iterator :: proc() -> list.Iterator(Entry) {
	return list.iterator_head(engine.asset_manager.entries, Entry, "node") }

get_or_add_entry :: proc(url: URL) -> (entry: ^Entry, existed: bool) {
	entry = get_entry(url)
	existed = (entry != nil)
	if ! existed do entry = add_entry({ url = url })
	return entry, existed }

contains_entry :: proc(url: URL) -> bool {
	return url in engine.asset_manager.entries_map }

log_asset_manager :: proc() {
	log.infof("Asset_Manager %s:", engine.asset_manager.relpath)
	iterator := asset_manager_iterator()
	i: int = 0
	for entry in list.iterate_next(&iterator) {
		log.infof("%d --- %s", i, entry.url)
		i += 1 } }

entry_integrity :: proc(entry: ^Entry) -> (ok: bool) {
	ok = entry.hash == _entry_hash(entry)
	return ok }

// (TODO): Have only 1 backing allocator: "engine.allocator"
add_entry :: proc(config: Entry_Config) -> (entry: ^Entry) {
	if contains_entry(config.url) do return get_entry(config.url)
	entry = new(Entry, engine.asset_manager.backing_allocator)
	entry.config = config
	list.push_back(&engine.asset_manager.entries, &entry.node)
	engine.asset_manager.modification_time = time.now()
	entry_update_hash(entry)
	map_insert(&engine.asset_manager.entries_map, entry.url, entry)
	return entry }

add_or_update_entry :: proc(entry_config: Entry_Config) -> (entry: ^Entry) {
	if entry = get_entry(entry_config.url); entry != nil {
		update_entry(entry, entry_config)
		return entry }
	else do return add_entry(entry_config) }

remove_entry :: proc(entry: ^Entry) {
	list.remove(&engine.asset_manager.entries, &entry.node)
	delete_key(&engine.asset_manager.entries_map, entry.url)
	free(entry) }

clone_entry :: proc(entry: ^Entry, allocator: runtime.Allocator) -> (entry_clone: Entry) {
	entry_clone = entry^
	entry_clone.url = cast(URL)strings.clone(cast(string)entry.url, allocator)
	entry_clone.data = slice.clone(entry.data, allocator)
	return entry_clone }

relpath_to_source_path :: proc(relpath: string, allocator: runtime.Allocator) -> (path: string) {
	path, _ = os.join_path({ relpath_to_path(engine.asset_manager.source_directory_relpath, allocator), relpath }, allocator = allocator)
	return path }

asset_manager_read_or_init :: proc(config: Asset_Manager_Config, allocator: runtime.Allocator) {
	if os.exists(relpath_to_path(config.relpath, context.temp_allocator)) do asset_manager_read(config, allocator)
	else do asset_manager_init(config, allocator) }

asset_manager_read :: proc(config: Asset_Manager_Config, allocator: runtime.Allocator, relpath_override: string = "") {
	asset_manager_init(config, allocator)
	engine.asset_manager.config = config
	path := relpath_to_path((relpath_override != "") ? relpath_override : config.relpath, allocator)
	compressed_data, err := os.read_entire_file_from_path(path, allocator = context.temp_allocator)
	assert(err == nil)
	data := decompress(compressed_data, context.temp_allocator)
	reader: bytes.Reader
	bytes.reader_init(&reader, data)
	binary_header: _Asset_Manager_Binary_Header
	bytes.reader_read_ptr(&reader, &binary_header, size_of(binary_header))
	assert(binary_header.magic_number == MAGIC_NUMBER)
	engine.asset_manager.last_autosave_time = binary_header.last_autosave_time
	log.warn("Reading Asset_Manager.")
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
		add_entry(entry)
		if ! entry_integrity(&entry) do log.errorf("Entry %s is invalid.", entry.url) }
	engine.asset_manager.modification_time = binary_header.modification_time
	register_builtin_asset_kinds() }

asset_manager_write :: proc(allocator: runtime.Allocator, relpath_override: string = "") {
	err: io.Error
	buffer: bytes.Buffer
	binary_header: _Asset_Manager_Binary_Header
	path: string

	log.warn("Writing Asset_Manager.")
	bytes.buffer_init_allocator(&buffer, 0, 32 * mem.Megabyte, allocator = allocator)
	binary_header.magic_number = MAGIC_NUMBER
	binary_header.last_autosave_time = engine.asset_manager.last_autosave_time
	binary_header.n_entries = cast(u32)list_len(engine.asset_manager.entries, Entry, "node")
	_, err = bytes.buffer_write_ptr(&buffer, &binary_header, size_of(binary_header)); assert(err == nil)
	iterator := asset_manager_iterator()
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
	path = relpath_to_path((relpath_override != "") ? relpath_override : engine.asset_manager.relpath, context.temp_allocator)
	data: []u8 = compress(buffer.buf[:], context.temp_allocator)
	assert(os.write_entire_file_from_bytes(path, data) == nil) }

remove_asset_manager :: proc() -> (err: os.Error) {
	return os.remove(relpath_to_path(engine.asset_manager.relpath, context.temp_allocator)) }

url_join :: proc(urls: []URL, allocator: runtime.Allocator) -> URL {
	return cast(URL)strings.join(transmute([]string)urls, sep = ":", allocator = allocator) }

url_split :: proc(url: URL, allocator: runtime.Allocator) -> (res: []string) {
	res, _ = strings.split(cast(string)url, ":")
	return res }

relpath_from_url :: proc(url: URL, allocator: runtime.Allocator) -> (path: string) {
	url_components: []string = url_split(url, allocator)
	working_directory, _ := os.get_executable_directory(allocator)
	filename := url_components[1]
	path, _ = os.join_path({ engine.asset_manager.source_directory_relpath, filename }, allocator)
	return path }

path_from_url :: proc(url: URL, allocator: runtime.Allocator) -> (path: string) {
	relpath: string = relpath_from_url(url, allocator)
	return relpath_to_path(relpath, allocator) }

entry_was_modified :: proc(entry: ^Entry) -> (outdated: bool) {
	if entry == nil do return true
	assert(entry.url != "")
	path := path_from_url(entry.url, context.temp_allocator)
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

update_entry :: proc(entry: ^Entry, config: Entry_Config) {
	if len(entry.data) > 0 do delete(entry.data)
	entry.config = config
	entry_update_hash(entry)
	engine.asset_manager.modification_time = time.now() }
