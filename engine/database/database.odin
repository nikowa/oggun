package database
import rt "base:runtime"
import t "core:time"
import os "core:os"
import b "core:bytes"
import mem "core:mem"
import io "core:io"
import sl "core:slice"
import lz4 "vendor:compress/lz4"
import log "core:log"
import str "core:strings"



MAGIC_NUMBER :: 0b10110100_10010100_10011111_10111100
Database_Binary_Header :: struct {
	magic_number: u32,
	n_entries: u32 }

// Database binary:
// Database_Binary_Header | header
// [^]u8                  | entries

Database :: struct {
	relpath: string,
	entries: [dynamic]Entry,
	entries_map: map[string]^Entry }

Entry :: struct {
	url: string,
	modification_time: t.Time,
	compressed: b8,
	data: []u8 }

// Entry binary:
// u8     | url_len
// [^]u8  | url
// t.Time | modification_time
// b8     | compressed
// u32    | data_len
// [^]u8  | data

make_database :: proc(relpath: string, allocator := context.allocator) -> (database: Database) {
	return Database{
		relpath = relpath,
		entries = make_dynamic_array_len_cap([dynamic]Entry, 0, 64, allocator),
		entries_map = make_map(map[string]^Entry, allocator) } }

make_entry :: proc(url: string, data: []u8, modification_time: t.Time = { }, compressed: b8 = false) -> (entry: Entry) {
	return Entry{ url = url, data = data, modification_time = modification_time, compressed = compressed } }

entry_from_url :: proc(database: ^Database, url: string) -> (entry: ^Entry, ok: bool) {
	return database.entries_map[url] }

add_entry :: proc(database: ^Database, entry: Entry) -> (entry_ptr: ^Entry) {
	_, err := append_elem(&database.entries, entry); assert(err == nil)
	index := len(database.entries) - 1
	entry := &database.entries[index]
	return map_insert(&database.entries_map, entry.url, entry)^ }

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

update_entries_map :: proc(database: ^Database) {
	for &entry, i in database.entries {
		database.entries_map[entry.url] = &database.entries[i] } }

clone_entry :: proc(entry: ^Entry, allocator := context.allocator) -> (entry_clone: Entry) {
	entry_clone = entry^
	entry_clone.url = str.clone(entry.url, allocator)
	entry_clone.data = sl.clone(entry.data, allocator)
	return entry_clone }

clone :: proc(database: ^Database, allocator := context.allocator) -> (database_clone: Database) {
	database_clone = database^
	for &entry, i in database.entries {
		database_clone.entries[i] = clone_entry(&entry)
		database_clone.entries_map[entry.url] = &database_clone.entries[i] }
	return database_clone }

equiv :: proc(database_a, database_b: ^Database) -> bool {
	if len(database_a.entries) != len(database_b.entries) do return false
	for _, i in database_a.entries {
		bytes_a: []u8 = sl.to_bytes(database_a.entries[i].data[:])
		bytes_b: []u8 = sl.to_bytes(database_b.entries[i].data[:])
		if ! sl.equal(bytes_a, bytes_b) do return false }
	return true }

relpath_to_path :: proc(relpath: string, allocator := context.allocator) -> (path: string) {
	base, _ := os.get_working_directory(allocator = allocator)
	path, _ = os.join_path({ base, relpath }, allocator = allocator)
	return path }

path_to_relpath :: proc(path: string, allocator := context.allocator) -> (relpath: string) {
	base, _ := os.get_working_directory(allocator = allocator)
	relpath, _ = os.get_relative_path(base, path, allocator = allocator)
	return relpath }

read :: proc(relpath: string, allocator := context.allocator) -> (database: Database) {
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
		url: []u8 = make([]u8, url_len)
		_, err = b.reader_read_slice(&reader, url); assert(err == nil)
		entry.url = cast(string)url
		_, err = b.reader_read_ptr(&reader, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		_, err = b.reader_read_ptr(&reader, &entry.compressed, size_of(entry.compressed)); assert(err == nil)
		data_len: u32
		_, err = b.reader_read_ptr(&reader, &data_len, size_of(data_len)); assert(err == nil)
		entry.data = make([]u8, data_len)
		_, err = b.reader_read_slice(&reader, entry.data); assert(err == nil)
		add_entry(&database, entry) }
	return database }

