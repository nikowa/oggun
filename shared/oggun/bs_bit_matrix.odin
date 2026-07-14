#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

Bit_Matrix :: struct {
	shape: [2]u32,
	backing: Bit_Array }

make_square_bit_matrix :: proc(width: u32, allocator := context.allocator, loc := #caller_location) -> (bit_matrix: Bit_Matrix, err: runtime.Allocator_Error) #optional_allocator_error {
	return make_bit_matrix({ width, width }, allocator, loc) }

make_bit_matrix :: proc(shape: [2]u32, allocator := context.allocator, loc := #caller_location) -> (bit_matrix: Bit_Matrix, err: runtime.Allocator_Error) #optional_allocator_error {
	bit_matrix.shape = shape
	bit_matrix.backing, err = make_bit_array(shape.x * shape.y, allocator, loc)
	return bit_matrix, err }

clone_bit_matrix :: proc(bit_matrix: ^Bit_Matrix, allocator := context.allocator) -> (Bit_Matrix, runtime.Allocator_Error) #optional_allocator_error {
	backing, err := clone_bit_array(&bit_matrix.backing, allocator)
	return { shape = bit_matrix.shape, backing = backing }, err }

bit_matrix_fill_random :: proc(bit_matrix: ^Bit_Matrix) {
	bit_array_fill_random(&bit_matrix.backing) }

@(private="file") address_to_index :: proc(shape: [2]u32, address: [2]u32) -> u32 {
	return address.y * shape.x + address.x }

bit_matrix_write :: proc(bit_matrix: ^Bit_Matrix, address: [2]u32, value: u8) {
	bit_array_write_bit(&bit_matrix.backing, address_to_index(bit_matrix.shape, address), value) }

bit_matrix_read :: proc(bit_matrix: ^Bit_Matrix, address: [2]u32) -> u8 {
	return bit_array_read_bit(&bit_matrix.backing, address_to_index(bit_matrix.shape, address)) }

aprint_bit_matrix :: proc(bit_matrix: ^Bit_Matrix, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, int((bit_matrix.shape.x + 1) * bit_matrix.shape.y), allocator)
	for i in 0 ..< bit_matrix.shape.x {
		for j in 0 ..< bit_matrix.shape.y do fmt.sbprint(&sb, bit_matrix_read(bit_matrix, { i, j }))
		fmt.sbprintln(&sb) }
	return strings.to_string(sb) }

// unary ops
// binary ops
//
