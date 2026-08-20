package oggun
import "core:os"
import "core:log"
import "core:strings"

String_Asset :: struct {
	using asset: Asset,
	str: string }

am_init_string_asset :: proc(this: ^String_Asset, config: Asset_Config) {
	config := config
	config.derived_type = String_Asset
	am_init_asset(String_Asset, &this.asset, config) }

am_string_op :: proc(base: ^Asset, op: Asset_Op, dest: Asset_Location = .None, src: Asset_Location = .None, arg: rawptr = nil, location := #caller_location) -> (ok: bool) {
	this := am_asset_base(base, String_Asset, "asset")
	ni: bool = false
	#partial switch op {
	case .Make:
		if dest == .RAM do this.str = (cast(^string)arg)^
		else do ni = true
	case .Delete: ni = true
	case .Initialize:
		if dest == .RAM do this.str = (cast(^string)arg)^
		else do ni = true
	case .Exists:
		#partial switch dest {
		case .Source:
			path := am_path_from_url(base.url, context.temp_allocator)
			return os.exists(path)
		case .RAM:
			return this.str != ""
		case .Database:
			return am_contains_entry(this.url)
		case: ni = true }
	case .Translate:
		vector: [2]Asset_Location = { src, dest }
		switch vector {
		case { .Source, .RAM }:
			if ! am_string_op(base, .Exists, src) do return false
			path := am_path_from_url(base.url, context.temp_allocator)
			bytes, err := os.read_entire_file_from_path(path, state.backing_allocator)
			this.str = cast(string)bytes
			return true
		case { .Database, .RAM }:
			if ! am_string_op(base, .Exists, src) {
				log.errorf("Failed to load string %s because it hasn't been imported.", base.url)
				return false }
			// err: os.Error
			// entry, existed := am_get_or_add_entry(asset.url)
			// if ! existed || am_entry_was_modified(entry) {
			// 	path := am_path_from_url(asset.url, context.temp_allocator)
			// 	bytes: []u8; bytes, err = os.read_entire_file_from_path(path, state.backing_allocator)
			// 	modification_time, _ := os.modification_time_by_path(path)
			// 	am_add_or_update_entry(am_make_entry(asset.url, bytes, modification_time))
			// 	assert(am_entry_integrity(entry)) }
			// if watch do if this.str == cast(string)entry.data do return true
			// this.str = strings.clone_from_bytes(entry.data, state.backing_allocator)
			return true }
	case: ni = true }
	if ni do am_error_not_implemented(op, dest, src, location)
	return false }

am_register_builtin_kinds :: proc() {
	am_register_asset_kind(String_Asset, { op = am_string_op }) }
