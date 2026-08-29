#+feature using-stmt
package bpointer
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"
import "core:mem"

@(test)
test :: proc(t: ^testing.T) {
	context.user_ptr = t
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 100_000))
	context.allocator = mem.arena_allocator(&arena)

	err: runtime.Allocator_Error

	bp: og.BPointer(^int, u16)

// bpointer_set :: proc "contextless" (p: ^$P/BPointer($T, $B), ptr: T, base: rawptr) {

// bpointer_get :: proc "contextless" (p: ^$P/BPointer($T, $B), base: rawptr) -> T {

	free_all(context.temp_allocator) }

// @(tezt)
// tezt :: proc(fuzzer: T_Integers) {
// }
