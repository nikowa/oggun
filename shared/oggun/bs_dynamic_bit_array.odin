#+feature using-stmt
package oggun
import "base:runtime"

Dynamic_Bit_Array :: struct {
	len: u32,
	cap: u32,
	buffer: [dynamic]Backing_Type }

@private len_to_wordlen :: proc(#any_int len: uint) -> uint {
	return len / BIT_ARRAY_W + 1 }

make_dynamic_bit_array :: proc(#any_int len: uint, #any_int cap: uint, allocator := context.allocator, loc := #caller_location) -> (array: Dynamic_Bit_Array, err: runtime.Allocator_Error) #optional_allocator_error {
	array.buffer, err = make_dynamic_array_len_cap([dynamic]Backing_Type, len_to_wordlen(len), len_to_wordlen(cap), allocator, loc)
	array.len, array.cap = u32(len), u32(cap)
	return array, err }

dynamic_bit_array_as_bit_array :: proc(array: ^Dynamic_Bit_Array) -> Bit_Array {
	return { len = array.len, buffer = array.buffer[:] } }

dynamic_bit_array_fill_random :: proc(array: ^Dynamic_Bit_Array) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_fill_random(&bit_array) }

aprint_dynamic_bit_array :: proc(array: ^Dynamic_Bit_Array, allocator := context.allocator) -> string {
	bit_array := dynamic_bit_array_as_bit_array(array)
	return aprint_bit_array(&bit_array, allocator) }

aprint_dynamic_bit_array_ext :: proc(array: ^Dynamic_Bit_Array, allocator := context.allocator) -> string {
	bit_array := dynamic_bit_array_as_bit_array(array)
	return aprint_bit_array_ext(&bit_array, allocator) }

delete_dynamic_bit_array :: proc(array: ^Dynamic_Bit_Array) {
	delete(array.buffer) }

dynamic_bit_array_set :: proc(array: ^Dynamic_Bit_Array, #any_int j: uint) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_set(&bit_array, j) }

dynamic_bit_array_clear :: proc { dynamic_bit_array_clear_bit, dynamic_bit_array_clear_chunk }

dynamic_bit_array_clear_bit :: proc(array: ^Dynamic_Bit_Array, #any_int j: uint) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_clear_bit(&bit_array, j) }

dynamic_bit_array_clear_chunk :: proc(array: ^Dynamic_Bit_Array, range: [2]uint) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_clear_chunk(&bit_array, range) }

dynamic_bit_array_read :: proc { dynamic_bit_array_read_bit, dynamic_bit_array_read_chunk }

dynamic_bit_array_read_bit :: proc(array: ^Dynamic_Bit_Array, #any_int j: uint) -> u8 {
	bit_array := dynamic_bit_array_as_bit_array(array)
	return bit_array_read_bit(&bit_array, j) }

dynamic_bit_array_read_chunk :: proc(array: ^Dynamic_Bit_Array, range: [2]uint) -> Backing_Type {
	bit_array := dynamic_bit_array_as_bit_array(array)
	return bit_array_read_chunk(&bit_array, range) }

dynamic_bit_array_write :: proc { dynamic_bit_array_write_bit, dynamic_bit_array_write_chunk }

dynamic_bit_array_write_bit :: proc(array: ^Dynamic_Bit_Array, #any_int j: uint, value: u8) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_write_bit(&bit_array, j, value) }

dynamic_bit_array_write_chunk :: proc(array: ^Dynamic_Bit_Array, range: [2]uint, value: Backing_Type) {
	bit_array := dynamic_bit_array_as_bit_array(array)
	bit_array_write_chunk(&bit_array, range, value) }

dynamic_bit_array_append :: proc { dynamic_bit_array_append_bit, dynamic_bit_array_append_chunk }

dynamic_bit_array_append_bit :: proc(array: ^Dynamic_Bit_Array, value: u8) {
	if len_to_wordlen(uint(array.len + 1)) > len_to_wordlen(array.len) do resize(&array.buffer, len_to_wordlen(array.len + 1))
	array.len += 1
	dynamic_bit_array_write_bit(array, array.len - 1, value) }

dynamic_bit_array_append_chunk :: proc(array: ^Dynamic_Bit_Array, value: Backing_Type, #any_int len: uint) {
	if len_to_wordlen(uint(array.len) + len) > len_to_wordlen(array.len) do resize(&array.buffer, len_to_wordlen(uint(array.len) + len))
	array.len += u32(len)
	dynamic_bit_array_write_chunk(array, { uint(array.len) - len, uint(array.len) }, value) }

dynamic_bit_arena_resize :: proc(array: ^Dynamic_Bit_Array, #any_int new_size: uint) {
	if len_to_wordlen(new_size) > len_to_wordlen(array.len) do resize(&array.buffer, len_to_wordlen(new_size))
	array.len = u32(new_size) }
