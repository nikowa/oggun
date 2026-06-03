package willow
import "core:os"
import "core:log"
import "core:strings"

String_Asset :: struct {
	using asset: Asset,
	str: string }

am_init_string_asset :: proc(string_asset: ^String_Asset, config: Asset_Config) {
	config := config
	config.derived_type = String_Asset
	am_init_asset(String_Asset, &string_asset.asset, config) }

am_string_command :: proc(asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	string_asset := am_asset_base(asset, String_Asset, "asset")
	switch command {
	case .Validate:
		urls: []string = am_url_split(asset.url, context.temp_allocator)
		return urls[0] == "string"
	case .Query_Location:
		path := am_path_from_url(asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
		return true
	case .Import:
		// There is a problem here: watch imports this every time
		// TEMP
		// context.allocator = engine.backing_allocator
		if .Source_Directory not_in asset.location do return false
		err: os.Error
		entry, existed := am_get_or_add_entry(asset.url)
		if ! existed || am_entry_was_modified(entry) {
			path := am_path_from_url(asset.url, context.temp_allocator)
			bytes: []u8; bytes, err = os.read_entire_file_from_path(path, context.allocator)
			modification_time, _ := os.modification_time_by_path(path)
			am_add_or_update_entry(am_make_entry(asset.url, bytes, modification_time))
			assert(am_entry_integrity(entry)) }
		asset.location += { .Database }
		return true
	case .Load:
		// TEMP
		// context.allocator = engine.backing_allocator
		if .Database not_in asset.location {
			log.errorf("Failed to load string %s because it hasn't been imported.", asset.url)
			return false }
		entry := am_get_entry(asset.url)
		if watch do if string_asset.str == cast(string)entry.data do return true
		string_asset.str = strings.clone_from_bytes(entry.data)
		asset.location += { .Main_Memory }
		return true
	case .Export, .Save, .Upload, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }

am_register_builtin_kinds :: proc() {
	am_register_asset_kind(String_Asset, { command = am_string_command }) }
