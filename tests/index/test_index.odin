#+feature using-stmt
package index
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"
import "core:math/bits"
import "core:mem"

@(test)
test :: proc(_t: ^testing.T) {
	context.user_ptr = _t

	f :: proc($B: typeid) {
		n: int = min(bits.U16_MAX, cast(int)og.signed_int_max(B))
		t := og.tintegers({ { 2, 0, n } })
		ix := og.make_index([]int, B)
		og.expect(og.index_is_nil(&ix))
		slice := make([]int, n + 1)
		jx: [2]int
		jx[0] = t[0][0]
		jx[1] = cast(int)og.signed_int_max(B) + 1 + t[0][1]
		for j, i in jx {
			k := min(j, len(slice) - 1)
			ptr0 := cast(^int)(uintptr(&slice[0]) + uintptr(size_of(int) * j))
			ok0 := og.index_set(&ix, slice, ptr0)
			og.expect((i == 0) || (ok0 == false))
			ptr1, ok1 := og.index_get(&ix, slice)
			og.index_set_nil(&ix)
			og.expect(og.index_is_nil(&ix))
			og.expect((! ok0) || ok1)
			og.expect(ok0 == ok1)
			og.expect((! ok1) || ((ptr0 == ptr1) && (ptr0 == &slice[j]))) } }

	for _ in 0 ..< 100 {
		f(i8)
		f(i16)
		f(i32) }

	free_all(context.temp_allocator) }
