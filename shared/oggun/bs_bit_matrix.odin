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

_clone_bit_matrix :: proc(bit_matrix: ^Bit_Matrix, allocator := context.allocator) -> (Bit_Matrix, runtime.Allocator_Error) #optional_allocator_error {
	backing, err := clone_bit_array(&bit_matrix.backing, allocator)
	return { shape = bit_matrix.shape, backing = backing }, err }

_bit_matrix_size :: proc(bit_matrix: ^Bit_Matrix) -> u32 {
	return bit_matrix.shape.x * bit_matrix.shape.y }

_bit_matrix_fill_random :: proc(bit_matrix: ^Bit_Matrix) {
	bit_array_fill_random(&bit_matrix.backing) }

_bit_matrix_fill :: proc(bit_matrix: ^Bit_Matrix, value: u8) {
	bit_array_fill(&bit_matrix.backing, value) }

_bit_matrix_rank :: proc(bit_matrix: ^Bit_Matrix, value: u8) -> (rank: u32) {
	return bit_array_rank(&bit_matrix.backing, value) }

// bit_matrix_write :: proc { _bit_matrix_write_bit, _bit_matrix_write_interval }

_bit_matrix_write_bit :: proc(bit_matrix: ^Bit_Matrix, index2: [2]u32, value: u8) {
	bit_array_write_bit(&bit_matrix.backing, index2_to_index(bit_matrix.shape, index2), value) }

// (TODO): This is limited by the size of the backing type. Implement a "copy" procedure to move an arbitrary number of bits. //
_bit_matrix_write_interval :: proc(bit_matrix: ^Bit_Matrix, first_index2: [2]u32, last_index2: [2]u32, value: Backing_Type) {
	range: [2]u32 = { cast(u32)index2_to_index(bit_matrix.shape, first_index2), cast(u32)index2_to_index(bit_matrix.shape, last_index2) + 1 }
	bit_array_write_chunk(&bit_matrix.backing, range, value) }

// bit_matrix_read :: proc { _bit_matrix_read_bit, _bit_matrix_read_interval }

_bit_matrix_read_bit :: proc(bit_matrix: ^Bit_Matrix, index2: [2]u32) -> u8 {
	return bit_array_read_bit(&bit_matrix.backing, index2_to_index(bit_matrix.shape, index2)) }

_bit_matrix_read_interval :: proc(bit_matrix: ^Bit_Matrix, first_index2: [2]u32, last_index2: [2]u32) -> Backing_Type {
	range: [2]u32 = { cast(u32)index2_to_index(bit_matrix.shape, first_index2), cast(u32)index2_to_index(bit_matrix.shape, last_index2) + 1 }
	return bit_array_read_chunk(&bit_matrix.backing, range) }

_aprint_bit_matrix :: proc(bit_matrix: ^Bit_Matrix, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, int((bit_matrix.shape.x + 1) * bit_matrix.shape.y), allocator)
	for i in 0 ..< bit_matrix.shape.x {
		for j in 0 ..< bit_matrix.shape.y do fmt.sbprint(&sb, _bit_matrix_read_bit(bit_matrix, { i, j }))
		fmt.sbprintln(&sb) }
	return strings.to_string(sb) }
