package oggun

// when OGGUN_EXE {
clone :: proc {
	clone_bit_array,
	clone_bit_matrix }

fill_random :: proc {
	bit_array_fill_random,
	bit_matrix_fill_random }

fill :: proc {
	bit_array_fill,
	bit_matrix_fill }

rank :: proc {
	bit_array_rank,
	bit_matrix_rank }

aprint :: proc {
	aprint_bit_array,
	aprint_bit_matrix }

set :: proc {
	bit_array_set }

zero :: proc {
	bit_array_zero_bit,
	bit_array_zero_chunk }

read :: proc {
	bit_array_read_bit,
	bit_array_read_chunk,
	bit_matrix_read_bit,
	bit_matrix_read_interval }

write :: proc {
	bit_array_write_bit,
	bit_array_write_chunk,
	bit_matrix_write_bit,
	bit_matrix_write_interval }

or :: proc {
	_bit_array_or_ref,
	_bit_array_or_make }

xor :: proc {
	_bit_array_xor_ref,
	_bit_array_xor_make }

and :: proc {
	_bit_array_and_ref,
	_bit_array_and_make }

and_not :: proc {
	_bit_array_and_not_ref,
	_bit_array_and_not_make }

not :: proc {
	_bit_array_not_ref,
	_bit_array_not_make }

size :: proc {
	bit_matrix_size }
// }
