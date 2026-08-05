#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

@(overload_type)
TMatrix :: struct($T: typeid) {
    shape: u32,
    backing: []T }

make_tmatrix :: proc($T: typeid, shape: u32, allocator := context.allocator, loc := #caller_location) -> (mx: TMatrix(T), err: runtime.Allocator_Error) #optional_allocator_error {
	mx.shape = shape
	mx.backing, err = make([]T, triangular_size(shape), allocator, loc)
	return mx, err }

@(overload="clone")
clone_tmatrix :: proc(mx: ^TMatrix($T), allocator := context.allocator) -> (TMatrix(T), runtime.Allocator_Error) #optional_allocator_error {
	backing, err := slice.clone(&mx.backing, allocator)
	return { shape = mx.shape, backing = backing }, err }

@(overload="size")
tmatrix_size :: proc(mx: ^TMatrix($T)) -> u32 {
	return triangular_size(mx.shape) }

@(overload="fill")
tmatrix_fill :: proc(mx: ^TMatrix($T), value: T) {
	for &cell in mx.backing do cell = value }

@(overload="rank")
tmatrix_rank :: proc(mx: ^TMatrix($T), value: T) -> (rank: u32) {
	for &cell in mx.backing do if cell == value do rank += 1
	if value == T({}) do rank += triangular_size_complement(mx.shape)
	return rank }

@(overload="write")
tmatrix_write :: proc(mx: ^TMatrix($T), index2: [2]u32, value: T) {
	mx.backing[index2_to_index_triangular(mx.shape, index2)] = value }

@(overload="read")
tmatrix_read :: proc(mx: ^TMatrix($T), index2: [2]u32) -> T {
	return mx.backing[index2_to_index_triangular(mx.shape, index2)] }

@(overload="aprint")
aprint_tmatrix :: proc(mx: ^TMatrix($T), allocator := context.allocator) -> string {
	sb := strings.builder_make(allocator)
	for i in 0 ..< mx.shape.x {
		for j in 0 ..< mx.shape.y do fmt.sbprintf(&sb, "%v ", _matrix_read(mx, { i, j }))
		fmt.sbprintln(&sb) }
	return strings.to_string(sb) }
