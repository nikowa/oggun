#+feature using-stmt
package tuple
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"
import "core:mem"
import "core:math/bits"

@(test)
test :: proc(_t: ^testing.T) {
	context.user_ptr = _t

	E :: int
	U :: i16
	B :: u8
	integers := og.tintegers({
		{ 1, min(int(og.signed_int_max(U)), 32 * mem.Megabyte) / 10, min(int(og.signed_int_max(U)), 32 * mem.Megabyte) },
		{ 1, min(int(og.unsigned_int_max(B)), 4 * mem.Megabyte) / 10, min(int(og.unsigned_int_max(B)), 4 * mem.Megabyte) } })
	universe := make([]int, integers[0][0])
	tup: og.Tuple(E, U, B) = og.make_tuple_len_cap(E, U, B, 0, integers[1][0])
	tup2: og.Tuple(E, U, B) = og.make_tuple_len(E, U, B, integers[1][0])
	og.expect(og.tuple_len(&tup2) == integers[1][0])
	og.expect(og.tuple_cap(&tup2) == integers[1][0])
	og.delete_tuple(&tup2)
	og.expect(og.tuple_len(&tup) == 0)
	og.expect(og.tuple_cap(&tup) == integers[1][0])
	integers2 := og.tintegers({ { integers[1][0], 0, integers[0][0] }, { integers[1][0], 0, bits.INT_MAX } })
	for _, i in integers2[0] {
		universe[integers2[0][i]] = integers2[1][i]
		n: int
		err: runtime.Allocator_Error
		if i % 2 == 0 do n, err = og.tuple_append_by_ptr(&tup, &universe[integers2[0][i]], universe)
		else do n, err = og.tuple_append_by_index(&tup, integers2[0][i], universe)
		og.expect((n == 1) && (err == nil))
		og.expect(og.tuple_len(&tup) == i + 1) }
	n, err := og.tuple_append(&tup, &universe[0], universe)
	og.expect((n == 0) && (err == .Out_Of_Memory))
	for _, i in integers2[0] {
		elem := og.tuple_elem(&tup, universe, i)
		og.expect(elem == &universe[integers2[0][i]]) }

	// f :: proc($B: typeid) {
	// 	n: int = min(bits.U16_MAX, cast(int)og.signed_int_max(B))
	// 	t := og.tintegers({ { 2, 0, n } })
	// 	ix := og.make_index([]int, B)
	// 	og.expect(og.index_is_nil(&ix))
	// 	slice := make([]int, n + 1)
	// 	jx: [2]int
	// 	jx[0] = t[0][0]
	// 	jx[1] = cast(int)og.signed_int_max(B) + 1 + t[0][1]
	// 	for j, i in jx {
	// 		k := min(j, len(slice) - 1)
	// 		ptr0 := cast(^int)(uintptr(&slice[0]) + uintptr(size_of(int) * j))
	// 		ok0 := og.index_set(&ix, slice, ptr0)
	// 		og.expect((i == 0) || (ok0 == false))
	// 		ptr1, ok1 := og.index_get(&ix, slice)
	// 		og.index_set_nil(&ix)
	// 		og.expect(og.index_is_nil(&ix))
	// 		og.expect((! ok0) || ok1)
	// 		og.expect(ok0 == ok1)
	// 		og.expect((! ok1) || ((ptr0 == ptr1) && (ptr0 == &slice[j]))) } }

	// for _ in 0 ..< 100 {
	// 	f(i8)
	// 	f(i16)
	// 	f(i32) }

	free_all(context.temp_allocator) }
