package willow
import "core:math/rand"

Color :: u32

BLACK:       Color : 0x000000ff
WHITE:       Color : 0xffffffff
RED:         Color : 0xff0000ff
DARK_RED:    Color : 0x800000ff
GREEN:       Color : 0x00ff00ff
DARK_GREEN:  Color : 0x008000ff
BLUE:        Color : 0x0000ffff
DARK_BLUE:   Color : 0x000080ff
GRAY:        Color : 0x808080ff
LIGHT_GRAY:  Color : 0xc0c0c0ff
DARK_GRAY:   Color : 0x404040ff

color_to_4f32 :: proc "contextless" (color: Color) -> [4]f32 {
	return {
		f32((color & 0xFF000000) >> 24) / 255.0,
		f32((color & 0x00FF0000) >> 16) / 255.0,
		f32((color & 0x0000FF00) >> 8)  / 255.0,
		f32((color & 0x000000FF))       / 255.0 } }

color_from_4f32 :: proc "contextless" (vec: [4]f32) -> (color: Color) {
	return \
		(cast(u32)cast(u8)(vec[0] * 255)) << 24 |
		(cast(u32)cast(u8)(vec[1] * 255)) << 16 |
		(cast(u32)cast(u8)(vec[2] * 255)) << 8  |
		(cast(u32)cast(u8)(vec[3] * 255)) }

color_random :: proc() -> Color {
	return \
		rand.uint32_max(256) << 24 |
		rand.uint32_max(256) << 16 |
		rand.uint32_max(256) <<  8 |
		0xFF }

color_r :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0xFF000000) >> 24) }

color_g :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0x00FF0000) >> 16) }

color_b :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0x0000FF00) >> 8) }

color_a :: proc "contextless" (color: Color) -> u8 {
	return u8(color & 0x000000FF) }
