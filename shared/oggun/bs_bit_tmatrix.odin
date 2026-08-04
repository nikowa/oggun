#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

Bit_TMatrix :: struct {
	shape: u32,
	backing: Bit_Array }

make_bit_tmatrix :: proc(shape: u32, allocator := context.allocator, loc := #caller_location) -> (bit_tmatrix: Bit_TMatrix, err: runtime.Allocator_Error) #optional_allocator_error {
	bit_tmatrix.shape = shape
	bit_tmatrix.backing, err = make_bit_array(shape * shape, allocator, loc)
	return bit_tmatrix, err }

clone_bit_tmatrix :: proc(bit_tmatrix: ^Bit_TMatrix, allocator := context.allocator) -> (Bit_TMatrix, runtime.Allocator_Error) #optional_allocator_error {
	backing, err := _clone_bit_array(&bit_tmatrix.backing, allocator)
	return { shape = bit_tmatrix.shape, backing = backing }, err }

bit_tmatrix_size :: proc(bit_tmatrix: ^Bit_TMatrix) -> u32 {
	return (bit_tmatrix.shape) * (bit_tmatrix.shape + 1) / 2 }

bit_tmatrix_fill_random :: proc(bit_tmatrix: ^Bit_TMatrix) {
	_bit_array_fill_random(&bit_tmatrix.backing) }

bit_tmatrix_fill :: proc(bit_tmatrix: ^Bit_TMatrix, value: u8) {
	_bit_array_fill(&bit_tmatrix.backing, value) }

bit_tmatrix_rank :: proc(bit_tmatrix: ^Bit_TMatrix, value: u8) -> (rank: u32) {
	return _bit_array_rank(&bit_tmatrix.backing, value) }

bit_tmatrix_write :: proc(bit_tmatrix: ^Bit_TMatrix, index2: [2]u32, value: u8) {
	if index.y > index.x do return
	_bit_array_write_bit(&bit_tmatrix.backing, index2_to_index_triangular(bit_tmatrix.shape, index2), value) }

bit_tmatrix_read :: proc(bit_tmatrix: ^Bit_TMatrix, index2: [2]u32) -> u8 {
	if index.y > index.x do return 0
	return _bit_array_read_bit(&bit_tmatrix.backing, index2_to_index_triangular(bit_tmatrix.shape, index2)) }

aprint_bit_tmatrix :: proc(bit_tmatrix: ^Bit_TMatrix, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, int((bit_tmatrix.shape + 1) * bit_tmatrix.shape), allocator)
	for i in 0 ..< bit_tmatrix.shape {
		for j in 0 ..< bit_tmatrix.shape do fmt.sbprint(&sb, _bit_tmatrix_read_bit(bit_tmatrix, { i, j }))
		fmt.sbprintln(&sb) }
	return strings.to_string(sb) }
