package oggun

clone :: proc {
	_clone_bit_array,
	_clone_bit_matrix }

fill_random :: proc {
	_bit_array_fill_random,
	_bit_matrix_fill_random }

fill :: proc {
	_bit_array_fill,
	_bit_matrix_fill }

rank :: proc {
	_bit_array_rank,
	_bit_matrix_rank }

aprint :: proc {
	_aprint_bit_array,
	_aprint_bit_matrix }

aprint_ext :: proc {
	_aprint_bit_array_ext }

set :: proc {
	_bit_array_set }

zero :: proc {
	_bit_array_zero_bit,
	_bit_array_zero_chunk }

read :: proc {
	_bit_array_read_bit,
	_bit_array_read_chunk,
	_bit_matrix_read_bit,
	_bit_matrix_read_interval }

write :: proc {
	_bit_array_write_bit,
	_bit_array_write_chunk,
	_bit_matrix_write_bit,
	_bit_matrix_write_interval }

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
	_bit_matrix_size }
