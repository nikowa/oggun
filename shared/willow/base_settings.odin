#+feature using-stmt
package willow
import "base:runtime"
import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:encoding/ini"
import "core:log"
import "core:strconv"
import "core:strings"
import "core:slice"

Settings_Manager :: struct {
	path: string,
	_map: map[string]map[string]string }

settings_manager_init :: proc(settings_manager: ^Settings_Manager, application_name: string, settings_name: string) {
	directory_path, _ := os.join_path({ os.user_data_dir(context.temp_allocator) or_else "", application_name }, context.temp_allocator)
	if ! os.exists(directory_path) do assert(os.make_directory(directory_path) == nil)
	path_base, _ := os.join_path({ directory_path, settings_name }, context.temp_allocator)
	settings_manager.path, _ = os.join_filename(path_base, "ini", context.allocator)
	// log.infof("Settings path: %s.", settings_manager.path)
	settings_manager._map = make_map(map[string]map[string]string, context.allocator) }

@private slice_to_string :: proc(slice: []$T) -> string {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, 1000)
	for x, i in slice do if i < len(slice) - 1 do fmt.sbprintf(&builder, "%v, " when T != f32 else "%.6f, ", x)
	else do fmt.sbprintf(&builder, "%v" when T != f32 else "%.6f", x)
	return strings.to_string(builder) }

@private bool_to_string :: proc(value: bool) -> string { return fmt.aprintf("%t", value) }

@private i32_to_string :: proc(value: i32) -> string { return fmt.aprintf("%d", value) }

@private u32_to_string :: proc(value: u32) -> string { return fmt.aprintf("%d", value) }

@private int_to_string :: proc{ i32_to_string, u32_to_string }

@private f32_to_string :: proc(value: f32) -> string { return fmt.aprintf("%.6f", value) }

@private string_to_bool :: proc(source: string) -> bool { value, _ := strconv.parse_bool(source); return value }

@private string_to_i32 :: proc(source: string) -> i32 { value, _ := strconv.parse_int(source); return cast(i32)value }

@private string_to_u32 :: proc(source: string) -> u32 { value, _ := strconv.parse_uint(source); return cast(u32)value }

@private string_to_f32 :: proc(source: string) -> f32 { value, _ := strconv.parse_f32(source); return cast(f32)value }

settings_manager_write :: proc(settings_manager: ^Settings_Manager, settings: ^$Type) where intrinsics.type_is_struct(Type) {
	type_info_named := type_info_of(Type).variant.(runtime.Type_Info_Named)
	section_name := type_info_named.name
	if section_name not_in settings_manager._map do map_insert(&settings_manager._map, section_name, make_map(map[string]string, context.allocator))
	section := &settings_manager._map[section_name]
	type_info_struct := type_info_named.base.variant.(runtime.Type_Info_Struct)
	for type_info, i in type_info_struct.types[:type_info_struct.field_count] {
		key: string = type_info_struct.names[i]
		field_ptr: rawptr = rawptr(uintptr(settings) + type_info_struct.offsets[i])
		#partial switch variant in type_info.variant {
		case runtime.Type_Info_Boolean: section[key] = bool_to_string((cast(^bool)field_ptr)^)
		case runtime.Type_Info_Integer:
			if variant.signed do section[key] = int_to_string((cast(^i32)field_ptr)^)
			else do section[key] = int_to_string((cast(^u32)field_ptr)^)
		case runtime.Type_Info_Float: section[key] = f32_to_string((cast(^f32)field_ptr)^)
		case runtime.Type_Info_String: section[key] = strings.clone((cast(^string)field_ptr)^)
		case runtime.Type_Info_Array:
			#partial switch elem_variant in variant.elem.variant {
			case runtime.Type_Info_Integer:
				if elem_variant.signed do section[key] = slice_to_string(slice.from_ptr(cast([^]i32)field_ptr, variant.count))
				else do section[key] = slice_to_string(slice.from_ptr(cast([^]u32)field_ptr, variant.count))
			case runtime.Type_Info_Float: section[key] = slice_to_string(slice.from_ptr(cast([^]f32)field_ptr, variant.count))
			case runtime.Type_Info_String: section[key] = slice_to_string(slice.from_ptr(cast([^]string)field_ptr, variant.count))
			}
} } }

