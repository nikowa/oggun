#+feature using-stmt
package base
import "core:fmt"
import os "core:os"

/*
Cache :: struct {
	files: map[string]Maybe([]u8) }


cache_init :: proc(cache: ^Cache) {
	cache_directory_path: string
	files:                []os.File_Info
	error:                os.Error

	cache.files = make_map(map[string]Maybe([]u8))
	cache_directory_path, error = os.join_path({ working_directory_path, "data", "cache" }, context.allocator)
	assert(error == nil)
	fmt.printfln("%s Cache directory path: %s.", LOG, cache_directory_path)
	files, error = os.read_directory_by_path(cache_directory_path, 0, context.allocator)
	assert(error == nil)
	for file in files {
		if file.type != .Regular do continue
		fmt.printfln("%s Adding %s to cache.", LOG, file.name)
		cache.files[file.name] = nil } }


cache_write :: proc(filename: string, data: []u8) {
	filepath: string
	error:    os.Error

	filepath, error = os.join_path({ working_directory_path, "data", "cache", filename }, context.allocator)
	assert(error == nil)
	error = os.write_entire_file_from_bytes(filepath, data)
	assert(error == nil) }

*/