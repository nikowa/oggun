#+feature using-stmt
package bitpacked_array
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"

@(test)
test :: proc(t: ^testing.T) {
	using og

	context.allocator = runtime.panic_allocator()

	bpa: = make_bitpacked_array(u64, 40, 32, context.temp_allocator)
	a := make([]u64, 32, context.temp_allocator)

	for i in 0 ..< 32 {
		value: u64 = rand.uint64_max(1_099_511_627_776)
		a[i] = value
		bitpacked_array_write(&bpa, i, value) }

	for i in 0 ..< 32 do testing.expect(t, bitpacked_array_read(&bpa, i) == a[i])

	free_all(context.temp_allocator) }
