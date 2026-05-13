package willow

Watcher :: struct {
	data: rawptr,
	outdated_proc: Outdated_Proc,
	update_proc: Update_Proc }

Outdated_Proc :: #type proc(data: rawptr) -> bool

Update_Proc :: #type proc(data: rawptr)

watcher_tick :: proc(watcher: ^Watcher) {
	if watcher.outdated_proc(watcher.data) do watcher.update_proc(watcher.data) }
