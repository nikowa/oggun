#+feature using-stmt
package willow
import "core:sync"

@(thread_local) rank: int
@(thread_local) rank_stack: [dynamic]int

ordered_mutex_init_thread :: proc() {
	rank = 0
	rank_stack = make([dynamic]int, 16) }

Ordered_Mutex :: struct {
	derived: sync.Ticket_Mutex,
	rank: int }

ordered_mutex_lock :: proc(m: ^Ordered_Mutex) {
	assert(m.rank > rank)
	append(&rank_stack, rank)
	rank = m.rank
	sync.ticket_mutex_lock(&m.derived) }

ordered_mutex_unlock :: proc(m: ^Ordered_Mutex) {
	rank = pop(&rank_stack)
	sync.ticket_mutex_unlock(&m.derived) }
