package willow
import "base:intrinsics"
import "core:reflect"
import "core:fmt"
import "core:time"
import "core:os"
import "core:dynlib"
import "core:log"
import "core:path/slashpath"

DL :: struct {
	lib: dynlib.Library,
	source_relpath: string,
	dll_relpath: string,
	temp_dll_relpath: string,
	modification_time: time.Time }

dl_make :: proc($T: typeid, source_relpath: string) -> (dll_object: T, err: os.Error) where intrinsics.type_has_field(T, "base"), intrinsics.type_field_type(T, "base") == DL {
	name, dir: string
	ok: bool

	source_path := relpath_to_path(source_relpath, context.temp_allocator)
	if ! os.exists(source_path) do return {}, os.General_Error.Not_Exist
	dll_object.source_relpath = source_relpath
	name = slashpath.name(source_relpath, allocator = context.temp_allocator)
	dir = slashpath.dir(source_relpath, context.temp_allocator)
	dll_object.dll_relpath = os.join_path({ dir, os.join_filename(name, "dll", context.temp_allocator) or_return }, context.allocator) or_return
	// log.errorf("dll_relpath: %s", dll_object.dll_relpath)
	dll_object.temp_dll_relpath = os.join_path({ dir, os.join_filename(fmt.tprintf("%s-temp", name), "dll", context.temp_allocator) or_return }, context.allocator) or_return
	dll_path := relpath_to_path(dll_object.dll_relpath, context.temp_allocator)
	dl_compile(source_path, dll_path) or_return
	ok = _dl_load(&dll_object)
	if ! ok do return {}, os.General_Error.Not_Exist
	dll_object.modification_time, _ = os.modification_time_by_path(source_path)
	return dll_object, os.General_Error.None }

dl_compile :: proc(source_path: string, dll_path: string) -> (err: os.Error) {
	old_modification_time, new_modification_time: time.Time

	// log.infof("Compiling DL %s %s.", source_path, dll_path)
	if os.exists(dll_path) do old_modification_time = os.modification_time_by_path(dll_path) or_return
	command: []string = { "odin", "build", source_path, "-file", "-build-mode:dll", fmt.tprintf("-out:%s", dll_path) }
	process_desc: os.Process_Desc = { working_dir = "", command = command }
	state, stdout, stderr, os_error: = os.process_exec(process_desc, context.temp_allocator)
	if ! os.exists(dll_path) {
		log.errorf("Odin failed to compile DL: \n%s%s", stdout, stderr)
		return os.General_Error.Invalid_File }
	if ! os.exists(dll_path) do err = os.General_Error.Invalid_File
	else {
		new_modification_time, err = os.modification_time_by_path(dll_path)
		if time.diff(old_modification_time, new_modification_time) == 0 do err = os.General_Error.Invalid_File }
	if err != os.General_Error.None {
		log.errorf("Odin failed to compile DL: \n%s%s", stdout, stderr)
		return os.General_Error.Invalid_File }
	return os.General_Error.None }

dl_modified :: proc(dll_object: ^$T) -> (was_modified: bool) where intrinsics.type_has_field(T, "base"), intrinsics.type_field_type(T, "base") == DL {
	return file_was_modified(dll_object.base.source_relpath, &dll_object.base.modification_time) }

dl_reload :: proc(dll_object: ^$T) -> (err: os.Error) where intrinsics.type_has_field(T, "base"), intrinsics.type_field_type(T, "base") == DL {
	source_path := relpath_to_path(dll_object.source_relpath, context.temp_allocator)
	temp_dll_path := relpath_to_path(dll_object.temp_dll_relpath, context.temp_allocator)
	// log.infof("Reloading DL %s | %s | %s.", dll_object.dll_relpath, dll_object.source_relpath, dll_object.temp_dll_relpath)
	err = dl_compile(source_path, temp_dll_path)
	if err != nil {
		log.errorf("Failed to compile DL: %v", err)
		return err }
	dynlib.unload_library(dll_object.lib)
	assert(remove_file(dll_object.dll_relpath, context.temp_allocator) == nil)
	assert(rename_file(dll_object.temp_dll_relpath, dll_object.dll_relpath, context.temp_allocator) == nil)
	dll_object.lib = nil
	if ! _dl_load(dll_object) do return os.General_Error.Invalid_File
	return os.General_Error.None }

dl_watch :: proc(dll_object: ^$T) -> (ok: bool) where intrinsics.type_has_field(T, "base"), intrinsics.type_field_type(T, "base") == DL {
	if dl_modified(dll_object) do return dl_reload(dll_object) == nil
	return false }

_dl_load :: proc(dll_object: ^$T) -> (ok: bool) where intrinsics.type_has_field(T, "base"), intrinsics.type_field_type(T, "base") == DL {
	dll_object.base.lib = dynlib.load_library(relpath_to_path(dll_object.base.dll_relpath, context.temp_allocator)) or_return
	for field in reflect.struct_fields_zipped(T) {
		if field.name == "lib" || !(reflect.is_procedure(field.type) || reflect.is_pointer(field.type)) do continue
		sym_ptr := dynlib.symbol_address(dll_object.base.lib, field.name) or_continue
		(^rawptr)(rawptr(uintptr(dll_object) + field.offset))^ = sym_ptr }
	return true }
