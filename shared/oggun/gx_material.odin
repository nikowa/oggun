#+feature using-stmt
package oggun
import "core:log"

Material_Asset :: struct {
	using asset: Asset,
	base_color: Image_Asset }
	// metallic_factor: f32,
	// roughness_factor: f32,

init_material :: proc(material: ^Material_Asset, config: Asset_Config, base_color_url: URL) {
	config := config
	config.derived_type = Material_Asset
	am_init_asset(Material_Asset, &material.asset, config)
	init_image(&material.base_color, { url = base_color_url }) }

material_asset_command :: proc(asset: ^Asset, command: Asset_Command, watch: bool = false) -> (ok: bool) {
	material := am_asset_base(asset, Material_Asset, "asset")
	switch command {
	case .Query_Location, .Import, .Load, .Upload:
		ok = am_command(Image_Asset, &material.base_color.asset, command)
		asset.location += material.base_color.asset.location
		return ok
	case .Validate, .Export, .Save, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }
