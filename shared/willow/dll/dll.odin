package dll
import intr "base:intrinsics"
import rl "core:reflect"
import fmt "core:fmt"
import tm "core:time"
import os "core:os"
import dl "core:dynlib"
import sp "core:path/slashpath"
import fm "core:fmt"
import str "core:strings"
import log "core:log"
import "../asset_manager"

DLL :: struct {
	lib: dl.Library,
	source_relpath: string,
	dll_relpath: string,
	temp_dll_relpath: string,
	modification_time: tm.Time }

make_dll :: proc($T: typeid, source_relpath: string) -> (dll_object: T, err: os.Error) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	name, dir: string
	ok: bool

	source_path := asset_manager.relpath_to_path(source_relpath, context.temp_allocator)
	if ! os.exists(source_path) do return {}, os.General_Error.Not_Exist
	dll_object.source_relpath = source_relpath
	name = sp.name(source_relpath, allocator = context.temp_allocator)
	dir = sp.dir(source_relpath, context.temp_allocator)
	dll_object.dll_relpath = os.join_path({ dir, os.join_filename(name, "dll", context.temp_allocator) or_return }, context.allocator) or_return
	// log.errorf("dll_relpath: %s", dll_object.dll_relpath)
	dll_object.temp_dll_relpath = os.join_path({ dir, os.join_filename(fmt.tprintf("%s-temp", name), "dll", context.temp_allocator) or_return }, context.allocator) or_return
	dll_path := asset_manager.relpath_to_path(dll_object.dll_relpath, context.temp_allocator)
	compile_dll(source_path, dll_path) or_return
	ok = _load_dll(&dll_object)
	if ! ok do return {}, os.General_Error.Not_Exist
	dll_object.modification_time, _ = os.modification_time_by_path(source_path)
	return dll_object, os.General_Error.None }

compile_dll :: proc(source_path: string, dll_path: string) -> (err: os.Error) {
	old_modification_time, new_modification_time: tm.Time

	// log.infof("Compiling DLL %s %s.", source_path, dll_path)
	if os.exists(dll_path) do old_modification_time = os.modification_time_by_path(dll_path) or_return
	command: []string = { "odin", "build", source_path, "-file", "-build-mode:dll", fmt.tprintf("-out:%s", dll_path) }
	process_desc: os.Process_Desc = { working_dir = "", command = command }
	state, stdout, stderr, os_error: = os.process_exec(process_desc, context.temp_allocator)
	if ! os.exists(dll_path) {
		log.errorf("Odin failed to compile DLL: \n%s%s", stdout, stderr)
		return os.General_Error.Invalid_File }
	if ! os.exists(dll_path) do err = os.General_Error.Invalid_File
	else {
		new_modification_time, err = os.modification_time_by_path(dll_path)
		if tm.diff(old_modification_time, new_modification_time) == 0 do err = os.General_Error.Invalid_File }
	if err != os.General_Error.None {
		log.errorf("Odin failed to compile DLL: \n%s%s", stdout, stderr)
		return os.General_Error.Invalid_File }
	return os.General_Error.None }

dll_was_modified :: proc(dll_object: ^$T) -> (was_modified: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	return asset_manager.file_was_modified(dll_object.base.source_relpath, &dll_object.base.modification_time) }

reload_dll :: proc(dll_object: ^$T) -> (err: os.Error) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	source_path := asset_manager.relpath_to_path(dll_object.source_relpath, context.temp_allocator)
	temp_dll_path := asset_manager.relpath_to_path(dll_object.temp_dll_relpath, context.temp_allocator)
	// log.infof("Reloading DLL %s | %s | %s.", dll_object.dll_relpath, dll_object.source_relpath, dll_object.temp_dll_relpath)
	err = compile_dll(source_path, temp_dll_path)
	if err != nil {
		log.errorf("Failed to compile DLL: %v", err)
		return err }
	dl.unload_library(dll_object.lib)
	assert(asset_manager.remove_file(dll_object.dll_relpath, context.temp_allocator) == nil)
	assert(asset_manager.rename_file(dll_object.temp_dll_relpath, dll_object.dll_relpath, context.temp_allocator) == nil)
	dll_object.lib = nil
	if ! _load_dll(dll_object) do return os.General_Error.Invalid_File
	return os.General_Error.None }

watch_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	if dll_was_modified(dll_object) do return reload_dll(dll_object) == nil
	return false }

_load_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	dll_object.base.lib = dl.load_library(asset_manager.relpath_to_path(dll_object.base.dll_relpath, context.temp_allocator)) or_return
	for field in rl.struct_fields_zipped(T) {
		if field.name == "lib" || !(rl.is_procedure(field.type) || rl.is_pointer(field.type)) do continue
		sym_ptr := dl.symbol_address(dll_object.base.lib, field.name) or_continue
		(^rawptr)(rawptr(uintptr(dll_object) + field.offset))^ = sym_ptr }
	return true }
