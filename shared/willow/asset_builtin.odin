package willow
import "core:os"
import "core:log"
import "core:strings"

String_Asset :: struct {
	using asset: Asset,
	str: string }

init_string_asset :: proc(asset_manager: ^Asset_Manager, string_asset: ^String_Asset, config: Asset_Config) {
	config := config
	config.derived_type = String_Asset
	init_asset(asset_manager, String_Asset, &string_asset.asset, config) }

string_asset_command :: proc(asset_manager: ^Asset_Manager, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	assert((asset_manager != nil) && (assert != nil))
	string_asset := asset_object(asset, String_Asset, "asset")
	switch command {
	case .Validate:
		urls: []string = url_split(asset.url, context.temp_allocator)
		return urls[0] == "string"
	case .Query_Location:
		path := path_from_url(asset_manager, asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
		return true
	case .Import:
		// There is a problem here: watch imports this every time
		if .Source_Directory not_in asset.location do return false
		err: os.Error
		entry, existed := get_or_add_entry(asset_manager, asset.url)
		if ! existed || entry_was_modified(asset_manager, entry) {
			path := path_from_url(asset_manager, asset.url, context.temp_allocator)
			bytes: []u8; bytes, err = os.read_entire_file_from_path(path, context.allocator)
			modification_time, _ := os.modification_time_by_path(path)
			add_or_update_entry(asset_manager, make_entry(asset.url, bytes, modification_time))
			assert(entry_integrity(entry)) }
		asset.location += { .Database }
		return true
	case .Load:
		if .Database not_in asset.location {
			log.errorf("Failed to load string %s because it hasn't been imported.", asset.url)
			return false }
		entry := get_entry(asset_manager, asset.url)
		if watch do if string_asset.str == cast(string)entry.data do return true
		string_asset.str = strings.clone_from_bytes(entry.data)
		asset.location += { .Main_Memory }
		return true
	case .Export, .Save, .Upload, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }

register_builtin_asset_kinds :: proc(asset_manager: ^Asset_Manager) {
	register_asset_kind(asset_manager, String_Asset, { command = string_asset_command }) }
