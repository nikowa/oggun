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



Asset_Manager_Config :: Database_Config

Asset_Manager :: struct {
	using database: Database,
	asset_kinds: map[typeid]Asset_Kind }

Asset_Command :: enum {
	Validate,
	Initialize,
	Query_Location,
	Import,
	Export,
	Read,
	Write,
	Load,
	Save,
	Upload,
	Download }

Asset_Location :: bit_set[Asset_Location_Field]

Asset_Location_Field :: enum {
	Source_Directory,
	Database_File,
	Database,
	Main_Memory,
	GPU_Memory }

Asset_Command_Proc :: #type proc(manager: ^Asset_Manager, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool)

Asset_Config :: struct {
	url: URL }

Asset :: struct {
	using asset_config: Asset_Config,
	location: Asset_Location }

Asset_Kind :: struct {
	command_proc: Asset_Command_Proc }

make_asset :: proc(config: Asset_Config) -> Asset {
	return { asset_config = config } }

asset_object :: proc(asset: ^Asset, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(asset) - offset) }

make_asset_manager :: proc(config: Asset_Manager_Config, allocator: rt.Allocator) -> (asset_manager: Asset_Manager) {
	asset_manager.database = make_or_read_database(config, allocator)
	asset_manager.asset_kinds = make(map[typeid]Asset_Kind, allocator)
	register_builtin_asset_kinds(&asset_manager)
	return asset_manager }

register_asset_kind :: proc(manager: ^Asset_Manager, type: typeid, kind: Asset_Kind) {
	manager.asset_kinds[type] = kind }
