package database
import fmt "core:fmt"
import rt "base:runtime"
import tm "core:time"
import os "core:os"
import b "core:bytes"
import mem "core:mem"
import io "core:io"
import sl "core:slice"
import lz4 "vendor:compress/lz4"
import log "core:log"
import str "core:strings"
import base "../base"
import sp "core:path/slashpath"



URL :: distinct string



MAGIC_NUMBER :: 0b10110100_10010100_10011111_10111100
Database_Binary_Header :: struct {
	magic_number: u32,
	n_entries: u32 }

// Database binary:
// Database_Binary_Header | header
// [^]u8                  | entries

Database_Config :: struct {
	relpath: string,
	source_directory_relpath: string }

Database :: struct {
	using config: Database_Config,
	entries: [dynamic]Entry,
	entries_map: map[URL]^Entry }

Entry :: struct {
	url: URL,
	modification_time: tm.Time,
	compressed: b8,
	data: []u8 }

// TODO: Add a *compression kind* field, which selects between LZ4 and QOI.

// Entry binary:
// u8      | url_len
// [^]u8   | url
// tm.Time | modification_time
// b8      | compressed
// u32     | data_len
// [^]u8   | data

make_database :: proc(config: Database_Config, allocator: rt.Allocator) -> (database: Database) {
	return Database{
		config = config,
		entries = make_dynamic_array_len_cap([dynamic]Entry, 0, 64, allocator),
		entries_map = make_map(map[URL]^Entry, allocator) } }

delete_database :: proc(database: Database, allocator: rt.Allocator) {
	rt.delete_dynamic_array(database.entries)
	rt.delete_map(database.entries_map) }

make_entry :: proc(url: URL, data: []u8, modification_time: tm.Time = { }, compressed: b8 = false) -> (entry: Entry) {
	return Entry{ url = url, data = data, modification_time = modification_time, compressed = compressed } }

delete_entry :: proc(entry: Entry, allocator: rt.Allocator) {
	delete_slice(entry.data, allocator) }

entry_equiv :: proc(entry_a: ^Entry, entry_b: ^Entry) -> bool {
	return (entry_a.url == entry_b.url) &&
		(entry_a.compressed == entry_b.compressed) &&
		sl.equal(entry_a.data, entry_b.data) }

entry_from_url :: proc(database: ^Database, url: URL) -> (entry: ^Entry, ok: bool) {
	return database.entries_map[url] }

contains_entry :: proc(database: ^Database, url: URL) -> bool {
	return url in database.entries_map }

add_entry :: proc(database: ^Database, entry: Entry) -> (entry_ptr: ^Entry, err: os.Error) {
	append_elem(&database.entries, entry) or_return
	index := len(database.entries) - 1
	entry := &database.entries[index]
	return map_insert(&database.entries_map, entry.url, entry)^, os.General_Error.None }

remove_entry :: proc(database: ^Database, entry: ^Entry) {
	index: int = -1
	for &this_entry, i in database.entries do if &this_entry == entry {
		index = i
		break }
	if index == -1 do return
	entry := database.entries[index]
	delete_key(&database.entries_map, entry.url)
	unordered_remove(&database.entries, index)
	update_entries_map(database) }

@(private="file")
update_entries_map :: proc(database: ^Database) {
	for &entry, i in database.entries {
		database.entries_map[entry.url] = &database.entries[i] } }

clone_entry :: proc(entry: ^Entry, allocator: rt.Allocator) -> (entry_clone: Entry) {
	entry_clone = entry^
	entry_clone.url = cast(URL)str.clone(cast(string)entry.url, allocator)
	entry_clone.data = sl.clone(entry.data, allocator)
	return entry_clone }

clone :: proc(database: ^Database, allocator: rt.Allocator) -> (database_clone: Database) {
	database_clone = database^
	for &entry, i in database.entries {
		database_clone.entries[i] = clone_entry(&entry, allocator)
		database_clone.entries_map[entry.url] = &database_clone.entries[i] }
	return database_clone }

equiv :: proc(database_a, database_b: ^Database) -> bool {
	if len(database_a.entries) != len(database_b.entries) do return false
	for _, i in database_a.entries {
		bytes_a: []u8 = sl.to_bytes(database_a.entries[i].data[:])
		bytes_b: []u8 = sl.to_bytes(database_b.entries[i].data[:])
		if ! sl.equal(bytes_a, bytes_b) do return false }
	return true }

