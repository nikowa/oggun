#+feature using-stmt
package bit_array
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"

@(test)
test :: proc(t: ^testing.T) {
	using og

	context.allocator = runtime.panic_allocator()
	context.user_ptr = t

	err: runtime.Allocator_Error

	data: u128 = 0b01100001110100000100100011001101001100100101010011110100111011111101010001000000000111000011010000101101100001011001001010000101
	ba: Bit_Array
	ba, err = make_bit_array_allocate(128, context.temp_allocator)
	expect(len(ba.buffer) == 128 / 8 / size_of(Backing_Type))
	expect(err == nil)

	for i in 0 ..< 128 do bit_array_write_bit(&ba, i, u8(0b1 & (data >> uint(127 - i))))
	for i in 0 ..< 128 do expect(bit_array_read_bit(&ba, i) == u8(0b1 & (data >> uint(127 - i))))

	ba1: Bit_Array
	ba1, err = make_bit_array_view(ba.len, ba.buffer)
	expect(err == nil)
	expect(&ba.buffer[0] == &ba1.buffer[0])
	expect(bit_array_equal(&ba, &ba1))

	ba2: Bit_Array
	ba2, err = clone_bit_array(&ba, context.temp_allocator)
	expect(err == nil)
	expect(bit_array_equal(&ba, &ba2))

	for j in 0 ..= 1 {
		bit_array_fill(&ba2, auto_cast j)
		for i in 0 ..< ba2.len do expect(bit_array_read_bit(&ba2, i) == auto_cast j) }

	bit_array_fill_random(&ba2)
	aprint_bit_array(&ba2, allocator=context.temp_allocator)

	rank0, rank1: u32
	for i in 0 ..< ba2.len do switch bit_array_read_bit(&ba2, i) {
	case 0: rank0 += 1
	case 1: rank1 += 1 }
	expect(bit_array_rank(&ba2, 0) == rank0)
	expect(bit_array_rank(&ba2, 1) == rank1)

	ba3 := make_bit_array_allocate(ba2.len, context.temp_allocator)
	for i in 0 ..< ba2.len do if bit_array_read_bit(&ba2, i) == 1 do bit_array_set(&ba3, i)
	expect(bit_array_equal(&ba2, &ba3))

	bit_array_fill(&ba3, 1)
	for i in 0 ..< ba2.len do if bit_array_read_bit(&ba2, i) == 0 do bit_array_zero_bit(&ba3, i)
	expect(bit_array_equal(&ba2, &ba3))

	// (TODO): This sometimes fails. Figure out why. //
	lo := rand.int32_range(0, 128)
	hi := rand.int32_range(lo, min(lo + 8 * size_of(Backing_Type), 129))
	log.warn(lo, hi)
	bit_array_zero_chunk(&ba3, [2]u32{ u32(lo), u32(hi) })
	for i in lo ..< hi do expect(bit_array_read_bit(&ba3, i) == 0)

	expect(bit_array_read_chunk(&ba, [2]u32{0, 28}) == 0b0110000111010000010010001100)
	expect(bit_array_read_chunk(&ba, [2]u32{12, 45}) == 0b000001001000110011010011001001010)
	expect(bit_array_read_chunk(&ba, [2]u32{48, 88}) == 0b1111010011101111110101000100000000011100)
	expect(bit_array_read_chunk(&ba, [2]u32{94, 128}) == 0b0000101101100001011001001010000101)
	expect(bit_array_read_chunk(&ba, [2]u32{64, 128}) == 0b1101010001000000000111000011010000101101100001011001001010000101)
	zero(&ba, [2]u32{ 0, 8 })
	for i in 0 ..< 8 do expect(bit_array_read_bit(&ba, i) == 0)
	zero(&ba, [2]u32{ 27, 35 })
	for i in 27 ..< 35 do expect(bit_array_read_bit(&ba, i) == 0)
	zero(&ba, [2]u32{ 56, 64 })
	for i in 56 ..< 64 do expect(bit_array_read_bit(&ba, i) == 0)

	fill_random(&ba)
	bit_array_write_chunk(&ba, [2]u32{ 8, 40 }, 0b11110111111101011001011000001011)
	expect(bit_array_read_chunk(&ba, [2]u32{ 8, 40 }) == 0b11110111111101011001011000001011)

	fill_random(&ba)
	bit_array_write_chunk(&ba, [2]u32{ 48, 80 }, 0b11110111111101011001011000001011)
	expect(bit_array_read_chunk(&ba, [2]u32{ 48, 80 }) == 0b11110111111101011001011000001011)

	delete_bit_array(&ba, allocator=context.temp_allocator)
	expect(ba.len == 0)

	free_all(context.temp_allocator) }
