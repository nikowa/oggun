#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"
import "core:relative"
import "core:math/bits"

Tuple :: struct($E: typeid) {
	// (TODO): Use custom type "BPointer" here. //
	buffer: []u16,
	len: u8 }

TUPLE_CAP :: 255

TUPLE_UNIVERSE_CAP :: bits.U16_MAX

make_tuple_len :: proc(Universe: []$E, #any_int len: u8, allocator := context.allocator, loc := #caller_location) ->
		(tuple: Tuple(E), err: runtime.Allocator_Error) #optional_allocator_error {
	return make_tuple_len_cap(tuple, len, len, allocator, loc) }

make_tuple_len_cap :: proc(Universe: []$E, #any_int len: u8, #any_int cap: u8, allocator := context.allocator, loc := #caller_location) ->
		(tuple: Tuple(E), err: runtime.Allocator_Error) #optional_allocator_error {
	tuple.buffer, err = make([]u16, cap, allocator)
	tuple.len = len
	return tuple, err }

tuple_append :: proc(tuple: ^Tuple($E), arg: ^E, universe: []E, loc := #caller_location) ->
		(n: int, err: runtime.Allocator_Error) #optional_allocator_error {
	if tuple.len == len(tuple) do return 0, .Out_Of_Memory
	tuple.buffer[tuple.len] = (u16(cast(uintptr)arg - cast(uintptr)&universe[0])) / size_of(E)
	tuple.len += 1
	return 1, nil }

tuple_elem :: proc(tuple: ^Tuple($E), universe: []E, #any_int index: u8) ->
		(elem: ^E, ok: bool) #optional_ok {
	if index >= tuple.len do return nil, false
	return cast(^E)(cast(uintptr)&universe[0] + cast(uintptr)tuple.buffer[index] * size_of(E)), true }

tuple_len :: proc(tuple: ^Tuple($E)) -> int {
	return cast(int)tuple.len }
