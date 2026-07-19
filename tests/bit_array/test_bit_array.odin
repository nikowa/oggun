#+feature using-stmt
package bit_array
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"

@(test)
test :: proc(t: ^testing.T) {
	using og

	context.allocator = runtime.panic_allocator()

	data: u128 = 0b01100001110100000100100011001101001100100101010011110100111011111101010001000000000111000011010000101101100001011001001010000101
	ba: Bit_Array = make_bit_array(128, context.temp_allocator)
	for i in 0 ..< 128 do write(&ba, i, u8(0b1 & (data >> uint(127 - i))))
	for i in 0 ..< 128 do expect(read(&ba, i) == u8(0b1 & (data >> uint(127 - i))))
	expect(read(&ba, [2]u32{0, 28}) == 0b0110000111010000010010001100)
	expect(read(&ba, [2]u32{12, 45}) == 0b000001001000110011010011001001010)
	expect(read(&ba, [2]u32{48, 88}) == 0b1111010011101111110101000100000000011100)
	expect(read(&ba, [2]u32{94, 128}) == 0b0000101101100001011001001010000101)
	expect(read(&ba, [2]u32{64, 128}) == 0b1101010001000000000111000011010000101101100001011001001010000101)
	zero(&ba, [2]u32{ 0, 8 })
	for i in 0 ..< 8 do expect(read(&ba, i) == 0)
	zero(&ba, [2]u32{ 27, 35 })
	for i in 27 ..< 35 do expect(read(&ba, i) == 0)
	zero(&ba, [2]u32{ 56, 64 })
	for i in 56 ..< 64 do expect(read(&ba, i) == 0)

	fill_random(&ba)
	write(&ba, [2]u32{ 8, 40 }, 0b11110111111101011001011000001011)
	expect(read(&ba, [2]u32{ 8, 40 }) == 0b11110111111101011001011000001011)

	fill_random(&ba)
	write(&ba, [2]u32{ 48, 80 }, 0b11110111111101011001011000001011)
	expect(read(&ba, [2]u32{ 48, 80 }) == 0b11110111111101011001011000001011)

	free_all(context.temp_allocator) }
