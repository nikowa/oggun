#+feature using-stmt
package oggun
import "base:intrinsics"
import "core:log"
import "core:fmt"
import "core:slice"

Index :: struct($S: typeid, $B: typeid)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	value: B }

make_index :: proc "contextless" ($S: typeid, $B: typeid) -> Index(S, B) {
	return { -1 } }

index_get :: proc "contextless" (ix: ^$I/Index($S, $B), array: S) -> (ptr: ^intrinsics.type_elem_type(S), ok: bool)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	if ix.value == -1 do return nil, false
	return slice.get_ptr(array, cast(int)ix.value) }

index_set :: proc "contextless" (ix: ^$I/Index($S, $B), array: S, arg: ^intrinsics.type_elem_type(S)) -> (ok: bool)
	where intrinsics.type_is_slice(S) && intrinsics.type_is_integer(B) && ! intrinsics.type_is_unsigned(B) {
	if cast(uintptr)arg < cast(uintptr)&array[0] || cast(uintptr)arg > cast(uintptr)&array[len(array) - 1] {
		ix.value = -1
		return false }
	ix.value = cast(B)((cast(uintptr)arg - cast(uintptr)&array[0]) / size_of(intrinsics.type_elem_type(S)))
	return true }

index_is_nil :: proc "contextless" (ix: ^$I/Index($S, $B)) -> bool {
	return ix.value == -1 }

index_set_nil :: proc "contextless" (ix: ^$I/Index($S, $B)) {
	ix.value = -1 }
