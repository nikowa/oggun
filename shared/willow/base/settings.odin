#+feature using-stmt
package base
import "base:runtime"
import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:encoding/ini"

Settings_Manager :: struct {
	settings_path: string,
	_map: map[string]map[string]string }

init_settings_manager :: proc(settings: ^Settings_Manager, application_name: string) {
	settings.settings_path, _ = os.join_path({ os.user_data_dir(context.temp_allocator) or_else "", application_name }, context.allocator)
	if ! os.exists(settings.settings_path) do assert(os.make_directory(settings.settings_path) == nil)
	settings._map = make_map(map[string]map[string]string, context.allocator) }

settings_manager_write :: proc(settings: ^Settings_Manager, value: ^$Type) where intrinsics.type_is_struct(Type) {
	type_info_named := type_info_of(Type).variant.(runtime.Type_Info_Named)
	section_name := type_info_named.name
	if section_name not_in settings._map do map_insert(&settings._map, section_name, make_map(map[string]string, context.allocator))
	section := &settings._map[section_name]
	type_info_struct := type_info_named.base.variant.(runtime.Type_Info_Struct)
	for type_info, i in type_info_struct.types[:type_info_struct.field_count] {
		#partial switch variant in type_info.variant {
		case runtime.Type_Info_Boolean:
			key: string = type_info_struct.names[i]
			value: bool = (cast(^bool)(uintptr(value) + type_info_struct.offsets[i]))^
			section[key] = fmt.aprintf("%t", value)
		}
	}
	fmt.println(settings)
}

@(deprecated="'settings_manager_read' is not implemented.")
settings_manager_read :: proc(settings: ^Settings_Manager, value: ^$Type) where intrinsics.type_is_struct(Type) {
}

@(deprecated="'settings_manager_export' is not implemented.")
settings_manager_export :: proc(settings: ^Settings_Manager) {
}

@(deprecated="'settings_manager_import' is not implemented.")
settings_manager_import :: proc(settings: ^Settings_Manager) {
}

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
