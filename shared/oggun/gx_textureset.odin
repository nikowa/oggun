#+feature using-stmt
package oggun
import "core:log"
import "core:fmt"

Textureset :: struct {
	using asset: Asset,
	textures: []^Texture }

Textureset_Shape :: []Texture_Shape

Material_Texture_Index :: enum {
	Base_Color,
	Roughness,
	Metallic }

Canvas_Texture_Index :: enum {
	Color,
	Emission,
	ID }

textureset_init :: proc { textureset_init_from_shape, textureset_init_from_textures }

textureset_init_from_shape :: proc(textureset: ^Textureset, config: Asset_Config, shape: Textureset_Shape, flags: Texture_Create_Flags = {}, allocator := context.allocator) {
	n := len(shape)
	textures := make([]^Texture, n)
	for i in 0 ..< n {
		textures[i] = new(Texture)
		texture_init(textures[i], { url = cast(URL)fmt.aprintf("%s-%d", config.url, i, allocator=allocator) }, shape[i], flags) }
	textureset_init_from_textures(textureset, config, textures) }

textureset_init_from_textures :: proc(textureset: ^Textureset, config: Asset_Config, textures: []^Texture) {
	config := config
	config.derived_type = Textureset
	textureset.textures = textures
	am_init_asset(Textureset, &textureset.asset, config) }

textureset_shape :: proc(textureset: ^Textureset, allocator := context.allocator) -> (shape: Textureset_Shape) {
	shape = make([]Texture_Shape, len(textureset.textures), allocator)
	for &texture_shape, i in shape do texture_shape = textureset.textures[i]
	return shape }

textureset_command :: proc(asset: ^Asset, command: Asset_Command, watch: bool = false, location := #caller_location) -> (ok: bool) {
	textureset := am_asset_base(asset, Textureset, "asset")
	switch command {
	case .Query_Location, .Import, .Deserialize, .Upload:
		ok = true
		for &texture in textureset.textures do ok &= am_command(Texture, &texture.asset, command)
		// (TODO): Update `asset.location`.
		// asset.location += textureset.asset.location
		return ok
	case .Validate, .Export, .Serialize, .Download:
		if ! watch do log.errorf("Command %v not implemented for asset kind \"Textureset\".", command)
		return false }
	return false }
