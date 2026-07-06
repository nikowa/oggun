#+feature using-stmt
package oggun
import "base:runtime"
import "core:log"

Bit_Arena :: Dynamic_Bit_Array

make_bit_arena :: proc(#any_int cap: uint, allocator := context.allocator, loc := #caller_location) -> (arena: Bit_Arena, err: runtime.Allocator_Error) {
	return make_dynamic_bit_array(0, cap, allocator, loc) }

bit_arena_alloc :: proc(arena: ^Bit_Arena, #any_int size: uint, loc := #caller_location) -> (offset: uint, err: runtime.Allocator_Error) {
	if uint(arena.len) + size > uint(arena.cap) do return 0, .Out_Of_Memory
	offset = uint(arena.len)
	dynamic_bit_arena_resize(arena, uint(arena.len) + size)
	dynamic_bit_array_clear_chunk(arena, { offset, uint(arena.len) })
	return offset, nil }

bit_arena_free_all :: proc(arena: ^Bit_Arena) {
	arena.len = 0 }
