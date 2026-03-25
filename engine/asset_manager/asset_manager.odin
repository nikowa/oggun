package asset_manager
import intr "base:intrinsics"
import rt "base:runtime"
import fmt "core:fmt"
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
	assets: [dynamic]^Asset,
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
	url: URL,
	derived_type: typeid }

Asset :: struct {
	using asset_config: Asset_Config,
	location: Asset_Location }

Asset_Kind :: struct {
	command: Asset_Command_Proc }

asset_command :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	assert(Asset_Type in manager.asset_kinds)
	asset_kind := manager.asset_kinds[Asset_Type]
	when ODIN_DEBUG do asset_kind.command(manager, asset, .Validate, false)
	return asset_kind.command(manager, asset, command, watch) }

init_asset :: proc(manager: ^Asset_Manager, asset: ^Asset, config: Asset_Config) {
	asset.asset_config = config
	append(&manager.assets, asset) }

asset_object :: proc(asset: ^Asset, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(asset) - offset) }

make_asset_manager :: proc(config: Asset_Manager_Config, allocator: rt.Allocator) -> (asset_manager: Asset_Manager) {
	asset_manager.database = make_or_read_database(config, allocator)
	asset_manager.asset_kinds = make(map[typeid]Asset_Kind, allocator)
	asset_manager.assets = make([dynamic]^Asset, allocator)
	register_builtin_asset_kinds(&asset_manager)
	return asset_manager }

register_asset_kind :: proc(manager: ^Asset_Manager, $Type: typeid, kind: Asset_Kind) {
	log.info("Registering type ", type_info_of(Type).id)
	manager.asset_kinds[Type] = kind }

// assert(as.asset_command(manager, as.String_Asset, &shader.frag_asset.asset, .Load))
watch_assets :: proc(manager: ^Asset_Manager) {
	for asset in manager.assets {
		log.info("Watching asset of type", type_info_of(asset.derived_type).id)
		asset_kind, ok := manager.asset_kinds[asset.derived_type]
		assert(ok)
		asset_kind.command(manager, asset, .Import, true) } }
