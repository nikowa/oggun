package bit_array
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"

@(test)
test :: proc(t: ^testing.T) {
	context.allocator = runtime.panic_allocator()

	data: u128 = 0b01100001110100000100100011001101001100100101010011110100111011111101010001000000000111000011010000101101100001011001001010000101
	ba: og.Bit_Array = og.make_bit_array(128, context.temp_allocator)
	for i in 0 ..< 128 do og.bit_array_write(&ba, i, u8(0b1 & (data >> uint(127 - i))))
	for i in 0 ..< 128 do testing.expect(t, og.bit_array_read(&ba, i) == u8(0b1 & (data >> uint(127 - i))))
	testing.expect(t, og.bit_array_read_chunk(&ba, {0, 28}) == 0b0110000111010000010010001100)
	testing.expect(t, og.bit_array_read_chunk(&ba, {12, 45}) == 0b000001001000110011010011001001010)
	testing.expect(t, og.bit_array_read_chunk(&ba, {48, 88}) == 0b1111010011101111110101000100000000011100)
	testing.expect(t, og.bit_array_read_chunk(&ba, {94, 128}) == 0b0000101101100001011001001010000101)
	testing.expect(t, og.bit_array_read_chunk(&ba, {64, 128}) == 0b1101010001000000000111000011010000101101100001011001001010000101)
	og.bit_array_clear_chunk(&ba, { 0, 8 })
	for i in 0 ..< 8 do testing.expect(t, og.bit_array_read(&ba, i) == 0)
	og.bit_array_clear_chunk(&ba, { 27, 35 })
	for i in 27 ..< 35 do testing.expect(t, og.bit_array_read(&ba, i) == 0)
	og.bit_array_clear_chunk(&ba, { 56, 64 })
	for i in 56 ..< 64 do testing.expect(t, og.bit_array_read(&ba, i) == 0)

	og.bit_array_fill_random(&ba)
	og.bit_array_write_chunk(&ba, { 8, 40 }, 0b11110111111101011001011000001011)
	testing.expect(t, og.bit_array_read_chunk(&ba, { 8, 40 }) == 0b11110111111101011001011000001011)

	og.bit_array_fill_random(&ba)
	og.bit_array_write_chunk(&ba, { 48, 80 }, 0b11110111111101011001011000001011)
	testing.expect(t, og.bit_array_read_chunk(&ba, { 48, 80 }) == 0b11110111111101011001011000001011)

	free_all(context.temp_allocator) }
