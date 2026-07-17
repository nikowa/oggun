package oggun
import "core:math/rand"
import win32 "core:sys/windows"
import "core:math"

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
CYAN:        Color : 0x00ffffff
DARK_CYAN:   Color : 0x008080ff
PURPLE:      Color : 0xff00ffff
DARK_PURPLE: Color : 0x800080ff

ANSI_FG_BLACK :: "\e[30m"
ANSI_FG_RED :: "\e[31m"
ANSI_FG_GREEN :: "\e[32m"
ANSI_FG_YELLOW :: "\e[33m"
ANSI_FG_BLUE :: "\e[34m"
ANSI_FG_MAGENTA :: "\e[35m"
ANSI_FG_CYAN :: "\e[36m"
ANSI_FG_WHITE :: "\e[37m"
ANSI_FG_INTENSE_BLACK :: "\e[90m"
ANSI_FG_INTENSE_RED :: "\e[91m"
ANSI_FG_INTENSE_GREEN :: "\e[92m"
ANSI_FG_INTENSE_YELLOW :: "\e[93m"
ANSI_FG_INTENSE_BLUE :: "\e[94m"
ANSI_FG_INTENSE_MAGENTA :: "\e[95m"
ANSI_FG_INTENSE_CYAN :: "\e[96m"
ANSI_FG_INTENSE_WHITE :: "\e[97m"
ANSI_BG_BLACK :: "\e[40m"
ANSI_BG_RED :: "\e[41m"
ANSI_BG_GREEN :: "\e[42m"
ANSI_BG_YELLOW :: "\e[43m"
ANSI_BG_BLUE :: "\e[44m"
ANSI_BG_MAGENTA :: "\e[45m"
ANSI_BG_CYAN :: "\e[46m"
ANSI_BG_WHITE :: "\e[47m"
ANSI_BG_INTENSE_BLACK :: "\e[100m"
ANSI_BG_INTENSE_RED :: "\e[101m"
ANSI_BG_INTENSE_GREEN :: "\e[102m"
ANSI_BG_INTENSE_YELLOW :: "\e[103m"
ANSI_BG_INTENSE_BLUE :: "\e[104m"
ANSI_BG_INTENSE_MAGENTA :: "\e[105m"
ANSI_BG_INTENSE_CYAN :: "\e[106m"
ANSI_BG_INTENSE_WHITE :: "\e[107m"
ANSI_DEFAULT :: "\e[0m"

ANSI_FG_15 :: "\e[38;5;15m"

gx_color_to_4f32 :: proc "contextless" (color: Color) -> [4]f32 {
	return {
		f32((color & 0xFF000000) >> 24) / 255.0,
		f32((color & 0x00FF0000) >> 16) / 255.0,
		f32((color & 0x0000FF00) >> 8)  / 255.0,
		f32((color & 0x000000FF))       / 255.0 } }

gx_color_to_4u8 :: proc "contextless" (color: Color) -> [4]u8 {
	return {
		u8((color & 0xFF000000) >> 24),
		u8((color & 0x00FF0000) >> 16),
		u8((color & 0x0000FF00) >> 8),
		u8((color & 0x000000FF)) } }

gx_color_from_4f32 :: proc "contextless" (vec: [4]f32) -> (color: Color) {
	return \
		(cast(u32)cast(u8)(vec[0] * 255)) << 24 |
		(cast(u32)cast(u8)(vec[1] * 255)) << 16 |
		(cast(u32)cast(u8)(vec[2] * 255)) << 8  |
		(cast(u32)cast(u8)(vec[3] * 255)) }

gx_color_from_4u8 :: proc "contextless" (vec: [4]u8) -> (color: Color) {
	return \
		(cast(u32)vec[0]) << 24 |
		(cast(u32)vec[1]) << 16 |
		(cast(u32)vec[2]) << 8  |
		(cast(u32)vec[3]) }

gx_gx_color_random :: proc() -> Color {
	return \
		rand.uint32_max(256) << 24 |
		rand.uint32_max(256) << 16 |
		rand.uint32_max(256) <<  8 |
		0xFF }

gx_color_r :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0xFF000000) >> 24) }

gx_color_g :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0x00FF0000) >> 16) }

gx_color_b :: proc "contextless" (color: Color) -> u8 {
	return u8((color & 0x0000FF00) >> 8) }

gx_color_a :: proc "contextless" (color: Color) -> u8 {
	return u8(color & 0x000000FF) }

gx_color_to_win32_color :: proc(color: Color) -> (win32_color: win32.COLORREF) {
	vec := gx_color_to_4u8(color)
	return auto_cast gx_color_from_4u8({ 0, vec.b, vec.g, vec.r }) }

gx_color_lightness :: proc(color: Color) -> f32 {
	c := gx_color_to_4u8(color)
	return clamp((((0.4126 * (f32(c.r) + f32(c.g) + f32(c.b)) - 0.0033 * f32(c.r) - 0.0179 * f32(c.g) - 0.0215 * f32(c.b) + 0.0518) / 3) - 1) / 100, 0, 1) }

gx_color_is_light :: proc(color: Color) -> bool {
	return gx_color_lightness(color) >= 0.5 }

gx_color_is_dark :: proc(color: Color) -> bool {
	return ! gx_color_is_light(color) }
