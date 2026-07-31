#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

@(overload_type)
Matrix :: struct($T: typeid) {
    shape: [2]u32,
    backing: []T }

make_matrix :: proc($T: typeid, shape: [2]u32, allocator := context.allocator, loc := #caller_location) -> (mx: Matrix(T), err: runtime.Allocator_Error) #optional_allocator_error {
	mx.shape = shape
	mx.backing, err = make([]T, shape.x * shape.y, allocator, loc)
	return mx, err }

@(overload="clone")
_clone_matrix :: proc(mx: ^Matrix($T), allocator := context.allocator) -> (Matrix(T), runtime.Allocator_Error) #optional_allocator_error {
	backing, err := slice.clone(&mx.backing, allocator)
	return { shape = mx.shape, backing = backing }, err }

@(overload="size")
_matrix_size :: proc(mx: ^Matrix($T)) -> u32 {
	return mx.shape.x * mx.shape.y }

@(overload="fill")
_matrix_fill :: proc(mx: ^Matrix($T), value: T) {
	for &cell in mx.backing do cell = value }

@(overload="rank")
_matrix_rank :: proc(mx: ^Matrix($T), value: T) -> (rank: u32) {
	for &cell in mx.backing do if cell == value do rank += 1
	return rank }

@(overload="write")
_matrix_write :: proc(mx: ^Matrix($T), index2: [2]u32, value: T) {
	mx.backing[index2_to_index(mx.shape, index2)] = value }

@(overload="read")
_matrix_read :: proc(mx: ^Matrix($T), index2: [2]u32) -> T {
	return mx.backing[index2_to_index(mx.shape, index2)] }

@(overload="aprint")
_aprint_matrix :: proc(mx: ^Matrix($T), allocator := context.allocator) -> string {
	sb := strings.builder_make(allocator)
	for i in 0 ..< mx.shape.x {
		for j in 0 ..< mx.shape.y do fmt.sbprintf(&sb, "%v ", _matrix_read(mx, { i, j }))
		fmt.sbprintln(&sb) }
	return strings.to_string(sb) }
