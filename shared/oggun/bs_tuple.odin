#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"
import "core:relative"
import "core:math/bits"

Tuple :: struct($E: typeid, $U: typeid, $B: typeid) {
	indexes: []Index([]E, U),
	len: B }

make_tuple :: proc { make_tuple_len, make_tuple_len_cap, make_tuple_from_ptrs, make_tuple_from_indexes }

make_tuple_len :: proc($E: typeid, $U: typeid, $B: typeid, #any_int len: u8, allocator := context.allocator, loc := #caller_location) -> (tuple: Tuple(E, U, B), err: runtime.Allocator_Error) #optional_allocator_error {
	return make_tuple_len_cap(E, U, B, len, len, allocator, loc) }

make_tuple_len_cap :: proc($E: typeid, $U: typeid, $B: typeid, #any_int len: u8, #any_int cap: u8, allocator := context.allocator, loc := #caller_location) -> (tuple: Tuple(E, U, B), err: runtime.Allocator_Error) #optional_allocator_error {
	tuple.indexes, err = make([]Index([]E, U), cap, allocator)
	for &index in tuple.indexes do index = make_index([]E, U)
	tuple.len = len
	return tuple, err }

make_tuple_from_ptrs :: proc($E: typeid, $U: typeid, $B: typeid, ptrs: []^E, universe: []E, allocator := context.allocator, loc := #caller_location) -> (tuple: Tuple(E, U, B), err: runtime.Allocator_Error) #optional_allocator_error {
	tuple, err = make_tuple_len_cap(E, U, B, 0, len(ptrs), allocator, loc)
	if err != nil do return tuple, err
	for elem in ptrs do tuple_append_by_ptr(&tuple, elem, universe, loc)
	return tuple, err }

make_tuple_from_indexes :: proc($E: typeid, $U: typeid, $B: typeid, indexes: []U, universe: []E, allocator := context.allocator, loc := #caller_location) -> (tuple: Tuple(E, U, B), err: runtime.Allocator_Error) #optional_allocator_error {
	tuple, err = make_tuple_len_cap(E, U, B, 0, len(indexes), allocator, loc)
	if err != nil do return tuple, err
	for index in indexes do tuple_append_by_index(&tuple, auto_cast index, universe, loc)
	return tuple, err }

delete_tuple :: proc(tuple: ^Tuple($E, $U, $B), allocator := context.allocator, loc := #caller_location) -> (err: runtime.Allocator_Error) {
	return delete(tuple.indexes, allocator, loc) }

tuple_append :: proc { tuple_append_by_ptr, tuple_append_by_index }

tuple_append_by_ptr :: proc "contextless" (tuple: ^Tuple($E, $U, $B), arg: ^E, universe: []E, loc := #caller_location) -> (n: int, err: runtime.Allocator_Error) #optional_allocator_error {
	if cast(int)tuple.len >= len(tuple.indexes) do return 0, .Out_Of_Memory
	index_set(&tuple.indexes[tuple.len], universe, arg)
	tuple.len += 1
	return 1, nil }

// (TODO): "index" param should have type "U".
tuple_append_by_index :: proc "contextless" (tuple: ^Tuple($E, $U, $B), index: int, universe: []E, loc := #caller_location) -> (n: int, err: runtime.Allocator_Error) #optional_allocator_error {
	if index < 0 || index >= len(universe) do return 0, .Invalid_Argument
	return tuple_append_by_ptr(tuple, &universe[index], universe, loc) }

tuple_get :: proc "contextless" (tuple: ^Tuple($E, $U, $B), universe: []E, i: B) -> (elem: ^E, ok: bool) #optional_ok {
	if i >= tuple.len do return nil, false
	return index_get(&tuple.indexes[i], universe) }

tuple_set :: proc { tuple_set_by_ptr, tuple_set_by_index }

tuple_set_by_index :: proc "contextless" (tuple: ^Tuple($E, $U, $B), i: B, index: int, universe: []E, loc := #caller_location) {
	if i < 0 || i >= cast(B)len(universe) do return
	index_set(&tuple.indexes[i], universe, &universe[index]) }

tuple_set_by_ptr :: proc "contextless" (tuple: ^Tuple($E, $U, $B), i: B, arg: ^E, universe: []E) {
	if i < 0 || i >= cast(B)len(universe) do return
	index_set(&tuple.indexes[i], universe, arg) }

tuple_len :: proc "contextless" (tuple: ^Tuple($E, $U, $B)) -> int {
	return cast(int)tuple.len }

tuple_cap :: proc "contextless" (tuple: ^Tuple($E, $U, $B)) -> int {
	return len(tuple.indexes) }

tuple_iterate :: proc "contextless" (tuple: ^Tuple($E, $U, $B), universe: []E, i: ^B) -> (elem: ^E, ok: bool) {
	elem, ok = tuple_get(tuple, universe, i^)
	i^ += 1
	return elem, ok }
