package willow
import "core:math"
import "core:math/linalg"

ease_sine :: proc(x: f32) -> f32 {
	return -(math.cos(math.PI * x) - 1) / 2 }
