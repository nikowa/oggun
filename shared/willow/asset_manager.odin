package willow
import "base:runtime"

Asset_Manager_Config :: Database_Config

Asset_Manager :: struct {
	using database: Database,
	assets: [dynamic]^Asset,
	asset_kinds: map[typeid]Asset_Kind }

Asset_Command :: enum {
	Validate,
	// Initialize,
	Query_Location,
	Import,
	Export,
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

// (NOTE): All types that derive from asset must be remain at the same memory address after initialization by "init_asset".
Asset :: struct {
	using asset_config: Asset_Config,
	location: Asset_Location }

Asset_Kind :: struct {
	command: Asset_Command_Proc }

asset_command :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	assert(Asset_Type in manager.asset_kinds)
	asset_kind := manager.asset_kinds[Asset_Type]
	when ODIN_DEBUG do asset_kind.command(manager, asset, .Validate, false)
	assert(asset_kind.command != nil)
	return asset_kind.command(manager, asset, command, watch) }

asset_commands :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, commands: []Asset_Command, watch: bool = false) -> (ok: bool) {
	ok = true
	for command in commands do ok &&= asset_command(manager, Asset_Type, asset, command, watch)
	return ok }

@(deferred_in=_init_asset_end)
init_asset :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	_init_asset_begin(manager, Asset_Type, asset, config) }

@private
_init_asset_begin :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	// log.info("Initializing asset of type", type_info_of(config.derived_type).id)
	asset.asset_config = config
	append(&manager.assets, asset) }

@private
_init_asset_end :: proc(manager: ^Asset_Manager, Asset_Type: typeid, asset: ^Asset, config: Asset_Config) {
	asset_commands(manager, Asset_Type, asset, { .Validate, .Query_Location }) }

asset_object :: proc(asset: ^Asset, $T: typeid, $field_name: string) -> (^T) {
	offset: uintptr = offset_of_by_string(T, field_name)
	return cast(^T)(uintptr(asset) - offset) }

make_asset_manager :: proc(config: Asset_Manager_Config, allocator: runtime.Allocator) -> (asset_manager: Asset_Manager) {
	asset_manager.database = make_or_read_database(config, allocator)
	asset_manager.asset_kinds = make(map[typeid]Asset_Kind, allocator)
	asset_manager.assets = make_dynamic_array_len_cap([dynamic]^Asset, 0, 32, allocator)
	register_builtin_asset_kinds(&asset_manager)
	return asset_manager }

register_asset_kind :: proc(manager: ^Asset_Manager, $Type: typeid, kind: Asset_Kind) {
	// log.info("Registering type ", type_info_of(Type).id)
	manager.asset_kinds[Type] = kind }

// assert(as.asset_command(manager, as.String_Asset, &shader.frag_asset.asset, .Load))
watch_assets :: proc(manager: ^Asset_Manager) {
	for asset in manager.assets {
		// log.infof("Watching asset %s of type %v", asset.url, type_info_of(asset.derived_type).id)
		asset_kind, ok := manager.asset_kinds[asset.derived_type]
		assert(ok)
		asset_kind.command(manager, asset, .Import, true)
		asset_kind.command(manager, asset, .Load, true)
		asset_kind.command(manager, asset, .Upload, true) } }
