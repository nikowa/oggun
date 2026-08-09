#+feature using-stmt
package bit_matrix
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

	bm: Bit_Matrix
	err: runtime.Allocator_Error

	// Create random-shaped matrix //
	shape: [2]u32 = { rand.uint32_range(4, 32), rand.uint32_range(4, 32) }
	bm, err = make_bit_matrix(shape, context.temp_allocator)
	expect(err == nil)

	// Fill with random bits //
	expect(bit_matrix_size(&bm) == shape.x * shape.y)
	bit_matrix_fill_random(&bm)

	// Write/read round-test //
	for i in 0 ..< 32 {
		address: [2]u32 = { rand.uint32_max(bm.shape.x), rand.uint32_max(bm.shape.y) }
		value: u8 = cast(u8)rand.uint32_max(2)
		bit_matrix_write_bit(&bm, address, value)
		expect(bit_matrix_read_bit(&bm, address) == value) }

	rk := bit_matrix_rank(&bm, 1)
	expect(rk == bit_matrix_size(&bm) - bit_matrix_rank(&bm, 0))
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do rk -= cast(u32)bit_matrix_read_bit(&bm, [2]u32{ i, j })
	expect(rk == 0)
	bm2: Bit_Matrix
	bm2, err = clone_bit_matrix(&bm, context.temp_allocator)
	expect(err == nil)
	for word, i in bm2.backing.buffer do expect(bm.backing.buffer[i] == word)

	// Fill with 0s //
	bit_matrix_fill(&bm, 0)
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(bit_matrix_read_bit(&bm, [2]u32{ i, j }) == 0)

	// Fill with 1s //
	bit_matrix_fill(&bm, 1)
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(bit_matrix_read_bit(&bm, [2]u32{ i, j }) == 1)

	free_all(context.temp_allocator) }
