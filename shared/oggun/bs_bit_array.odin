#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

Backing_Type :: uint
BIT_ARRAY_W: u32 : 8 * size_of(Backing_Type)

Bit_Array :: struct {
	len: u32,
	buffer: []Backing_Type }

make_bit_array :: proc { make_bit_array_allocate, make_bit_array_view }

make_bit_array_allocate :: proc(#any_int len: u32, allocator := context.allocator, loc := #caller_location) -> (array: Bit_Array, err: runtime.Allocator_Error) #optional_allocator_error {
	array.len = u32(len)
	array.buffer, err = make([]Backing_Type, (len % BIT_ARRAY_W == 0) ? (len / BIT_ARRAY_W) : len / BIT_ARRAY_W + 1, allocator)
	return array, err }

make_bit_array_view :: proc(#any_int len: u32, buffer: []Backing_Type) -> (array: Bit_Array, err: runtime.Allocator_Error) #optional_allocator_error {
	if slice.length(buffer) == 0 do return {}, .Out_Of_Memory
	array.len = u32(len)
	array.buffer = buffer
	return array, nil }

clone_bit_array :: proc(array: ^Bit_Array, allocator := context.allocator) -> (Bit_Array, runtime.Allocator_Error) #optional_allocator_error {
	buffer, err := slice.clone(array.buffer, allocator)
	return { len = array.len, buffer = buffer }, err }

bit_array_fill_random :: proc(array: ^Bit_Array) {
	for i in 0 ..< array.len do bit_array_write_bit(array, i, cast(u8)rand.uint32_max(2)) }

bit_array_fill :: proc(array: ^Bit_Array, value: u8) {
	word: Backing_Type = (value == 0) ? Backing_Type(0) : ~Backing_Type(0)
	for i in 0 ..< len(array.buffer) do array.buffer[i] = word }

bit_array_rank :: proc(array: ^Bit_Array, value: u8) -> (rank: u32) {
	if value == 1 do for i in 0 ..< array.len do rank += cast(u32)bit_array_read_bit(array, i)
	else do for i in 0 ..< array.len do rank += 1 - cast(u32)bit_array_read_bit(array, i)
	return rank }

aprint_bit_array :: proc(array: ^Bit_Array, split_words := false, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, int(array.len + (array.len / cast(u32)BIT_ARRAY_W)), allocator)
	for i in 0 ..< array.len {
		if split_words do if cast(u32)i % BIT_ARRAY_W == 0 do fmt.sbprint(&sb, ' ')
		fmt.sbprint(&sb, bit_array_read_bit(array, i)) }
	return strings.to_string(sb) }

delete_bit_array :: proc(array: ^Bit_Array, allocator := context.allocator) {
	delete(array.buffer, allocator)
	array.len = 0 }

bit_array_equal :: proc(array0, array1: ^Bit_Array) -> bool {
	if array0.len != array1.len do return false
	return slice.equal(array0.buffer, array1.buffer) }

bit_array_set :: proc(array: ^Bit_Array, #any_int j: u32) {
	array.buffer[j / BIT_ARRAY_W] |= 0b1 << (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W)) }

bit_array_zero :: proc { bit_array_zero_bit, bit_array_zero_chunk }

bit_array_zero_bit :: proc(array: ^Bit_Array, #any_int j: u32) {
	array.buffer[j / BIT_ARRAY_W] &= ~ (0b1 << (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W))) }

bit_array_zero_chunk :: proc(array: ^Bit_Array, range: [2]u32) {
	n := range[1] - range[0]
	mask: Backing_Type = ((0b1 << n) - 1) << (BIT_ARRAY_W - n - (range[0]  % BIT_ARRAY_W))
	array.buffer[range[0] / BIT_ARRAY_W] &= ~ mask }

bit_array_read :: proc { bit_array_read_bit, bit_array_read_chunk }

bit_array_read_bit :: proc(array: ^Bit_Array, #any_int j: u32) -> u8 {
	runtime.bounds_check_error_loc(index=cast(int)j, count=cast(int)array.len)
	return u8(0b1 & (array.buffer[j / BIT_ARRAY_W] >> (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W)))) }

@private _bit_array_read_chunk :: proc(array: ^Bit_Array, range: [2]u32) -> (result: Backing_Type) {
	n := range[1] - range[0]
	assert(n <= BIT_ARRAY_W)
	assert(range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W)
	i := range[0] / BIT_ARRAY_W
	result = (array.buffer[i] >> ((BIT_ARRAY_W - range[1]) % BIT_ARRAY_W))
	if n < BIT_ARRAY_W do result %= (cast(Backing_Type)0b1 << n)
	return result }

