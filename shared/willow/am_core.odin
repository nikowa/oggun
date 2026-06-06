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
import "core:fmt"
import "core:math/bits"

// (TOOD): All functions that might want to use the backing allocator should have an explicit allocator param.

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
	autosave_interval = 30 * time.Minute,
	autosave_cap = 10,
	watch = true }

Asset_Manager :: struct {
	using config: Asset_Manager_Config,
	initialized: bool,
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

// (NOTE): All types that derive from asset must be remain at the same memory address after initialization by "am_init_asset".
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

am_init :: proc(config: Asset_Manager_Config) {
	engine.asset_manager.config = config
	engine.asset_manager.entries_map = make_map(map[URL]^Entry)
	engine.asset_manager.asset_kinds = make(map[typeid]Asset_Kind)
	engine.asset_manager.assets = make_dynamic_array_len_cap([dynamic]^Asset, 0, 32)
	am_register_builtin_kinds()
	engine.asset_manager.initialized = true }

am_verify_watch_no_leak :: proc(Asset_Type: typeid, asset: ^Asset, command: Asset_Command) -> (ok: bool) {
	// (TODO): Implement this. //
	return true }

am_command :: proc(Asset_Type: typeid, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	asset_kind, registered := engine.asset_manager.asset_kinds[Asset_Type]
	if ! registered do log.errorf("Type %v not registered!", Asset_Type)
	when ODIN_DEBUG do asset_kind.command(asset, .Validate, false)
	assert(asset_kind.command != nil)
	return asset_kind.command(asset, command, watch) }

am_commands :: proc(Asset_Type: typeid, asset: ^Asset, commands: []Asset_Command, watch: bool = false) -> (ok: bool) {
	ok = true
	for command in commands do ok &&= am_command(Asset_Type, asset, command, watch)
	return ok }

@(deferred_in=_am_init_asset_end)
am_init_asset :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	_am_init_asset_begin(Asset_Type, asset, config) }

@private
_am_init_asset_begin :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	asset.asset_config = config
	append(&engine.asset_manager.assets, asset) }

@private
_am_init_asset_end :: proc(Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	am_commands(Asset_Type, asset, { .Validate, .Query_Location }) }

am_asset_base :: proc(asset: ^Asset, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(asset) - offset) }

am_register_asset_kind :: proc($Type: typeid, kind: Asset_Kind) {
	// log.info("Registering type ", type_info_of(Type).id)
	engine.asset_manager.asset_kinds[Type] = kind }

am_tick :: proc() {
	if ! engine.asset_manager.watch do return
	for asset in engine.asset_manager.assets {
		asset_kind, ok := engine.asset_manager.asset_kinds[asset.derived_type]
		assert(ok)
		asset_kind.command(asset, .Import, true)
		asset_kind.command(asset, .Load, true)
		asset_kind.command(asset, .Upload, true) } }

am_make_entry :: proc(url: URL, data: []u8, modification_time: time.Time = { }) -> (entry: Entry) {
	entry = Entry{ url = url, data = data, modification_time = modification_time }
	am_entry_update_hash(&entry)
	return entry }

am_delete_entry :: proc(entry: Entry, allocator: runtime.Allocator) {
	delete_slice(entry.data, allocator) }

am_get_entry :: proc(url: URL) -> (entry: ^Entry) {
	// return asset_manager.entries_map[url] }
	iterator := am_iterator()
	for entry in list.iterate_next(&iterator) {
		if entry.url == url do return entry }
	return nil }

am_iterator :: proc() -> list.Iterator(Entry) {
	return list.iterator_head(engine.asset_manager.entries, Entry, "node") }

am_get_or_add_entry :: proc(url: URL) -> (entry: ^Entry, existed: bool) {
	entry = am_get_entry(url)
	existed = (entry != nil)
	if ! existed do entry = am_add_entry({ url = url })
	return entry, existed }

am_contains_entry :: proc(url: URL) -> bool {
	return url in engine.asset_manager.entries_map }

am_log :: proc() {
	log.infof("Asset_Manager %s:", engine.asset_manager.relpath)
	iterator := am_iterator()
	i: int = 0
	for entry in list.iterate_next(&iterator) {
		log.infof("%d --- %s", i, entry.url)
		i += 1 } }

am_entry_integrity :: proc(entry: ^Entry) -> (ok: bool) {
	ok = entry.hash == am_entry_hash(entry)
	return ok }

// (TODO): Have only 1 backing allocator: "engine.allocator"
am_add_entry :: proc(config: Entry_Config) -> (entry: ^Entry) {
	// (TODO): There is no point in checking if the entry exists. THere is "am_get_or_add_entry" for that.
	if am_contains_entry(config.url) do return am_get_entry(config.url)
	entry = new(Entry, engine.backing_allocator)
	entry.config = config
	list.push_back(&engine.asset_manager.entries, &entry.node)
	engine.asset_manager.modification_time = time.now()
	am_entry_update_hash(entry)
	map_insert(&engine.asset_manager.entries_map, entry.url, entry)
	return entry }

am_add_or_update_entry :: proc(entry_config: Entry_Config) -> (entry: ^Entry) {
	if entry = am_get_entry(entry_config.url); entry != nil {
		am_update_entry(entry, entry_config)
		return entry }
	else do return am_add_entry(entry_config) }

am_remove_entry :: proc(entry: ^Entry) {
	list.remove(&engine.asset_manager.entries, &entry.node)
	delete_key(&engine.asset_manager.entries_map, entry.url)
	free(entry) }

