#+feature using-stmt
package oggun
import "base:runtime"
import "base:intrinsics"
import "core:log"
import "core:fmt"
import "core:slice"

Index :: struct($S: typeid, $B: typeid)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	value: B }

make_index :: proc "contextless" ($S: typeid, $B: typeid) -> Index(S, B) {
	return { -1 } }

index_get :: proc "contextless" (ix: ^$I/Index($S, $B), universe: S) -> (ptr: ^intrinsics.type_elem_type(S), ok: bool)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	if ix.value == -1 do return nil, false
	return slice.get_ptr(universe, cast(int)ix.value) }

// (TODO): Rename to "index_set_by_ptr" and add "index_set_by_index".

index_set :: proc "contextless" (ix: ^$I/Index($S, $B), universe: S, arg: ^intrinsics.type_elem_type(S), loc := #caller_location) -> (ok: bool)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	context = runtime.default_context()
	assert(len(universe) > 0, loc=loc)
	if cast(uintptr)arg < cast(uintptr)&universe[0] || cast(uintptr)arg > cast(uintptr)&universe[len(universe) - 1] {
		ix.value = -1
		return false }
	ix.value = cast(B)((cast(uintptr)arg - cast(uintptr)&universe[0]) / size_of(intrinsics.type_elem_type(S)))
	return true }

index_is_nil :: proc "contextless" (ix: ^$I/Index($S, $B)) -> bool {
	return ix.value == -1 }

index_set_nil :: proc "contextless" (ix: ^$I/Index($S, $B)) {
	ix.value = -1 }
