#+feature using-stmt
package oggun
import "base:intrinsics"

BPointer :: struct($Type: typeid, $Backing: typeid) where
		intrinsics.type_is_pointer(Type) || intrinsics.type_is_multi_pointer(Type),
		intrinsics.type_is_integer(Backing) && intrinsics.type_is_unsigned(Backing) {
	offset: Backing }

bpointer_get :: proc "contextless" (p: ^$P/BPointer($T, $B), base: rawptr) -> T {
	return cast(T)(cast(uintptr)base + cast(uintptr)p.offset) }

bpointer_set :: proc "contextless" (p: ^$P/BPointer($T, $B), ptr: T, base: rawptr) {
	p.offset = cast(Backing)(cast(uintptr)ptr - cast(uintptr)base) }

bpointer_set_safe :: proc "contextless" (p: ^$P/BPointer($T, $B), ptr: T, base: rawptr) -> (ok: bool) {
	if ! bpointer_bounds_check(ptr, base) do return false
	bpointer_set(p, ptr, base)
	return true }

bpointer_bounds_check :: proc "contextless" (ptr: $T, base: rawptr) -> bool {
	return true }

// bnew :: proc($T: typeid, allocator := context.allocator, loc := #caller_location) -> (t: ^typeid, err: Allocator_Error) #optional_ok {
// }

// bmake :: proc()
