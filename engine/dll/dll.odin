package dll
import intr "base:intrinsics"
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
	__handle: dl.Library,
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
	dll_object.__handle, ok = dl.load_library(dll_object.dll_relpath, allocator = context.temp_allocator)
	assert(ok)
	// _, ok = dl.initialize_symbols(&dll_object, dll_object.dll_relpath)
	if ! ok do return {}, os.General_Error.Not_Exist
	dll_object.modification_time, _ = os.modification_time_by_path(db.relpath_to_path(source_relpath, context.temp_allocator))
	return dll_object, os.General_Error.None }

compile_dll :: proc(source_relpath: string, dll_relpath: string) {
	command: []string = { "odin", "build", source_relpath, "-file", "-build-mode:dll", fmt.tprintf("-out:%s", dll_relpath) }
	process_desc: os.Process_Desc = {
		working_dir = "",
		command = command,
		stderr = nil,
		stdout = nil,
		stdin = nil }
	state, stdout, stderr, os_error: = os.process_exec(process_desc, context.temp_allocator)
	// log.info(cast(string)stdout, cast(string)stderr)
}

dll_was_modified :: proc(dll_object: ^$T) -> (was_modified: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	return db.file_was_modified(dll_object.base.source_relpath, &dll_object.base.modification_time) }

reload_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	log.infof("Reloading DLL %s.", dll_object.dll_relpath)
	assert(dl.unload_library(dll_object.__handle))
	dll_object.__handle = nil
	err := os.remove(dll_object.dll_relpath)
	compile_dll(dll_object.source_relpath, dll_object.dll_relpath)
	dll_object.__handle, ok = dl.load_library(dll_object.dll_relpath, allocator = context.temp_allocator)
	assert(ok)
	return ok }

watch_dll :: proc(dll_object: ^$T) -> (ok: bool) where intr.type_has_field(T, "base"), intr.type_field_type(T, "base") == DLL {
	if dll_was_modified(dll_object) do return reload_dll(dll_object)
	return false }

// load_dll :: proc(
// 	symbol_table: ^$T, library_path: string,
// 	symbol_prefix := "", handle_field_name := "__handle",
// ) -> (count: int = -1, ok: bool = false) where intrinsics.type_is_struct(T) {
// 	assert(symbol_table != nil)

// 	// First, (re)load the library.
// 	handle: Library
// 	for field in reflect.struct_fields_zipped(T) {
// 		if field.name == handle_field_name {
// 			field_ptr := rawptr(uintptr(symbol_table) + field.offset)

// 			// We appear to be hot reloading. Unload previous incarnation of the library.
// 			if old_handle := (^Library)(field_ptr)^; old_handle != nil {
// 				unload_library(old_handle) or_return
// 			}

// 			handle = load_library(library_path) or_return
// 			(^Library)(field_ptr)^ = handle
// 			break
// 		}
// 	}

// 	// No field for it in the struct.
// 	if handle == nil {
// 		handle = load_library(library_path) or_return
// 	}

// 	// Buffer to concatenate the prefix + symbol name.
// 	prefixed_symbol_buf: [2048]u8 = ---

// 	count = 0
// 	for field in reflect.struct_fields_zipped(T) {
// 		// If we're not the library handle, the field needs to be a pointer type, be it a procedure pointer or an exported global.
// 		if field.name == handle_field_name || !(reflect.is_procedure(field.type) || reflect.is_pointer(field.type)) {
// 			continue
// 		}

// 		// Calculate address of struct member
// 		field_ptr := rawptr(uintptr(symbol_table) + field.offset)

// 		// Let's look up or construct the symbol name to find in the library
// 		prefixed_name: string

// 		// Do we have a symbol override tag?
// 		if override, tag_ok := reflect.struct_tag_lookup(field.tag, "dynlib"); tag_ok {
// 			prefixed_name = override
// 		}

// 		// No valid symbol override tag found, fall back to `<symbol_prefix>name`.
// 		if len(prefixed_name) == 0 {
// 			offset := copy(prefixed_symbol_buf[:], symbol_prefix)
// 			copy(prefixed_symbol_buf[offset:], field.name)
// 			prefixed_name = string(prefixed_symbol_buf[:len(symbol_prefix) + len(field.name)])
// 		}

// 		// Assign procedure (or global) pointer if found.
// 		sym_ptr := symbol_address(handle, prefixed_name) or_continue
// 		(^rawptr)(field_ptr)^ = sym_ptr
// 		count += 1
// 	}
// 	return count, count > 0
// }
