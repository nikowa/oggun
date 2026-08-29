#+feature using-stmt
package tuple
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

	

	free_all(context.temp_allocator) }
