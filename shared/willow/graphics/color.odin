package graphics
import "core:math/rand"

color_random :: proc() -> [4]f32 {
	return { rand.float32(), rand.float32(), rand.float32(), 1.0 } }