am_clone_entry :: proc(entry: ^Entry, allocator: runtime.Allocator) -> (entry_clone: Entry) {
	entry_clone = entry^
	entry_clone.url = cast(URL)strings.clone(cast(string)entry.url, allocator)
	entry_clone.data = slice.clone(entry.data, allocator)
	return entry_clone }

am_relpath_to_source_path :: proc(relpath: string, allocator: runtime.Allocator) -> (path: string) {
	path, _ = os.join_path({ relpath_to_path(engine.asset_manager.source_directory_relpath, allocator), relpath }, allocator = allocator)
	return path }

am_read_or_init :: proc(config: Asset_Manager_Config) {
	if os.exists(relpath_to_path(config.relpath, context.temp_allocator)) do am_read(config)
	else do am_init(config) }

am_read :: proc(config: Asset_Manager_Config, relpath_override: string = "") {
	am_init(config)
	engine.asset_manager.config = config
	path := relpath_to_path((relpath_override != "") ? relpath_override : config.relpath, context.allocator)
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
		url: []u8 = make([]u8, url_len, context.allocator)
		_, err = bytes.reader_read_slice(&reader, url); assert(err == nil)
		entry.url = cast(URL)url
		_, err = bytes.reader_read_ptr(&reader, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		data_len: u32
		_, err = bytes.reader_read_ptr(&reader, &data_len, size_of(data_len)); assert(err == nil)
		entry.data = make([]u8, data_len, context.allocator)
		_, err = bytes.reader_read_slice(&reader, entry.data); assert(err == nil)
		// log.infof("Reading entry \"%s\".", entry.url)
		am_add_entry(entry)
		if ! am_entry_integrity(&entry) do log.errorf("Entry %s is invalid.", entry.url) }
	engine.asset_manager.modification_time = binary_header.modification_time
	am_register_builtin_kinds() }

am_write :: proc(allocator: runtime.Allocator, relpath_override: string = "") {
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
	iterator := am_iterator()
	i: int = 0
	for entry in list.iterate_next(&iterator) {
		defer i += 1
		if ! am_entry_integrity(entry) do log.errorf("Entry %s is invalid.", entry.url)
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

am_url_join :: proc(urls: []URL, allocator: runtime.Allocator) -> URL {
	return cast(URL)strings.join(transmute([]string)urls, sep = ":", allocator = allocator) }

am_url_split :: proc(url: URL, allocator: runtime.Allocator, loc := #caller_location) -> (res: []string) {
	res, _ = strings.split(cast(string)url, ":", loc=loc)
	return res }

am_relpath_from_url :: proc(url: URL, allocator: runtime.Allocator, loc := #caller_location) -> (path: string) {
	url_components: []string = am_url_split(url, allocator, loc=loc)
	working_directory, _ := os.get_executable_directory(allocator)
	filename := url_components[1]
	path, _ = os.join_path({ engine.asset_manager.source_directory_relpath, filename }, allocator)
	return path }

am_path_from_url :: proc(url: URL, allocator: runtime.Allocator, loc := #caller_location) -> (path: string) {
	relpath: string = am_relpath_from_url(url, allocator, loc=loc)
	return relpath_to_path(relpath, allocator) }

am_entry_was_modified :: proc(entry: ^Entry) -> (outdated: bool) {
	if entry == nil do return true
	assert(entry.url != "")
	path := am_path_from_url(entry.url, context.temp_allocator)
	modification_time, err := os.modification_time_by_path(path)
	if err != nil do return false
	outdated = time.diff(entry.modification_time, modification_time) > 0
	if outdated do log.infof("Source of entry \"%s\" was modified.", entry.url)
	return outdated }

am_entry_hash :: proc(entry: ^Entry) -> (hashed: u32) {
	digest := hash.hash_bytes(.Insecure_MD5, entry.data, engine.backing_allocator)
	return slice.reinterpret([]u32, digest)[0] }

am_entry_update_hash :: proc(entry: ^Entry) {
	entry.hash = am_entry_hash(entry) }

am_update_entry :: proc(entry: ^Entry, config: Entry_Config) {
	// (TODO): This triggers a "bad free" error. //
	// if len(entry.data) > 0 do delete(entry.data)
	entry.config = config
	am_entry_update_hash(entry)
	engine.asset_manager.modification_time = time.now() }

am_autosave :: proc() {
	time_now: time.Time
	relpath: string
	saved: bool
	file_infos: []os.File_Info
	file_info_oldest: os.File_Info
	n_autosaves: u32
	err: os.Error

	file_name_is_autosave :: proc(name: string) -> bool {
		if ! strings.contains(name, "Data-") do return false
		if ! (os.ext(name) == ".bin") do return false
		return true }

	time_now = time.now()
	if time.diff(engine.asset_manager.last_autosave_time, time_now) > engine.asset_manager.autosave_interval {
		relpath = fmt.tprintf("cache/Data-%d.bin", time.time_to_unix_nano(time_now))
		log.infof("Autosaving %s to %s.", engine.asset_manager.relpath, relpath)
		am_write(context.temp_allocator, relpath)
		engine.asset_manager.last_autosave_time = time_now
		file_infos, err = os.read_directory_by_path(relpath_to_path("cache", context.temp_allocator), -1, context.temp_allocator)
		file_info_oldest.creation_time = { bits.I64_MAX }
		n_autosaves = 0
		for file_info in file_infos do if file_name_is_autosave(file_info.name) do n_autosaves += 1
		if n_autosaves <= engine.asset_manager.autosave_cap do return
		for file_info in file_infos {
			if ! file_name_is_autosave(file_info.name) do continue
			if time.diff(file_info_oldest.creation_time, file_info.creation_time) < 0 do file_info_oldest = file_info }
		os.remove(file_info_oldest.fullpath) } }
