package willow
import "base:runtime"
import "core:os"
import "core:strings"
import "core:time"
import "core:path/slashpath"

relpath_to_path :: proc(relpath: string, allocator: runtime.Allocator) -> (path: string) {
	base, _ := os.get_executable_directory(allocator = allocator)
	path, _ = os.join_path({ base, relpath }, allocator = allocator)
	return path }

path_to_relpath :: proc(path: string, allocator: runtime.Allocator) -> (relpath: string) {
	base, _ := os.get_executable_directory(allocator = allocator)
	relpath, _ = os.get_relative_path(base, path, allocator = allocator)
	return relpath }

file_was_modified :: proc(relpath: string, modification_time: ^time.Time) -> (was_modified: bool) {
	path := relpath_to_path(relpath, context.temp_allocator)
	if ! os.exists(path) do return false
	current_modification_time, _ := os.modification_time_by_path(path)
	if time.diff(modification_time^, current_modification_time) <= 0 do return false
	modification_time^ = current_modification_time
	return true }

search_file_by_name :: proc(directory_relpath: string, file_name: string, allocator: runtime.Allocator) -> (path: string) {
	directory_path := relpath_to_path(directory_relpath, context.temp_allocator)
	if ! os.exists(directory_path) do return ""
	file_infos, _ := os.read_directory_by_path(directory_path, -1, context.temp_allocator)
	for file_info in file_infos do if slashpath.name(file_info.name, false, context.temp_allocator) == file_name do return strings.clone(file_info.fullpath, allocator)
	return "" }

remove_file :: proc(relpath: string, allocator: runtime.Allocator) -> (err: os.Error)  {
	return os.remove(relpath_to_path(relpath, allocator)) }

rename_file :: proc(old_relpath: string, new_relpath: string, allocator: runtime.Allocator) -> (err: os.Error) {
	return os.rename(relpath_to_path(old_relpath, allocator), relpath_to_path(new_relpath, allocator)) }