relpath_to_path :: proc(relpath: string, allocator: rt.Allocator) -> (path: string) {
	base, _ := os.get_working_directory(allocator = allocator)
	path, _ = os.join_path({ base, relpath }, allocator = allocator)
	return path }

relpath_to_source_path :: proc(database: ^Database, relpath: string, allocator: rt.Allocator) -> (path: string) {
	path, _ = os.join_path({ relpath_to_path(database.source_directory_relpath, allocator), relpath }, allocator = allocator)
	return path }

path_to_relpath :: proc(path: string, allocator: rt.Allocator) -> (relpath: string) {
	base, _ := os.get_working_directory(allocator = allocator)
	relpath, _ = os.get_relative_path(base, path, allocator = allocator)
	return relpath }

make_or_read_database :: proc(config: Database_Config, allocator: rt.Allocator) -> (database: Database) {
	if os.exists(relpath_to_path(config.relpath, allocator)) do return read(config.relpath, allocator)
	else do return make_database(config, allocator) }

_read_without_decompressing :: proc(relpath: string, allocator: rt.Allocator) -> (database: Database) {
	data: []u8
	err: os.Error
	database.relpath = relpath
	data, err = os.read_entire_file_from_path(relpath_to_path(relpath, allocator), allocator = allocator)
	assert(err == nil)
	reader: b.Reader
	b.reader_init(&reader, data)
	binary_header: Database_Binary_Header
	b.reader_read_ptr(&reader, &binary_header, size_of(binary_header))
	assert(binary_header.magic_number == MAGIC_NUMBER)
	database.entries = make_dynamic_array([dynamic]Entry, allocator = allocator)
	for i in 0 ..< binary_header.n_entries {
		entry: Entry
		url_len: u8
		_, err = b.reader_read_ptr(&reader, &url_len, size_of(url_len)); assert(err == nil)
		url: []u8 = make([]u8, url_len, allocator)
		_, err = b.reader_read_slice(&reader, url); assert(err == nil)
		entry.url = cast(URL)url
		_, err = b.reader_read_ptr(&reader, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		_, err = b.reader_read_ptr(&reader, &entry.compressed, size_of(entry.compressed)); assert(err == nil)
		data_len: u32
		_, err = b.reader_read_ptr(&reader, &data_len, size_of(data_len)); assert(err == nil)
		entry.data = make([]u8, data_len, allocator)
		_, err = b.reader_read_slice(&reader, entry.data); assert(err == nil)
		add_entry(&database, entry) }
	return database }

read :: read_and_decompress
read_and_decompress :: proc(relpath: string, allocator: rt.Allocator) -> (database: Database) {
	database = _read_without_decompressing(relpath, allocator = allocator)
	decompress(&database, allocator = allocator)
	return database }

write :: compress_and_write
compress_and_write :: proc(database: ^Database, allocator: rt.Allocator) {
	compress(database, allocator = allocator)
	_write_without_compressing(database, allocator = allocator) }

_write_without_compressing :: proc(database: ^Database, allocator: rt.Allocator) {
	err: io.Error
	buffer: b.Buffer
	b.buffer_init_allocator(&buffer, 0, 32 * mem.Megabyte, allocator = allocator)
	binary_header: Database_Binary_Header = { magic_number = MAGIC_NUMBER, n_entries = cast(u32)len(database.entries) }
	_, err = b.buffer_write_ptr(&buffer, &binary_header, size_of(binary_header)); assert(err == nil)
	for &entry, i in database.entries {
		url_len: u8 = cast(u8)len(entry.url)
		_, err = b.buffer_write_ptr(&buffer, &url_len, size_of(url_len)); assert(err == nil)
		_, err = b.buffer_write_string(&buffer, cast(string)entry.url); assert(err == nil)
		_, err = b.buffer_write_ptr(&buffer, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		_, err = b.buffer_write_ptr(&buffer, &entry.compressed, size_of(entry.compressed)); assert(err == nil)
		data_len: u32 = cast(u32)len(entry.data)
		_, err = b.buffer_write_ptr(&buffer, &data_len, size_of(data_len)); assert(err == nil)
		_, err = b.buffer_write_slice(&buffer, entry.data); assert(err == nil) }
	assert(os.write_entire_file_from_bytes(relpath_to_path(database.relpath, context.temp_allocator), buffer.buf[:]) == nil) }

remove_database :: proc(database: ^Database) -> (err: os.Error) {
	return os.remove(relpath_to_path(database.relpath, context.temp_allocator)) }

_compress_bytes :: proc(bytes: []u8, allocator: rt.Allocator) -> (compressed_bytes: []u8) {
	compress_bound: i32 = lz4.compressBound(cast(i32)len(bytes))
	compressed_bytes_buffer: []u8 = make([]u8, cast(int)compress_bound, allocator)
	compressed_size: i32 = lz4.compress_default(&bytes[0], &compressed_bytes_buffer[0], cast(i32)len(bytes), compress_bound)
	assert(compressed_size != 0)
	compressed_bytes = sl.clone(compressed_bytes_buffer[0:compressed_size], allocator)
	delete(compressed_bytes_buffer, allocator)
	return compressed_bytes }

_decompress_bytes :: proc(compressed_bytes: []u8, allocator: rt.Allocator) -> (bytes: []u8) {
	estimated_compression_ratio: f32 = 0.5
	for {
		decompress_bound: i32 = cast(i32)(cast(f32)len(compressed_bytes) / estimated_compression_ratio)
		bytes_buffer: []u8 = make([]u8, cast(int)decompress_bound, allocator)
		decompressed_size: i32 = lz4.decompress_safe(&compressed_bytes[0], &bytes_buffer[0], cast(i32)len(compressed_bytes), decompress_bound)
		if decompressed_size < 0 {
			fmt.println(base.WARN, "Decompress bound", decompress_bound, "not sufficient.")
			estimated_compression_ratio /= 2.0
			delete(bytes_buffer, allocator)
			continue }
		bytes = sl.clone(bytes_buffer[0:decompressed_size], allocator)
		delete(bytes_buffer, allocator)
		return bytes } }

compress :: proc(database: ^Database, allocator: rt.Allocator) {
	for &entry in database.entries do if ! entry.compressed {
		compress_data: []u8 = _compress_bytes(entry.data, allocator = allocator)
		delete(entry.data, allocator = allocator)
		entry.data = compress_data
		entry.compressed = true } }

decompress :: proc(database: ^Database, allocator: rt.Allocator) {
	for &entry in database.entries do if entry.compressed {
		data: []u8 = _decompress_bytes(entry.data, allocator = allocator)
		delete(entry.data, allocator = allocator)
		entry.data = data
		entry.compressed = false } }

url_join :: proc(urls: []URL, allocator: rt.Allocator) -> URL {
	return cast(URL)str.join(transmute([]string)urls, sep = ":", allocator = allocator) }

url_split :: proc(url: URL, allocator: rt.Allocator) -> (res: []string) {
	res, _ = str.split(cast(string)url, ":")
	return res }

URL_TYPE_EXTENSIONS :: [?][2]string {
	{ "shader", "glsl" },
	{ "image", "png" },
	{ "audio-mp3", "mp3" } }

relpath_from_url :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string) {
	source_directory: string

	url_components: []string = url_split(url, allocator)
	working_directory, _ := os.get_working_directory(allocator)
	extension: string = ""
	for type_extension in URL_TYPE_EXTENSIONS do if url_components[0] == type_extension[0] {
		extension = type_extension[1]
		break }
	if extension == "" do return ""
	filename, _ := os.join_filename(url_components[1], extension, allocator)
	path, _ = os.join_path({ database.source_directory_relpath, filename }, allocator)
	return path }

path_from_url :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string) {
	relpath: string = relpath_from_url(database, url, allocator)
	return relpath_to_path(relpath, allocator) }

entry_outdated :: proc(database: ^Database, entry: ^Entry) -> (outdated: bool) {
	if entry == nil do return true
	assert(entry.url != "")
	path := path_from_url(database, entry.url, context.temp_allocator)
	modification_time, err := os.modification_time_by_path(path)
	if err != nil do return false
	return tm.diff(entry.modification_time, modification_time) > 0 }

entry_update :: proc(entry: ^Entry, data: []u8, modification_time: tm.Time) {
	if entry.data != nil do delete(entry.data)
	entry.data = data
	entry.modification_time = modification_time }

@(require_results)
url_search_source :: proc(database: ^Database, url: URL, allocator: rt.Allocator) -> (path: string, err: os.Error) {
	url_name: string
	source_directory_path: string
	file_infos: []os.File_Info

	url_name = url_split(url, context.temp_allocator)[1]
	source_directory_path = relpath_to_path(database.source_directory_relpath, allocator)
	file_infos = os.read_directory_by_path(source_directory_path, -1, context.temp_allocator) or_return
	for file_info in file_infos do if sp.name(file_info.name, false, context.temp_allocator) == url_name do return str.clone(file_info.fullpath, allocator), os.General_Error.None
	return "", os.General_Error.Not_Exist }
