#+feature using-stmt
package bit_tmatrix
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

	bm: Bit_TMatrix
	err: runtime.Allocator_Error

	// shape: u32 = rand.uint32_range(4, 32)
	// bm, err = make_bit_tmatrix(shape, context.temp_allocator)
	// expect(err == nil)
	// expect(bit_tmatrix_size(&bm) == shape.x * shape.y)
	// fill_random(&bm)
	// for i in 0 ..< 32 {
	// 	address: [2]u32 = { rand.uint32_max(bm.shape.x), rand.uint32_max(bm.shape.y) }
	// 	value: u8 = cast(u8)rand.uint32_max(2)
	// 	write(&bm, address, value)
	// 	expect(read(&bm, address) == value) }
	// rk := rank(&bm, 1)
	// expect(rk == bit_tmatrix_size(&bm) - rank(&bm, 0))
	// for i in 0 ..< shape.x do for j in 0 ..< shape.y do rk -= cast(u32)read(&bm, [2]u32{ i, j })
	// expect(rk == 0)
	// bm2: Bit_TMatrix
	// bm2, err = clone_bit_tmatrix(&bm, context.temp_allocator)
	// expect(err == nil)
	// for word, i in bm2.backing.buffer do expect(bm.backing.buffer[i] == word)
	// fill(&bm, 0)
	// for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(read(&bm, [2]u32{ i, j }) == 0)
	// fill(&bm, 1)
	// for i in 0 ..< shape.x do for j in 0 ..< shape.y do expect(read(&bm, [2]u32{ i, j }) == 1)

	free_all(context.temp_allocator) }
