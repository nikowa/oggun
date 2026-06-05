package willow
import "core:math"
import "core:math/linalg"

ease_sin :: proc(x: f32) -> f32 {
	return -(math.cos(math.PI * x) - 1) / 2 }

ease_sin_2 :: proc(x: f32) -> f32 {
	return ease_sin(ease_sin(x)) }

ease_sin_3 :: proc(x: f32) -> f32 {
	return ease_sin(ease_sin(ease_sin(x))) }

ease_sin_4 :: proc(x: f32) -> f32 {
	return ease_sin(ease_sin(ease_sin(ease_sin(x)))) }
