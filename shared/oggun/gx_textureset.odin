#+feature using-stmt
package oggun
import "core:log"
import "core:fmt"

Textureset :: struct {
	using asset: Asset,
	textures: []^Texture,
	// render_buffer: ^Render_Buffer
}

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

textureset_op :: proc(asset: ^Asset, op: Asset_Op, dest: Asset_Location = .None, src: Asset_Location = .None, arg: rawptr = nil, location := #caller_location) -> (ok: bool) {
	textureset := am_asset_base(asset, Textureset, "asset")
	ni: bool = false
	ok = true
	#partial switch op {
	case .Make, .Delete, .Initialize, .Exists, .Translate:
		for &texture in textureset.textures do ok &= am_op(Texture, &texture.asset, op, dest, src, arg, location)
		return ok
	case .Outdated:
		for &texture in textureset.textures do ok |= am_op(Texture, &texture.asset, op, dest, src, arg, location)
		return ok
	case: ni = true }
	if ni do am_error_not_implemented(op, dest, src, location)
	return false }
