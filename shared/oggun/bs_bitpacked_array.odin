#+feature using-stmt
package oggun
import "base:runtime"
import "core:log"

Bitpacked_Array :: struct($Elem_Type: typeid, $elem_size: u32) {
	len: u32,
	backing: Bit_Array }

make_bitpacked_array :: proc($Elem_Type: typeid, $elem_size: u32, #any_int len: u32, allocator := context.allocator, loc := #caller_location) -> (array: Bitpacked_Array(Elem_Type, elem_size), err: runtime.Allocator_Error) #optional_allocator_error {
	array.backing, err = make_bit_array(elem_size * len, allocator, loc)
	array.len = len
	return array, err }

clone_bitpacked_array :: proc(array: ^Bitpacked_Array($Elem_Type, $elem_size), allocator := context.allocator) -> (Bitpacked_Array(Elem_Type, elem_size), runtime.Allocator_Error) #optional_allocator_error {
	backing, err := clone_bit_array(&array.backing, allocator)
	return { backing = backing }, err }

bitpacked_array_read :: proc(array: ^Bitpacked_Array($Elem_Type, $elem_size), #any_int i: u32) -> Elem_Type {
	return cast(Elem_Type)bit_array_read_chunk(&array.backing, [2]u32{ i * elem_size, (i + 1) * elem_size }) }

bitpacked_array_write :: proc(array: ^Bitpacked_Array($Elem_Type, $elem_size), #any_int i: u32, value: Elem_Type) {
	bit_array_write_chunk(&array.backing, [2]u32{ i * elem_size, (i + 1) * elem_size }, cast(Backing_Type)value) }
