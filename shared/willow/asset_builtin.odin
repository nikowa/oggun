package willow
import "core:os"
import "core:log"
import "core:strings"

String_Asset :: struct {
	using asset: Asset,
	str: string }

init_string_asset :: proc(as_mngr: ^Asset_Manager, string_asset: ^String_Asset, config: Asset_Config) {
	config := config
	config.derived_type = String_Asset
	init_asset(as_mngr, String_Asset, &string_asset.asset, config)
	// (TODO): `init_asset` should execute `.Query_Location` by default.
	string_asset_command(as_mngr, &string_asset.asset, .Query_Location) }

// (NOTE): If the "watch" field is set, then the command is called by a watcher, and it should only be executed if the source
// location is outdated. For assets that do not implement outdatedness checking, the command should be ignored if "watch" is
// set.
string_asset_command :: proc(as_mngr: ^Asset_Manager, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	assert((as_mngr != nil) && (assert != nil))
	string_asset := asset_object(asset, String_Asset, "asset")
	switch command {
	case .Validate:
		urls: []string = url_split(asset.url, context.temp_allocator)
		return urls[0] == "string"
	case .Query_Location:
		path := path_from_url(&as_mngr.database, asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
		return true
	case .Import:
		// There is a problem here: watch imports this every time
		if .Source_Directory not_in asset.location do return false
		err: os.Error
		entry, existed := get_or_make_entry(&as_mngr.database, asset.url)
		if ! existed || entry_was_modified(&as_mngr.database, entry) {
			path := path_from_url(&as_mngr.database, asset.url, context.temp_allocator)
			bytes: []u8; bytes, err = os.read_entire_file_from_path(path, context.allocator)
			modification_time, _ := os.modification_time_by_path(path)
			_, err = add_or_update_entry(&as_mngr.database, make_entry(asset.url, bytes, modification_time), true)
			assert(entry_integrity(entry)) }
		asset.location += { .Database }
		return true
	case .Load:
		if .Database not_in asset.location {
			log.errorf("Failed to load string %s because it hasn't been imported.", asset.url)
			return false }
		entry := get_entry(&as_mngr.database, asset.url) or_return
		if watch do if string_asset.str == cast(string)entry.data do return true
		string_asset.str = strings.clone_from_bytes(entry.data)
		asset.location += { .Main_Memory }
		return true
	case .Export, .Save, .Upload, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }

register_builtin_asset_kinds :: proc(as_mngr: ^Asset_Manager) {
	register_asset_kind(as_mngr, String_Asset, { command = string_asset_command }) }
