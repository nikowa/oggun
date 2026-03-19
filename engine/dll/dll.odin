package dll
import intr "base:intrinsics"
import rl "core:reflect"
import fmt "core:fmt"
import tm "core:time"
import os "core:os"
import dl "core:dynlib"
import sp "core:path/slashpath"
import fm "core:fmt"
import libc "core:c/libc"
import str "core:strings"
import log "core:log"
import db "../database"



DLL :: struct {
	lib: dl.Library,
	source_relpath: string,
	dll_relpath: string,
	modification_time: tm.Time }

make_dll :: proc($T: typeid, source_relpath: string) -> (dll_object: T, err: os.Error) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	name, dir: string
	ok: bool

	if ! os.exists(source_relpath) do return {}, os.General_Error.Not_Exist
	dll_object.source_relpath = source_relpath
	name = sp.name(source_relpath, allocator = context.temp_allocator)
	dir = sp.dir(source_relpath, context.temp_allocator)
	dll_object.dll_relpath = os.join_path({ dir, os.join_filename(name, "dll", context.temp_allocator) or_return }, context.temp_allocator) or_return
	compile_dll(dll_object.source_relpath, dll_object.dll_relpath)
	ok = load_dll(&dll_object)
	if ! ok do return {}, os.General_Error.Not_Exist
	dll_object.modification_time, _ = os.modification_time_by_path(db.relpath_to_path(source_relpath, context.temp_allocator))
	return dll_object, os.General_Error.None }

compile_dll :: proc(source_relpath: string, dll_relpath: string) {
	command: []string = { "odin", "build", source_relpath, "-file", "-build-mode:dll", fmt.tprintf("-out:%s", dll_relpath) }
	process_desc: os.Process_Desc = { working_dir = "", command = command }
	state, stdout, stderr, os_error: = os.process_exec(process_desc, context.temp_allocator) }

dll_was_modified :: proc(dll_object: ^$T) -> (was_modified: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	return db.file_was_modified(dll_object.base.source_relpath, &dll_object.base.modification_time) }

reload_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	log.infof("Reloading DLL %s.", dll_object.dll_relpath)
	dl.unload_library(dll_object.lib) or_return
	dll_object.lib = nil
	err := os.remove(dll_object.dll_relpath)
	compile_dll(dll_object.source_relpath, dll_object.dll_relpath)
	load_dll(dll_object) or_return
	return true }

watch_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	if dll_was_modified(dll_object) do return reload_dll(dll_object)
	return false }

load_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	dll_object.base.lib = dl.load_library(dll_object.base.dll_relpath) or_return
	for field in rl.struct_fields_zipped(T) {
		if field.name == "lib" || !(rl.is_procedure(field.type) || rl.is_pointer(field.type)) do continue
		sym_ptr := dl.symbol_address(dll_object.base.lib, field.name) or_continue
		(^rawptr)(rawptr(uintptr(dll_object) + field.offset))^ = sym_ptr }
	return true }
