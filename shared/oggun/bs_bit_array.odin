#+feature using-stmt
package oggun
import "base:runtime"
import "core:log"

Backing_Type :: u8
w: uint : 8 * size_of(Backing_Type)

Bit_Array :: struct {
	len: u32,
	buffer: []Backing_Type }

make_bit_array :: proc(#any_int len: uint, allocator := context.allocator, loc := #caller_location) -> (array: Bit_Array, err: runtime.Allocator_Error) #optional_allocator_error {
	array.len = u32(len)
	array.buffer, err = make([]Backing_Type, len / w + 1)
	return array, err }

delete_bit_array :: proc(array: ^Bit_Array) {
	delete(array.buffer) }

bit_array_read :: proc(array: ^Bit_Array, #any_int j: uint) -> Backing_Type {
	return 0b1 & (array.buffer[j / w] >> (w - 1 - (j % w))) }

bit_array_set :: proc(array: ^Bit_Array, #any_int j: uint) {
	array.buffer[j / w] |= 0b1 << (w - 1 - (j % w)) }

bit_array_clear :: proc(array: ^Bit_Array, #any_int j: uint) {
	array.buffer[j / w] &= ~ (0b1 << (w - 1 - (j % w))) }


