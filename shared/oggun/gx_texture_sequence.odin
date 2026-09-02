#+feature using-stmt
package oggun
import "core:log"
import "core:fmt"
import "core:slice"
import gl "vendor:OpenGL"

Texture_Sequence :: struct {
	using asset: Asset,
	// (TODO): Use "Tuple" here instead of slice. //
	textures: Tuple(Texture, i16, u8),
	render_buffer: ^Render_Buffer }

Texture_Sequence_Shape :: []Texture_Shape

Material_Texture_Index :: enum {
	Base_Color,
	Roughness,
	Metallic }

Canvas_Texture_Index :: enum {
	Color,
	Emission,
	ID }

texture_sequence_init :: proc { texture_sequence_init_from_shape, texture_sequence_init_from_textures }

texture_sequence_init_from_shape :: proc(texture_sequence: ^Texture_Sequence, config: Asset_Config, shape: Texture_Sequence_Shape, allocator := context.allocator) {
	n := len(shape)
	textures := make([]^Texture, n)
	for i in 0 ..< n {
		textures[i] = new(Texture)
		texture_init(textures[i], { url = cast(URL)fmt.aprintf("%s-%d", config.url, i, allocator=allocator) }, shape[i]) }
	texture_sequence_init_from_textures(texture_sequence, config, textures) }

texture_sequence_init_from_textures :: proc(texture_sequence: ^Texture_Sequence, config: Asset_Config, textures: []^Texture, allocator := context.allocator) {
	config := config
	config.derived_type = Texture_Sequence
	texture_sequence.textures = make_tuple(Texture, i16, u8, textures, state.graphics_manager.textures[:], allocator)
	am_init_asset(Texture_Sequence, &texture_sequence.asset, config) }

texture_sequence_shape :: proc(texture_sequence: ^Texture_Sequence, allocator := context.allocator) -> (shape: Texture_Sequence_Shape) {
	shape = make([]Texture_Shape, tuple_len(&texture_sequence.textures), allocator)
	for &texture_shape, i in shape do texture_shape = tuple_get(&texture_sequence.textures, state.graphics_manager.textures[:], auto_cast i).shape
	return shape }

texture_sequence_op :: proc(base: ^Asset, op: Asset_Op, dest: Asset_Location = .None, src: Asset_Location = .None, arg: rawptr = nil, location := #caller_location) -> (ok: bool) {
	this := am_asset_base(base, Texture_Sequence, "asset")
	ni: bool = false
	ok = true
	i: u8 = 0
	#partial switch op {
	case .Make:
		for texture in tuple_iterate(&this.textures, state.graphics_manager.textures[:], &i) {
			ok &= am_op(Texture, &texture.asset, op, dest, src, arg, location) }
		if dest == .VRAM do texture_sequence_allocate_render_buffer(this)
		return ok
	case .Exists:
		for texture in tuple_iterate(&this.textures, state.graphics_manager.textures[:], &i) {
			ok &= am_op(Texture, &texture.asset, op, dest, src, arg, location) }
		if dest == .VRAM do ok &= (this.render_buffer.frame_buffer_handle != 0 && this.render_buffer.render_buffer_handle != 0)
		return ok
	case .Delete, .Initialize, .Translate:
		for texture in tuple_iterate(&this.textures, state.graphics_manager.textures[:], &i) {
			ok &= am_op(Texture, &texture.asset, op, dest, src, arg, location) }
		return ok
	case .Outdated:
		for texture in tuple_iterate(&this.textures, state.graphics_manager.textures[:], &i) {
			ok |= am_op(Texture, &texture.asset, op, dest, src, arg, location) }
		return ok
	case: ni = true }
	if ni do am_error_not_implemented(op, dest, src, location)
	return false }

texture_sequence_allocate_render_buffer :: proc(this: ^Texture_Sequence) {
	size := tuple_get(&this.textures, state.graphics_manager.textures[:], 0).size
	n := tuple_len(&this.textures)
	this.render_buffer = new(Render_Buffer)
	internal_formats, formats, data_types := make([]i32, n), make([]u32, n), make([]u32, n)
	for i in 0 ..< n {
		texture := tuple_get(&this.textures, state.graphics_manager.textures[:], auto_cast i)
		shape := texture.shape
		internal_formats[i] = _texture_shape_to_gl_internal_format(shape)
		formats[i] = _texture_shape_to_gl_format(shape)
		data_types[i] = gl.UNSIGNED_INT }
	this.render_buffer^ = make_render_buffer(auto_cast size, internal_formats, formats, data_types) }

make_texture_sequence_shape :: proc(texture_shapes: []Texture_Shape, allocator := context.allocator) -> Texture_Sequence_Shape {
	return slice.clone(texture_shapes, allocator)
}