bit_array_read_chunk :: proc(array: ^Bit_Array, range: [2]u32) -> Backing_Type {
	runtime.bounds_check_error_loc(index=cast(int)range[1]-1, count=cast(int)array.len)
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	if range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W {
		return _bit_array_read_chunk(array, range) }
	else {
		hi_range: [2]u32 = { range[0], range[1] - range[1] % BIT_ARRAY_W }
		lo_range: [2]u32 = { range[1] - range[1] % BIT_ARRAY_W, range[1] }
		hi := _bit_array_read_chunk(array, hi_range)
		lo := _bit_array_read_chunk(array, lo_range)
		return (hi << (lo_range[1] - lo_range[0])) | lo } }

bit_array_write :: proc { bit_array_write_bit, bit_array_write_chunk }

bit_array_write_bit :: proc(array: ^Bit_Array, #any_int j: u32, value: u8) {
	runtime.bounds_check_error_loc(index=cast(int)j, count=cast(int)array.len)
	if cast(bool)value do bit_array_set(array, j)
	else do bit_array_zero_bit(array, j) }

@private __bit_array_write_chunk :: proc(array: ^Bit_Array, range: [2]u32, value: Backing_Type) {
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	assert(range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W)
	bit_array_zero_chunk(array, range)
	n := range[1] - range[0]
	i := range[0] / BIT_ARRAY_W
	array.buffer[i] |= value << ((BIT_ARRAY_W - range[1]) % BIT_ARRAY_W) }

bit_array_write_chunk :: proc(array: ^Bit_Array, range: [2]u32, value: Backing_Type) {
	runtime.bounds_check_error_loc(index=cast(int)range[1]-1, count=cast(int)array.len)
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	if range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W {
		__bit_array_write_chunk(array, range, value) }
	else {
		hi_range: [2]u32 = { range[0], range[1] - range[1] % BIT_ARRAY_W }
		lo_range: [2]u32 = { range[1] - range[1] % BIT_ARRAY_W, range[1] }
		hi := value >> (lo_range[1] - lo_range[0])
		lo := value % (0b1 << (lo_range[1] - lo_range[0]))
		__bit_array_write_chunk(array, hi_range, hi)
		__bit_array_write_chunk(array, lo_range, lo) } }

bit_array_or :: proc { _bit_array_or_ref, _bit_array_or_make }

_bit_array_or_ref :: proc(a, b: Bit_Array, result: ^Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	n := len(a.buffer)
	for i in 0 ..< n do result.buffer[i] = a.buffer[i] | b.buffer[i] }

_bit_array_or_make :: proc(a, b: Bit_Array, allocator := context.allocator) -> (result: Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	result = make_bit_array(a.len, allocator)
	_bit_array_or_ref(a, b, &result)
	return result }

bit_array_xor :: proc { _bit_array_xor_ref, _bit_array_xor_make }

_bit_array_xor_ref :: proc(a, b: Bit_Array, result: ^Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	n := len(a.buffer)
	for i in 0 ..< n do result.buffer[i] = a.buffer[i] ~ b.buffer[i] }

_bit_array_xor_make :: proc(a, b: Bit_Array, allocator := context.allocator) -> (result: Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	result = make_bit_array(a.len, allocator)
	_bit_array_xor_ref(a, b, &result)
	return result }

bit_array_and :: proc { _bit_array_and_ref, _bit_array_and_make }

_bit_array_and_ref :: proc(a, b: Bit_Array, result: ^Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	n := len(a.buffer)
	for i in 0 ..< n do result.buffer[i] = a.buffer[i] & b.buffer[i] }

_bit_array_and_make :: proc(a, b: Bit_Array, allocator := context.allocator) -> (result: Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	result = make_bit_array(a.len, allocator)
	_bit_array_and_ref(a, b, &result)
	return result }

bit_array_and_not :: proc { _bit_array_and_not_ref, _bit_array_and_not_make }

_bit_array_and_not_ref :: proc(a, b: Bit_Array, result: ^Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	n := len(a.buffer)
	for i in 0 ..< n do result.buffer[i] = a.buffer[i] &~ b.buffer[i] }

_bit_array_and_not_make :: proc(a, b: Bit_Array, allocator := context.allocator) -> (result: Bit_Array) {
	assert(len(a.buffer) == len(b.buffer))
	result = make_bit_array(a.len, allocator)
	_bit_array_and_not_ref(a, b, &result)
	return result }

bit_array_not :: proc { _bit_array_not_ref, _bit_array_not_make }

_bit_array_not_ref :: proc(bit_array: Bit_Array, result: ^Bit_Array) {
	n := len(bit_array.buffer)
	for i in 0 ..< n do result.buffer[i] = ~bit_array.buffer[i] }

_bit_array_not_make :: proc(bit_array: Bit_Array, allocator := context.allocator) -> (result: Bit_Array) {
	result = make_bit_array(bit_array.len, allocator)
	_bit_array_not_ref(bit_array, &result)
	return result }