read_and_decompress :: proc(relpath: string, allocator := context.allocator) -> (database: Database) {
	database = read(relpath, allocator = allocator)
	decompress(&database, allocator = allocator)
	return database }

compress_and_write :: proc(database: ^Database, allocator := context.allocator) {
	compress(database, allocator = allocator)
	write(database, allocator = allocator) }

write :: proc(database: ^Database, allocator := context.allocator) {
	err: io.Error
	buffer: b.Buffer
	b.buffer_init_allocator(&buffer, 0, 32 * mem.Megabyte, allocator = allocator)
	binary_header: Database_Binary_Header = { magic_number = MAGIC_NUMBER, n_entries = cast(u32)len(database.entries) }
	_, err = b.buffer_write_ptr(&buffer, &binary_header, size_of(binary_header)); assert(err == nil)
	for &entry, i in database.entries {
		url_len: u8 = cast(u8)len(entry.url)
		_, err = b.buffer_write_ptr(&buffer, &url_len, size_of(url_len)); assert(err == nil)
		_, err = b.buffer_write_string(&buffer, entry.url); assert(err == nil)
		_, err = b.buffer_write_ptr(&buffer, &entry.modification_time, size_of(entry.modification_time)); assert(err == nil)
		_, err = b.buffer_write_ptr(&buffer, &entry.compressed, size_of(entry.compressed)); assert(err == nil)
		data_len: u32 = cast(u32)len(entry.data)
		_, err = b.buffer_write_ptr(&buffer, &data_len, size_of(data_len)); assert(err == nil)
		_, err = b.buffer_write_slice(&buffer, entry.data); assert(err == nil) }
	assert(os.write_entire_file_from_bytes(relpath_to_path(database.relpath, allocator), buffer.buf[:]) == nil) }

compress_bytes :: proc(bytes: []u8, allocator := context.allocator) -> (compressed_bytes: []u8) {
	compress_bound: i32 = lz4.compressBound(cast(i32)len(bytes))
	compressed_bytes_buffer: []u8 = make([]u8, cast(int)compress_bound, allocator)
	compressed_size: i32 = lz4.compress_default(&bytes[0], &compressed_bytes_buffer[0], cast(i32)len(bytes), compress_bound)
	assert(compressed_size != 0)
	compressed_bytes = sl.clone(compressed_bytes_buffer[0:compressed_size], allocator)
	delete(compressed_bytes_buffer, allocator)
	return compressed_bytes }

decompress_bytes :: proc(compressed_bytes: []u8, allocator := context.allocator) -> (bytes: []u8) {
	estimated_compression_ratio: f32 = 0.5
	for {
		decompress_bound: i32 = cast(i32)(cast(f32)len(compressed_bytes) / estimated_compression_ratio)
		bytes_buffer: []u8 = make([]u8, cast(int)decompress_bound, allocator)
		decompressed_size: i32 = lz4.decompress_safe(&compressed_bytes[0], &bytes_buffer[0], cast(i32)len(compressed_bytes), decompress_bound)
		if decompressed_size < 0 {
			// log.info("Decompress bound", decompress_bound, "not sufficient.")
			decompress_bound /= 2.0
			delete(bytes_buffer, allocator)
			continue }
		bytes = sl.clone(bytes_buffer[0:decompressed_size], allocator)
		delete(bytes_buffer, allocator)
		return bytes } }

compress :: proc(database: ^Database, allocator := context.allocator) {
	for &entry in database.entries do if ! entry.compressed {
		compress_data: []u8 = compress_bytes(entry.data, allocator = allocator)
		delete(entry.data, allocator = allocator)
		entry.data = compress_data
		entry.compressed = true } }

decompress :: proc(database: ^Database, allocator := context.allocator) {
	for &entry in database.entries do if entry.compressed {
		data: []u8 = decompress_bytes(entry.data, allocator = allocator)
		delete(entry.data, allocator = allocator)
		entry.data = data
		entry.compressed = false } }

url_join :: proc(urls: []string, allocator := context.allocator) -> string {
	return str.join(urls, sep = ":", allocator = allocator) }


