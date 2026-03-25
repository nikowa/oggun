package asset_manager
import fmt "core:fmt"
import rt "base:runtime"
import tm "core:time"
import os "core:os"
import b "core:bytes"
import mem "core:mem"
import io "core:io"
import sl "core:slice"
import lz4 "vendor:compress/lz4"
import log "core:log"
import str "core:strings"
import base "../base"
import sp "core:path/slashpath"



String_Asset :: struct {
	using asset: Asset,
	str: string }

init_string_asset :: proc(manager: ^Asset_Manager, string_asset: ^String_Asset, config: Asset_Config) {
	init_asset(manager, &string_asset.asset, config)
	string_asset_command(manager, &string_asset.asset, .Query_Location) }

// (NOTE): If the "watch" field is set, then the command is called by a watcher, and it should only be executed if the source
// location is outdated. For assets that do not implement outdatedness checking, the command should be ignored if "watch" is
// set.
string_asset_command :: proc(manager: ^Asset_Manager, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	assert((manager != nil) && (assert != nil))
	string_asset := asset_object(asset, String_Asset, "asset")
	switch command {
	case .Validate:
		urls: []string = url_split(asset.url, context.temp_allocator)
		return urls[0] == "string"
	case .Query_Location:
		path := path_from_url(&manager.database, asset.url, context.temp_allocator)
		if os.exists(path) do asset.location += { .Source_Directory }
	case .Import:
		if watch do return true
		if .Source_Directory not_in asset.location do return false
		err: os.Error
		entry, ok := entry_from_url(&manager.database, asset.url)
		if ! ok || entry_was_modified(&manager.database, entry) || manager.database.spec_modified {
			path := path_from_url(&manager.database, asset.url, context.temp_allocator)
			bytes: []u8; bytes, err = os.read_entire_file_from_path(path, context.allocator)
			modification_time, _ := os.modification_time_by_path(path)
			_, err = add_or_update_entry(&manager.database, make_entry(asset.url, bytes, modification_time), true) }
		asset.location += { .Database }
		return true
	case .Load:
		if .Database not_in asset.location do return false
		entry := entry_from_url(&manager.database, asset.url) or_return
		string_asset.str = str.clone_from_bytes(entry.data)
		asset.location += { .Main_Memory }
		return true
	case .Initialize, .Export, .Read, .Write, .Save, .Upload, .Download:
		log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }

register_builtin_asset_kinds :: proc(manager: ^Asset_Manager) {
	register_asset_kind(manager, String_Asset, { command = string_asset_command }) }
