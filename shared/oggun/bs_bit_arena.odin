#+feature using-stmt
package oggun
import "base:runtime"
import "core:log"

Bit_Arena :: struct {
	backing: Bit_Array,
	offset: uint }

bit_arena_alloc :: proc(a: ^Bit_Arena, #any_int size: uint, loc := #caller_location) -> (offset: uint, err: runtime.Allocator_Error) {
	// (TODO):
	return 0, nil }
