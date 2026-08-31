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
	context.logger.options += { .Line, .Procedure }

	E :: int
	U :: i16
	B :: u8
	integers := og.tintegers({
		{ 1, min(int(og.signed_int_max(U)), 32 * mem.Megabyte) / 10, min(int(og.signed_int_max(U)), 32 * mem.Megabyte) },
		{ 1, min(int(og.unsigned_int_max(B)), 4 * mem.Megabyte) / 10, min(int(og.unsigned_int_max(B)), 4 * mem.Megabyte) } })
	universe := make([]int, integers[0][0])
	tup: og.Tuple(E, U, B) = og.make_tuple_len_cap(E, U, B, 0, integers[1][0])
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
		elem := og.tuple_get(&tup, universe, cast(B)i)
		og.expect(elem == &universe[integers2[0][i]]) }

	tup2: og.Tuple(E, U, B) = og.make_tuple_len(E, U, B, integers[1][0])
	og.expect(og.tuple_len(&tup2) == integers[1][0])
	og.expect(og.tuple_cap(&tup2) == integers[1][0])
	og.delete_tuple(&tup2)

	n = len(integers2[0])
	ptrs := make([]^E, n)
	indexes := make([]U, n)
	for integer, i in integers2[0] {
		ptrs[i] = &universe[integers2[0][i]]
		indexes[i] = cast(U)integer }
	tup3: og.Tuple(E, U, B) = og.make_tuple_from_ptrs(E, U, B, ptrs, universe)
	tup4: og.Tuple(E, U, B) = og.make_tuple_from_indexes(E, U, B, indexes, universe)
	tup5: og.Tuple(E, U, B) = og.make_tuple_len(E, U, B, n)
	for i in 0 ..< n {
		if i % 2 == 0 do og.tuple_set_by_ptr(&tup5, cast(B)i, ptrs[i], universe)
		else do og.tuple_set_by_index(&tup5, cast(B)i, auto_cast indexes[i], universe) }
	og.expect(og.tuple_len(&tup3) == n)
	og.expect(og.tuple_len(&tup4) == n)
	og.expect(og.tuple_len(&tup5) == n)
	j: B = 0
	for elem in og.tuple_iterate(&tup3, universe, &j) do og.expect(elem == og.tuple_get(&tup3, universe, j - 1))
	for i in 0 ..< n {
		og.expect(og.tuple_get(&tup3, universe, cast(B)i) == og.tuple_get(&tup4, universe, cast(B)i))
		og.expect(og.tuple_get(&tup4, universe, cast(B)i) == og.tuple_get(&tup5, universe, cast(B)i)) }

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
