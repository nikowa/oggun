#+feature using-stmt
package micro_pair
import rt "base:runtime"
import fmt "core:fmt"
import mb "core:math/bits"



Micro_Pair :: [2]u32

EMPTY :: mb.U32_MAX

make_micro_pair :: #force_inline proc "contextless" () -> (micro_pair: Micro_Pair) {
	return { EMPTY, EMPTY } }

len :: #force_inline proc "contextless" (micro_pair: Micro_Pair) -> int {
	return (micro_pair[0] == EMPTY ? 1 : 0) + (micro_pair[1] == EMPTY ? 1 : 0) }

add :: proc { add_by_index, add_by_ptr }

add_by_index :: #force_inline proc "contextless" (micro_pair: Micro_Pair, #any_int elem: int) -> (result: Micro_Pair, ok: bool) #optional_ok {
	micro_pair := micro_pair
	_elem: u32 = cast(u32)elem
	if micro_pair[0] == EMPTY do micro_pair[0] = _elem
	else if micro_pair[1] == EMPTY do micro_pair[1] = _elem
	else do return micro_pair, false
	return micro_pair, true }

add_by_ptr :: #force_inline proc "contextless" (micro_pair: Micro_Pair, array: []$T, elem: ^T) -> (result: Micro_Pair, ok: bool) #optional_ok {
	return add_by_index(micro_pair, cast(int)((cast(uintptr)elem - cast(uintptr)(&array[0])) / size_of(T))) }

remove :: proc { remove_by_index, remove_by_ptr }

remove_by_index :: #force_inline proc "contextless" (micro_pair: Micro_Pair, #any_int elem: int) -> (result: Micro_Pair, ok: bool) #optional_ok {
	micro_pair := micro_pair
	_elem: u32 = cast(u32)elem
	if micro_pair[0] == _elem do micro_pair[0] = EMPTY
	else if micro_pair[1] == _elem do micro_pair[1] = EMPTY
	else do return micro_pair, false
	return micro_pair, true }

remove_by_ptr :: #force_inline proc "contextless" (micro_pair: Micro_Pair, array: []$T, elem: ^T) -> (result: Micro_Pair, ok: bool) #optional_ok {
	return remove_by_index(micro_pair, cast(int)((cast(uintptr)elem - cast(uintptr)(&array[0])) / size_of(T))) }

remove_at :: #force_inline proc "contextless" (micro_pair: Micro_Pair, #any_int index: int) -> (result: Micro_Pair) {
	micro_pair := micro_pair
	micro_pair[index] = EMPTY
	return micro_pair }

get_at :: #force_inline proc "contextless" (micro_pair: Micro_Pair, array: []$T, #any_int index: int) -> (elem: T, ok: bool) {
	if micro_pair[index] == EMPTY do return {}, false
	return array[micro_pair[index]], true }

get_at_ptr :: #force_inline proc "contextless" (micro_pair: Micro_Pair, array: []$T, #any_int index: int) -> (elem: ^T, ok: bool) {
	if micro_pair[index] == EMPTY do return {}, false
	return &array[micro_pair[index]], true }

from_rawptr :: #force_inline proc "contextless" (micro_pair: rawptr) -> Micro_Pair {
	return transmute(Micro_Pair)micro_pair }

to_rawptr :: #force_inline proc "contextless" (micro_pair: Micro_Pair) -> rawptr {
	return transmute(rawptr)micro_pair }

from_rawptr_ptr :: #force_inline proc "contextless" (micro_pair: ^rawptr) -> ^Micro_Pair {
	return cast(^Micro_Pair)micro_pair }

is_empty :: #force_inline proc "contextless" (micro_pair: Micro_Pair) -> bool {
	return (micro_pair[0] == EMPTY) && (micro_pair[1] == EMPTY) }