settings_verify :: proc(value: ^$Type) -> bool where intrinsics.type_is_struct(Type) {
	type_info_named := type_info_of(Type).variant.(runtime.Type_Info_Named)
	type_info_struct := type_info_named.base.variant.(runtime.Type_Info_Struct)
	for type_info, i in type_info_struct.types[:type_info_struct.field_count] do #partial switch variant in type_info.variant {
		case runtime.Type_Info_Boolean, runtime.Type_Info_String: continue
		case runtime.Type_Info_Integer, runtime.Type_Info_Float: if type_info.size != 4 do return false
		case runtime.Type_Info_Array:
			#partial switch elem_variant in variant.elem.variant {
			case runtime.Type_Info_Boolean, runtime.Type_Info_String: continue
			case runtime.Type_Info_Integer, runtime.Type_Info_Float: if variant.elem.size != 4 do return false
			case: return false }
		case: return false }
	return true }

settings_manager_log :: proc(settings: ^Settings_Manager) {
	data := ini.save_map_to_string(cast(ini.Map)settings._map, context.temp_allocator)
	log.infof("\n%s", data) }

settings_manager_read :: proc(settings_manager: ^Settings_Manager, settings: ^$Type) where intrinsics.type_is_struct(Type) {
	type_info_named := type_info_of(Type).variant.(runtime.Type_Info_Named)
	section_name := type_info_named.name
	section, ok := settings_manager._map[section_name]; if ! ok do return
	type_info_struct := type_info_named.base.variant.(runtime.Type_Info_Struct)
	for type_info, i in type_info_struct.types[:type_info_struct.field_count] {
		key: string = type_info_struct.names[i]
		field_ptr: rawptr = rawptr(uintptr(settings) + type_info_struct.offsets[i])
		#partial switch variant in type_info.variant {
		case runtime.Type_Info_Boolean: (cast(^bool)field_ptr)^ = string_to_bool(section[key])
		case runtime.Type_Info_Integer:
			if variant.signed do (cast(^i32)field_ptr)^ = string_to_i32(section[key])
			else do (cast(^u32)field_ptr)^ = string_to_u32(section[key])
		case runtime.Type_Info_Float: (cast(^f32)field_ptr)^ = string_to_f32(section[key])
		case runtime.Type_Info_String: (cast(^string)field_ptr)^ = strings.clone(section[key])
		case runtime.Type_Info_Array:
			elem_strings: []string = strings.split(section[key], ",")
			#partial switch elem_variant in variant.elem.variant {
			case runtime.Type_Info_Integer:
				if elem_variant.signed {
					array := (cast([^]i32)field_ptr)
					for i in 0 ..< min(len(elem_strings), variant.count) do array[i] = string_to_i32(strings.trim_space(elem_strings[i])) }
				else {
					array := (cast([^]u32)field_ptr)
					for i in 0 ..< min(len(elem_strings), variant.count) do array[i] = string_to_u32(strings.trim_space(elem_strings[i])) }
			case runtime.Type_Info_Float:
					array := (cast([^]f32)field_ptr)
					for i in 0 ..< min(len(elem_strings), variant.count) do array[i] = string_to_f32(strings.trim_space(elem_strings[i]))
			case runtime.Type_Info_String:
					array := (cast([^]string)field_ptr)
					for i in 0 ..< min(len(elem_strings), variant.count) do array[i] = strings.clone(strings.trim_space(elem_strings[i])) } } } }

settings_manager_export :: proc(settings_manager: ^Settings_Manager) {
	data := ini.save_map_to_string(cast(ini.Map)settings_manager._map, context.temp_allocator)
	_ = os.write_entire_file(settings_manager.path, data) }

settings_manager_import :: proc(settings_manager: ^Settings_Manager) {
	data, err := os.read_entire_file(settings_manager.path, context.allocator)
	settings_map, _ := ini.load_map_from_string(string(data), context.allocator)
	settings_manager._map = auto_cast settings_map }

/*
Graphics_Settings_Manager :: struct {
	environment_quality: Quality_Setting,
	lighting_quality:    Quality_Setting,
	effects_quality:     Quality_Setting,
	fullscreen:          bool,
	resolution:          [2]int,
	resolution_scale:    Resolution_Scale_Setting,
	fps_limit:           Tickrate_Config }

Quality_Setting :: enum { LOW, MEDIUM, HIGH }
Resolution_Scale_Setting :: enum { PERCENT_25, PERCENT_50, PERCENT_100, PERCENT_200, PERCENT_400 }

settings_default :: proc(settings: ^Settings_Manager) {
	settings.graphics = {
		environment_quality = .HIGH,
		lighting_quality    = .HIGH,
		effects_quality     = .HIGH,
		fullscreen          = false,
		resolution          = { 1920, 960 },
		resolution_scale    = .PERCENT_100,
		fps_limit           = .LIMITED_120_FPS } }

*/
