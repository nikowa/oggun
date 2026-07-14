package bit_matrix
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"

@(test)
test :: proc(t: ^testing.T) {
	context.allocator = runtime.panic_allocator()

	bm: og.Bit_Matrix
	err: runtime.Allocator_Error
	bm, err = og.make_bit_matrix({ rand.uint32_range(4, 32), rand.uint32_range(4, 32) }, context.temp_allocator)
	og.bit_matrix_fill_random(&bm)
	// log.infof("\n%s", og.aprint_bit_matrix(&bm, context.temp_allocator))
	for i in 0 ..< 32 {
		address: [2]u32 = { rand.uint32_max(bm.shape.x), rand.uint32_max(bm.shape.y) }
		value: u8 = cast(u8)rand.uint32_max(2)
		og.bit_matrix_write(&bm, address, value)
		testing.expect(t, og.bit_matrix_read(&bm, address) == value) }

	free_all(context.temp_allocator) }
