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

	// Diff testing //
	shape: [2]u32 = { rand.uint32_range(4, 32), rand.uint32_range(4, 32) }
	bm, err = make_bit_matrix(shape, context.temp_allocator)
	expect(err == nil)
	expect(size(&bm) == shape.x * shape.y)
	fill_random(&bm)
	// log.infof("\n%s", aprint_bit_matrix(&bm, context.temp_allocator))
	for i in 0 ..< 32 {
		address: [2]u32 = { rand.uint32_max(bm.shape.x), rand.uint32_max(bm.shape.y) }
		value: u8 = cast(u8)rand.uint32_max(2)
		write(&bm, address, value)
		expect(read(&bm, address) == value) }
	rk := rank(&bm, 1)
	expect(rk == size(&bm) - rank(&bm, 0))
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do rk -= cast(u32)read(&bm, [2]u32{ i, j })
	expect(rk == 0)
	bm2: Bit_Matrix
	bm2, err = clone(&bm, context.temp_allocator)
	expect(err == nil)
	for word, i in bm2.backing.buffer do expect(bm.backing.buffer[i] == word)
	fill(&bm, 0)
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(read(&bm, [2]u32{ i, j }) == 0)
	fill(&bm, 1)
	for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(read(&bm, [2]u32{ i, j }) == 1)

	// Square matrix //
	width: u32 = rand.uint32_range(4, 32)
	bm, err = make_square_bit_matrix(width, context.temp_allocator)
	expect(err == nil)
	expect(bm.shape.x == width && bm.shape.y == width)

	free_all(context.temp_allocator) }
