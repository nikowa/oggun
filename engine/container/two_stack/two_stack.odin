package two_stack



Two_Stack :: struct($T: typeid) {
	buffer: [2]T,
	len: u8 }

init :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) {
	two_stack^ = {} }

len :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> u32 {
	return two_stack.len }

push :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T), elem: T) -> bool {
	if two_stack.len >= 2 do return false
	two_stack.buffer[two_stack.len] = elem
	two_stack.len += 1
	return true }

pop :: pop_top
pop_top :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T) {
	if two_stack.len == 0 do return nil
	two_stack.len -= 1
	elem = two_stack.buffer[two_stack.len]
	two_stack.buffer[two_stack.len] = nil
	return elem }

pop_bottom :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T) {
	if two_stack.len == 0 do return nil
	if two_stack.len == 2 {
		temp := two_stack.buffer[0]
		two_stack.buffer[0] = two_stack.buffer[1]
		two_stack.buffer[1] = temp }
	return pop_top(two_stack) }

peek :: peek_top
peek_top :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T) {
	if two_stack.len == 0 do return nil
	elem = two_stack.buffer[two_stack.len]
	return elem }

