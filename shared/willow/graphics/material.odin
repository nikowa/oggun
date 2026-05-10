#+feature using-stmt
package graphics
import rt "base:runtime"
import rl "core:reflect"
import fmt "core:fmt"
import os "core:os"
import slc "core:slice"
import m "core:math"
import la "core:math/linalg"
import mem "core:mem"
import fp "core:path/filepath"
import gl "vendor:OpenGL"
import gltf "shared:gltf2"
import log "core:log"
import "../asset_manager"
import t "core:time"
import b "core:bytes"

Material_Asset :: struct {
	using asset: asset_manager.Asset,
	base_color: Image_Asset }
	// metallic_factor: f32,
	// roughness_factor: f32,

init_material :: proc(as_mngr: ^asset_manager.Asset_Manager, material: ^Material_Asset, config: asset_manager.Asset_Config, base_color_url: asset_manager.URL) {
	config := config
	config.derived_type = Material_Asset
	asset_manager.init_asset(as_mngr, Material_Asset, &material.asset, config)
	init_image(as_mngr, &material.base_color, { url = base_color_url }) }

material_asset_command :: proc(as_mngr: ^asset_manager.Asset_Manager, asset: ^asset_manager.Asset, command: asset_manager.Asset_Command, watch: bool = false) -> (ok: bool) {
	material := asset_manager.asset_object(asset, Material_Asset, "asset")
	switch command {
	case .Query_Location, .Import, .Load, .Upload:
		ok = asset_manager.asset_command(as_mngr, Image_Asset, &material.base_color.asset, command)
		asset.location += material.base_color.asset.location
		return ok
	case .Validate, .Export, .Save, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"string\".", command)
		return false }
	return false }
