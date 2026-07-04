package bitpacked_array
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"

@(test)
test :: proc(t: ^testing.T) {
	context.allocator = runtime.panic_allocator()

	bpa: = og.make_bitpacked_array(u64, 40, 32, context.temp_allocator)

	free_all(context.temp_allocator) }
