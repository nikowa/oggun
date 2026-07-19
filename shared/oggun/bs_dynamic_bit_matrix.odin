#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

Dynamic_Bit_Matrix :: struct {
	using bit_matrix: Bit_Matrix,
	allocator: runtime.Allocator }

make_square_dynamic_bit_matrix :: proc(width: u32, allocator := context.allocator, loc := #caller_location) -> (result: Dynamic_Bit_Matrix, err: runtime.Allocator_Error) #optional_allocator_error {
	result.bit_matrix, err = make_square_bit_matrix(width, allocator, loc)
	result.allocator = allocator
	return result, err }

make_dynamic_bit_matrix :: proc(shape: [2]u32, allocator := context.allocator, loc := #caller_location) -> (result: Dynamic_Bit_Matrix, err: runtime.Allocator_Error) #optional_allocator_error {
	result.bit_matrix, err = make_bit_matrix(shape, allocator, loc)
	result.allocator = allocator
	return result, err }

clone_dynamic_bit_matrix :: proc(dbm: ^Dynamic_Bit_Matrix, allocator := context.allocator) -> (result: Dynamic_Bit_Matrix, err: runtime.Allocator_Error) #optional_allocator_error {
	result.bit_matrix, err = _clone_bit_matrix(&dbm.bit_matrix, allocator)
	result.allocator = allocator
	return result, err }

dynamic_bit_matrix_fill_random :: proc(dbm: ^Dynamic_Bit_Matrix) {
	_bit_matrix_fill_random(&dbm.bit_matrix) }

dynamic_bit_matrix_write :: proc(dbm: ^Dynamic_Bit_Matrix, index2: [2]u32, value: u8) {
	_bit_matrix_write_bit(&dbm.bit_matrix, index2, value) }

dynamic_bit_matrix_read :: proc(dbm: ^Dynamic_Bit_Matrix, index2: [2]u32) -> u8 {
	return _bit_matrix_read_bit(&dbm.bit_matrix, index2) }

aprint_dynamic_bit_matrix :: proc(dbm: ^Dynamic_Bit_Matrix, allocator := context.allocator) -> string {
	return _aprint_bit_matrix(&dbm.bit_matrix, allocator) }

dynamic_bit_matrix_copy_range :: proc(dest: ^Dynamic_Bit_Matrix, src: ^Dynamic_Bit_Matrix, dest_range: Range(int), src_range: Range(int)) { }

dynamic_bit_matrix_append_row :: proc(dynamic_bit_matrix: ^Dynamic_Bit_Matrix) { }

dynamic_bit_matrix_prepend_row :: proc(dynamic_bit_matrix: ^Dynamic_Bit_Matrix) { }

dynamic_bit_matrix_append_col :: proc(dynamic_bit_matrix: ^Dynamic_Bit_Matrix) { }

dynamic_bit_matrix_prepend_col :: proc(dynamic_bit_matrix: ^Dynamic_Bit_Matrix) { }
