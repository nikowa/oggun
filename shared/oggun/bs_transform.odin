package oggun
import "base:runtime"
import "core:math/linalg"

Transformer :: struct {
	translate: matrix[4, 4]f32,
	rotate: matrix[4, 4]f32,
	scale: matrix[4, 4]f32,
	total: matrix[4, 4]f32,
	total_cumulative: matrix[4, 4]f32 }

Transform :: struct {
	translate: [3]f32,
	rotate: quaternion128,
	scale: [3]f32 }

transform_to_transformer :: proc(transform: ^Transform) -> (transformer: Transformer) {
	transformer.translate = linalg.matrix4_translate_f32(transform.translate)
	transformer.rotate = linalg.matrix4_rotate_f32(transform.rotate.x, { 1, 0, 0 }) *
		linalg.matrix4_rotate_f32(transform.rotate.y, { 0, 1, 0 }) *
		linalg.matrix4_rotate_f32(transform.rotate.z, { 0, 0, 1 })
	transformer.scale = linalg.matrix4_scale_f32(transform.scale)
	transformer.total = transformer.translate * transformer.rotate * transformer.scale
	return transformer }
