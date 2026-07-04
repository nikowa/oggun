#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:math/rand"
import "core:strings"
import "core:slice"

Backing_Type :: uint
BIT_ARRAY_W: uint : 8 * size_of(Backing_Type)

Bit_Array :: struct {
	len: u32,
	buffer: []Backing_Type }

make_bit_array :: proc(#any_int len: uint, allocator := context.allocator, loc := #caller_location) -> (array: Bit_Array, err: runtime.Allocator_Error) #optional_allocator_error {
	array.len = u32(len)
	array.buffer, err = make([]Backing_Type, len / BIT_ARRAY_W + 1, allocator)
	return array, err }

clone_bit_array :: proc(array: ^Bit_Array, allocator := context.allocator) -> (Bit_Array, runtime.Allocator_Error) #optional_allocator_error {
	buffer, err := slice.clone(array.buffer, allocator)
	return { len = array.len, buffer = buffer }, err }

bit_array_fill_random :: proc(array: ^Bit_Array) {
	for i in 0 ..< array.len do bit_array_write(array, i, cast(u8)rand.uint32_max(2)) }

aprint_bit_array :: proc(array: ^Bit_Array, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, cast(int)array.len, allocator)
	for i in 0 ..< array.len do fmt.sbprint(&sb, bit_array_read(array, i))
	return strings.to_string(sb) }

aprint_bit_array_ext :: proc(array: ^Bit_Array, allocator := context.allocator) -> string {
	sb := strings.builder_make_len_cap(0, int(array.len + (array.len / cast(u32)BIT_ARRAY_W)), allocator)
	for i in 0 ..< array.len {
		if cast(uint)i % BIT_ARRAY_W == 0 do fmt.sbprint(&sb, ' ')
		fmt.sbprint(&sb, bit_array_read(array, i)) }
	return strings.to_string(sb) }

@(deprecated="untested")
delete_bit_array :: proc(array: ^Bit_Array) {
	delete(array.buffer) }

bit_array_read :: proc { bit_array_read_bit, bit_array_read_chunk }

bit_array_write :: proc { bit_array_write_bit }

bit_array_read_bit :: proc(array: ^Bit_Array, #any_int j: uint) -> u8 {
	return u8(0b1 & (array.buffer[j / BIT_ARRAY_W] >> (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W)))) }

bit_array_set :: proc(array: ^Bit_Array, #any_int j: uint) {
	array.buffer[j / BIT_ARRAY_W] |= 0b1 << (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W)) }

bit_array_clear :: proc(array: ^Bit_Array, #any_int j: uint) {
	array.buffer[j / BIT_ARRAY_W] &= ~ (0b1 << (BIT_ARRAY_W - 1 - (j % BIT_ARRAY_W))) }

bit_array_clear_chunk :: proc(array: ^Bit_Array, range: [2]uint) {
	n := range[1] - range[0]
	mask: Backing_Type = ((0b1 << n) - 1) << (BIT_ARRAY_W - n - (range[0]  % BIT_ARRAY_W))
	array.buffer[range[0] / BIT_ARRAY_W] &= ~ mask }

bit_array_write_bit :: proc(array: ^Bit_Array, #any_int j: uint, value: u8) {
	if cast(bool)value do bit_array_set(array, j)
	else do bit_array_clear(array, j) }

@private _bit_array_read_chunk :: proc(array: ^Bit_Array, range: [2]uint) -> (result: Backing_Type) {
	n := range[1] - range[0]
	assert(n <= BIT_ARRAY_W)
	assert(range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W)
	i := range[0] / BIT_ARRAY_W
	result = (array.buffer[i] >> ((BIT_ARRAY_W - range[1]) % BIT_ARRAY_W))
	if n < BIT_ARRAY_W do result %= (cast(Backing_Type)0b1 << n)
	return result }

bit_array_read_chunk :: proc(array: ^Bit_Array, range: [2]uint) -> Backing_Type {
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	if range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W {
		return _bit_array_read_chunk(array, range) }
	else {
		hi_range: [2]uint = { range[0], range[1] - range[1] % BIT_ARRAY_W }
		lo_range: [2]uint = { range[1] - range[1] % BIT_ARRAY_W, range[1] }
		hi := _bit_array_read_chunk(array, hi_range)
		lo := _bit_array_read_chunk(array, lo_range)
		return (hi << (lo_range[1] - lo_range[0])) | lo } }

@private _bit_array_write_chunk :: proc(array: ^Bit_Array, range: [2]uint, value: Backing_Type) {
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	assert(range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W)
	bit_array_clear_chunk(array, range)
	n := range[1] - range[0]
	i := range[0] / BIT_ARRAY_W
	array.buffer[i] |= value << ((BIT_ARRAY_W - range[1]) % BIT_ARRAY_W) }

bit_array_write_chunk :: proc(array: ^Bit_Array, range: [2]uint, value: Backing_Type) {
	assert(range[1] - range[0] <= BIT_ARRAY_W)
	if range[0] / BIT_ARRAY_W == (range[1] - 1) / BIT_ARRAY_W {
		_bit_array_write_chunk(array, range, value) }
	else {
		hi_range: [2]uint = { range[0], range[1] - range[1] % BIT_ARRAY_W }
		lo_range: [2]uint = { range[1] - range[1] % BIT_ARRAY_W, range[1] }
		hi := value >> (lo_range[1] - lo_range[0])
		lo := value % (0b1 << (lo_range[1] - lo_range[0]))
		_bit_array_write_chunk(array, hi_range, hi)
		_bit_array_write_chunk(array, lo_range, lo) } }
