package oggun



Two_Stack :: struct($T: typeid) {
	buffer: [2]T,
	len: u8 }

two_stack_init :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) {
	two_stack^ = {} }

two_stack_len :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> int {
	return cast(int)two_stack.len }

two_stack_push :: two_stack_push_top
two_stack_push_top :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T), elem: T) -> bool {
	if two_stack.len >= 2 do return false
	two_stack.buffer[two_stack.len] = elem
	two_stack.len += 1
	return true }

two_stack_push_bottom :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T), elem: T) -> bool {
	if two_stack.len >= 2 do return false
	if two_stack.len == 1 {
		two_stack.buffer[1] = two_stack.buffer[0]
		two_stack.buffer[0] = elem }
	else do two_stack.buffer[0] = elem
	two_stack.len += 1
	return true }

two_stack_pop :: two_stack_pop_top
two_stack_pop_top :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool) {
	if two_stack.len == 0 do return {}, false
	two_stack.len -= 1
	elem = two_stack.buffer[two_stack.len]
	two_stack.buffer[two_stack.len] = {}
	return elem, true }

two_stack_pop_bottom :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool) {
	if two_stack.len == 0 do return {}, false
	if two_stack.len == 2 {
		temp := two_stack.buffer[0]
		two_stack.buffer[0] = two_stack.buffer[1]
		two_stack.buffer[1] = temp }
	return two_stack_pop_top(two_stack) }

two_stack_peek :: two_stack_peek_top
two_stack_peek_top :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool) {
	if two_stack.len == 0 do return {}, false
	elem = two_stack.buffer[two_stack.len - 1]
	return elem, true }

two_stack_peek_bottom :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T)) -> (elem: T, ok: bool) {
	if two_stack.len == 0 do return {}, false
	elem = two_stack.buffer[0]
	return elem, true }

two_stack_contains :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T), elem: T) -> (ok: bool) {
	return ((two_stack.len >= 2) && (two_stack.buffer[1] == elem)) || ((two_stack.len >= 1) && (two_stack.buffer[0] == elem)) }

two_stack_index :: #force_inline proc "contextless" (two_stack: ^Two_Stack($T), elem: T) -> (i: int) {
	if (two_stack.len >= 1) && (two_stack.buffer[0] == elem) do return 0
	else if (two_stack.len >= 2) && (two_stack.buffer[1] == elem) do return 1
	else do return -1 }
