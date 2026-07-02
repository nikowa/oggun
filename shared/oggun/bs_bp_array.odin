#+feature using-stmt
package oggun

// Bit-packed array //
BP_Array :: struct($Elem_Type: typeid, $elem_size: int, $n: int) {
	buffer: [(elem_size * n) / 8 + 1]u8 }

// A[i] == buffer[i * elem_size : (i + 1) * elem_size]

bp_array_read :: proc(array: BP_Array($Elem_Type, $elem_size, $n), j: int) -> Elem_Type {

}
