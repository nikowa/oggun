package dll
import intr "base:intrinsics"
import tm "core:time"
import os "core:os"
import dl "core:dynlib"
import db "../database"



DLL :: struct {
	lib: dl.Library,
	relpath: string,
	modification_time: tm.Time }

make_dll :: proc($T: typeid, relpath: string) -> (dll_object: T, ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	if ! os.exists(relpath) do return {}, false
	dll_object.relpath = relpath
	_, ok = dl.initialize_symbols(&dll_object, dll_object.relpath, handle_field_name = "lib")
	dll_object.modification_time, _ = os.modification_time_by_path(db.relpath_to_path(relpath, context.temp_allocator))
	return dll_object, true }

dll_was_modified :: proc(dll_object: ^$T) -> (was_modified: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	return db.file_was_modified(dll_object.base.relpath, &dll_object.base.modification_time) }

reload_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	_, ok = dl.initialize_symbols(dll_object, dll_object.relpath, handle_field_name = "lib")
	return ok }

watch_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	if dll_was_modified(dll_object) do return reload_dll(dll_object)
	return false }
