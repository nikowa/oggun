#+feature using-stmt
package willow
import "core:sync"

Context :: struct {
	locks_registers: Two_Stack(^Lock) }

make_context :: proc() -> (sync_context: Context) {
	two_stack_init(&sync_context.locks_registers)
	return sync_context }

//////////
// LOCK //
Lock :: sync.Ticket_Mutex

lock_acquire_unmanaged :: sync.ticket_mutex_lock
lock_release_unmanaged :: sync.ticket_mutex_unlock
lock_guard_unmanaged :: sync.ticket_mutex_guard

////////////////
// ARENA LOCK //
// Arena_Lock :: struct {
// 	lock: Lock,
// 	size: u32 }

// arena_lock_acquire_unsafe :: #force_inline proc "contextless" (arena_lock: ^Arena_Lock) {
// 	lock_acquire(&arena_lock.lock) }

// arena_lock_release_unsafe :: #force_inline proc "contextless" (arena_lock: ^Arena_Lock) {
// 	lock_release(&arena_lock.lock) }

// @(deferred_in=arena_lock_release_unsafe)
// arena_lock_guard_unsafe :: proc "contextless" (arena_lock: ^Arena_Lock) -> bool {
// 	arena_lock_acquire_unsafe(arena_lock)
// 	return true }

// arena_locks_ordered :: #force_inline proc "contextless" (arena_lock_a, arena_lock_b: ^Arena_Lock) -> bool {
// 	return cast(uintptr)arena_lock_a < cast(uintptr)arena_lock_b }

// arena_lock_acquire :: arena_lock_push

// arena_lock_release :: #force_inline proc(arena_lock: ^Arena_Lock) -> (ok: bool) {
// 	thread_data := get_thread_data()
// 	i := ts.index(&thread_data._locks_registers, arena_lock)
// 	switch i {
// 	case -1: return false
// 	case 0:
// 		_, ok = ts.pop_bottom(&thread_data._locks_registers)
// 		return ok
// 	case 1:
// 		_, ok = ts.pop_top(&thread_data._locks_registers)
// 		return ok }
// 	return false }

// // Acquire the lock and push it onto the thread's locks stack. //
// arena_lock_push :: #force_inline proc(arena_lock: ^Arena_Lock) -> (ok: bool) {
// 	ok = false
// 	thread_data := get_thread_data()
// 	top_lock := ts.peek(&thread_data._locks_registers) or_return
// 	ts.push(&thread_data._locks_registers, arena_lock) or_return
// 	if top_lock == nil || arena_locks_ordered(top_lock, arena_lock) do arena_lock_acquire_unsafe(arena_lock)
// 	else {
// 		arena_lock_release_unsafe(top_lock)
// 		arena_lock_acquire_unsafe(arena_lock)
// 		arena_lock_acquire_unsafe(top_lock) }
// 	return true }

// // Pop the top lock from the thread's locks stack and release it. //
// arena_lock_pop :: #force_inline proc() -> (ok: bool) {
// 	ok = false
// 	thread_data := get_thread_data()
// 	top_lock := ts.pop(&thread_data._locks_registers) or_return
// 	arena_lock_release_unsafe(top_lock)
// 	return true }

// @(deferred_none=arena_lock_pop)
// arena_lock_scope :: #force_inline proc(arena_lock: ^Arena_Lock) -> (ok: bool) {
// 	arena_lock_push(arena_lock)
// 	return true }



////////////////////
// CAGE ALLOCATOR //
// Cage :: struct {
// 	size: uintptr,
// 	lock: Lock,
// 	hash: u32,
// 	readonly: bool }

// CAGES_CAP :: 32
// Cage_Allocator :: struct {
// 	cages: [dynamic]Cage,
// 	size: uintptr,
// 	arena: mem.Arena,
// 	backing_allocator: runtime.Allocator }

// @(no_sanitize_address)
// cage_allocator_init :: proc(allocator: ^Cage_Allocator, buffer: []u8) {
// 	mem.arena_init(&allocator.arena, buffer)
// 	allocator.backing_allocator = mem.arena_allocator(&allocator.arena)
// 	allocator.cages = make_dynamic_array_len_cap([dynamic]Cage, 0, 256, context.allocator) }

// @(require_results, no_sanitize_address)
// cage_allocator :: proc(data: ^Cage_Allocator) -> mem.Allocator {
// 	return mem.Allocator{
// 		data = data,
// 		procedure = cage_allocator_proc } }

// current_cage_allocator :: proc() -> (allocator: ^Cage_Allocator) {
// 	return cast(^Cage_Allocator)context.allocator.data }

// cage_allocator_new_cage :: proc(cage_allocator: ^Cage_Allocator, size: uintptr, readonly: bool) {
// 	assert(cage_allocator.size + size <= cast(uintptr)len(cage_allocator.arena.data))
// 	append(&cage_allocator.cages, Cage{ size = size, readonly = readonly }) }

// @(no_sanitize_address)
// cage_allocator_proc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, runtime.Allocator_Error) {
// 	cage_allocator: ^Cage_Allocator = cast(^Cage_Allocator)allocator_data
// 	switch mode {
// 	case .Alloc, .Alloc_Non_Zeroed:
// 		ptr, error := mem.alloc(size, alignment, cage_allocator.backing_allocator)
// 		if ptr != nil do return slice.bytes_from_ptr(ptr, size), nil
// 		else do return nil, error
// 	case .Free:
// 		return nil, mem.free(old_memory)
// 	case .Free_All:
// 		return nil, .Mode_Not_Implemented
// 	case .Resize, .Resize_Non_Zeroed:
// 		ptr, error := mem.resize(old_memory, old_size, size, alignment, cage_allocator.backing_allocator)
// 		if ptr != nil do return slice.bytes_from_ptr(ptr, size), nil
// 		else do return slice.bytes_from_ptr(old_memory, old_size), error
// 	case .Query_Features:
// 		set := (^mem.Allocator_Mode_Set)(old_memory)
// 		if set != nil {
// 			set^ = {.Alloc, .Alloc_Non_Zeroed, .Free, .Resize, .Resize_Non_Zeroed, .Query_Features} }
// 		return nil, nil
// 	case .Query_Info:
// 		return nil, .Mode_Not_Implemented }
// 	return nil, nil }

// cage_allocator_readonly_seal :: proc(cage_allocator: ^Cage_Allocator, cage: ^Cage) {
// 	bytes: []u8 = cage_allocator.arena.data[]
// 	hash
// 	hash.hash_byte(.BLAKE2B, )
// }



// acquire_cage_by_ptr
// release_cage_by_ptr
// swap_cage_by_ptr





// lock_trade_1_for_1 :: proc(owned: ^Lock, desired: ^Lock) {
// 	lock_release(owned)
// 	lock_acquire(desired) }


// lock_trade_1_for_2 :: proc(owned: ^Lock, desired: ^Lock) {
// 	lock_release(owned)
// 	lock_acquire(desired) }


/*
// NOTE: A regular mutex would not work. We need a ticket mutex to ensure that the thread that first requested the lock acquires the lock. //
Lock :: ranked_mutex.Ranked_Mutex
lock_acquire :: ranked_mutex.lock
lock_release :: ranked_mutex.unlock
lock_guard :: ranked_mutex.guard


// TODO: Jobs must be a linked list, so that a thread can take a job from the middle, if it doesn't have the right filters for the tail-job.
Sync :: struct {
	n_logical_cores: u32,
	threads:         [dynamic]Thread,
	job_queue:       Locked_Struct(Job_Queue),
	flags:           Sync_Flags }


Sync_Flag :: enum {
	DRAWING }


Sync_Flags :: bit_set[Sync_Flag]


// The main thread must also have a Thread object assigned to it, with a nil "tr". //
Thread :: struct {
	handle:  ^thread.Thread,
	data:    ^Thread_Proc_Data,
	filters: Thread_Filters }


Thread_Filter :: enum {
	MAIN_THREAD }


Thread_Filters :: bit_set[Thread_Filter]


// @(tag="job") job_proc_example :: proc(x: ^Locked_Struct(int), y: ^Locked_Struct(string), a: int, b: string) {
// 	// NOTE: Job functions cannot take pointers, except pointers to Locked_Struct.
// }
// @(disabled=!ODIN_DEBUG) @(init) _ :: proc() { assert(job_proc_is_valid(job_proc_example)) }


// job_proc_is_valid :: proc(job_proc: $T) -> bool {
// 	when ODIN_DEBUG {
// 		type_info: runtime.Type_Info_Procedure = type_info_of().variant.(runtime.Type_Info_Procedure)
// 		params: runtime.Type_Info_Parameters = type_info.(runtime.Type_Info_Parameters)
// 		for type in params.types {
// 			pointer: runtime.Type_Info_Pointer
// 			ok: bool
// 			pointer, ok := type.variant.(runtime.Type_Info_Pointer)
// 			if ok {
// 				named: runtime.Type_Info_Named
// 				elem_type := pointer.elem
// 				named, ok = elem_type.variant.(runtime.Type_Info_Named)
// 				if named.name != "Locked_Struct" do return false } }
// 		return true
// 	} else {
// 		return true } }


job_queue_len :: proc(job_queue: ^Job_Queue) -> (n: int) {
	iter: list.Iterator(Job)

	n = 0
	iter = list.iterator_head(job_queue._queue, Job, "node")
	for job in list.iterate_next(&iter) do n += 1
	return n }


@(private="file") _job_queue_append_job :: proc(job_queue: ^Job_Queue, job: Job) {
	_job: ^Job

	_job = new(Job)
	_job^ = job
	list.push_back(&job_queue._queue, &_job.node) }


job_queue_append :: proc(job_queue: ^Job_Queue, name: string, fn: proc(data: rawptr), filters: Thread_Filters, data: $T) {
	data_clone: ^T

	data_clone = new(T)
	data_clone^ = data
	_job_queue_append_job(job_queue, Job{ name = name, fn = fn, data = data_clone, filters = filters }) }


job_queue_append_non_duplicate :: proc(job_queue: ^Job_Queue, name: string, fn: proc(data: rawptr), filters: Thread_Filters, data: $T) {
	data_clone: ^T

	if job_queue_contains(job_queue, fn) do return
	data_clone = new(T)
	data_clone^ = data
	_job_queue_append_job(job_queue, Job{ name=name, fn=fn, data=data_clone, filters=filters }) }


Thread_Proc_Data :: struct {
	index:          u32,
	job_queue:      ^Locked_Struct(Job_Queue),
	thread_filters: Thread_Filters }


thread_proc :: proc(handle: ^thread.Thread) {
	data: ^Thread_Proc_Data
	job:  Job
	ok:   bool

	ordered_mutex_init_thread()
	data = auto_cast handle.data
	fmt.println(LOG, "Thread proc on thread", data.index)
	for {
		// fmt.println("Thread", data.index, "is looking for a job.")
		{
			// fmt.println(cast(uintptr)handle.data, cast(uintptr)data.job_queue)
			// fmt.println(handle^)
			lock_guard(&data.job_queue.lock)
			if data.job_queue.terminate do return
			// fmt.println("Thread", data.index, "has filters", data.thread_filters)
			job, ok = job_queue_search_by_filters(unwrap(data.job_queue), data.thread_filters)
		}
		if ok {
			// fmt.println("Thread", data.index, "has acquired a job", job.name, ".")
			job_execute(job)
			free_all(context.temp_allocator) } }
	fmt.println(LOG, "Teminate.") }


sync_init :: proc(sync: ^Sync) {
	n_logical_cores:  u32
	n_physical_cores: u32
	n_relieved_cores: u32
	system_info:      windows.SYSTEM_INFO
	info_size:        u32
	thread:           Thread

	n_logical_cores = 0
	n_physical_cores = 0
	n_relieved_cores = 8
	windows.GetSystemInfo(&system_info)
	n_logical_cores = system_info.dwNumberOfProcessors
	windows.GetLogicalProcessorInformation(nil, &info_size)
	fmt.println("Info size:", info_size)
	logical_processor_info: []windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION = make([]windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION, info_size / size_of(windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION))
	windows.GetLogicalProcessorInformation(nil, &info_size)
	windows.GetLogicalProcessorInformation(&logical_processor_info[0], &info_size)
	n_physical_cores = 0
	for info in logical_processor_info {
		if info.Relationship == .RelationProcessorCore do n_physical_cores += 1 }
	sync.job_queue.allocator = context.allocator
	fmt.println(LOG, "Number of logical cores:", n_logical_cores)
	fmt.println(LOG, "Number of physical cores:", n_physical_cores)
	sync.n_logical_cores = min(n_physical_cores, n_logical_cores - n_relieved_cores)
	// sync.n_logical_cores = 1 // TEMP
	fmt.println(LOG, "Number of threads:", sync.n_logical_cores)
	for i in 0 ..< sync.n_logical_cores - 1 {
		thread = {}
		thread.data = new(Thread_Proc_Data)
		thread.data^ = {
			index = i + 1,
			job_queue = &sync.job_queue,
			thread_filters = { } }
		thread.filters = {}
		thread.handle = thread.create(procedure=thread_proc, priority=.Normal)
		thread.handle.data = cast(rawptr)thread.data
		thread.handle.init_context = runtime.default_context()
		append(&sync.threads, thread) } }


Job :: struct {
	name:    string,
	node:    list.Node,
	fn:      proc(data: rawptr),
	data:    rawptr,
	filters: Thread_Filters }


job_execute :: proc(job: Job) {
	job.fn(job.data) }


// TODO: Make sure this returns true before a thread is employed to do a job. //
thread_is_suitable_for_job :: proc(thread: ^Thread, job: ^Job) -> bool {
	return thread.filters >= job.filters }


Job_Queue :: struct {
	_queue:    list.List,
	terminate: bool }


Locked_Struct :: struct($T: typeid) {
	using _:    T,
	using lock: Lock,
	allocator:  runtime.Allocator }


Locked_Object :: struct($T: typeid) {
	object:     T,
	using lock: Lock }


unwrap :: proc { locked_struct_unwrap, locked_object_unwrap }


// NOTE: If a function takes a Locked_Struct pointer as an argument, it is assumed that the calling thread has not acquired it's lock. If it takes a pointer
//       to an element that is inside a Locked_Struct, it is assumed that the calling thread has already acquired it's lock. So you should unwrap blocks using
//       this procedure after acquiring them.
locked_struct_unwrap :: proc(locked_struct: ^Locked_Struct($T)) -> ^T {
	return cast(^T)locked_struct }


locked_object_unwrap :: proc(locked_object: ^Locked_Object($T)) -> ^T {
	return cast(^T)locked_object }


// (DESC): Acquire the lock of a locked struct. //
locked_struct_acquire :: proc(locked_struct: ^Locked_Struct($T)) -> ^T {
	lock_acquire(locked_struct.lock) }


// (DESC): Release the lock of a locked struct. //
locked_struct_release :: proc(locked_struct: ^Locked_Struct($T)) -> ^T {
	lock_release(locked_struct.lock) }


// (DESC): Acquire and unwrap a locked struct. Automatically released at the end of scope. //
// @(deferred_in=locked_struct_release)
// locked_struct_guard :: proc(locked_struct: ^Locked_Struct($T)) -> ^T {
// 	locked_struct_acquire(locked_struct)
// 	return locked_struct_unwrap(locked_struct) }


deref_any :: proc(data: any, $T: typeid) -> T {
	assert(data.id == T)
	return (cast(^T)data.data)^ }


type_any :: proc(data: any, $T: typeid) -> ^T {
	assert(data.id == T)
	return (cast(^T)data.data) }


job_queue_contains :: proc(job_queue: ^Job_Queue, fn: proc(data: rawptr)) -> bool {
	iter: list.Iterator(Job)

	iter = list.iterator_head(job_queue._queue, Job, "node")
	for job in list.iterate_next(&iter) {
		if job.fn == fn do return true }
	return false }


job_queue_search_by_filters :: proc(job_queue: ^Job_Queue, filters: Thread_Filters) -> (job: Job, ok: bool) #optional_ok {
	iter: list.Iterator(Job)

	iter = list.iterator_head(job_queue._queue, Job, "node")
	for _job in list.iterate_next(&iter) {
		if _job.filters <= filters {
			// fmt.printfln("%v < %v", _job.filters, filters)
			job = _job^
			list.remove(&job_queue._queue, &_job.node)
			return job, true } }
	return {}, false }


Burnout_Job_Data :: struct {
	job_queue: ^Locked_Struct(Job_Queue) }
@(tag="job") burnout_job :: proc(data_ptr: rawptr) {
	data: ^Burnout_Job_Data

	data = auto_cast data_ptr
	// fmt.println("burning rubber...")
	for k in 0 ..< 1000 {
		a, b: matrix[4, 4]f32
		for i in 0 ..< 4 do for j in 0 ..< 4 {
			a[i][j] = rand.float32()
			b[i][j] = rand.float32() }
		c := a * b }
	lock_guard(data.job_queue)
	job_queue_append_non_duplicate(unwrap(data.job_queue), "Burnout", burnout_job, {}, Burnout_Job_Data{ job_queue=data.job_queue }) }


Sync_Tick_Data :: struct {
	sync:                   ^Locked_Struct(Sync),
	clock:                  ^Locked_Struct(Clock),
	draw:                   ^Locked_Struct(Draw),
	camera:                 ^Locked_Struct(Camera),
	physics:                ^Locked_Struct(Physics),
	input:                  ^Locked_Struct(Input),
	ui:                     ^Locked_Struct(UI),
	working_directory_path: string }
sync_tick_filters: Thread_Filters : { .MAIN_THREAD }
@(tag="job") sync_tick :: proc(data_ptr: rawptr) {
	data: ^Sync_Tick_Data

	// fmt.println("Sync Tick")
	data = auto_cast data_ptr
	defer free(data)
	using data
	lock_guard(&camera.lock)
	lock_guard(&clock.lock)
	lock_guard(&draw.lock)
	lock_guard(&input.lock)
	lock_guard(&physics.lock)
	lock_guard(&sync.lock)
	lock_guard(&sync.job_queue.lock)
	if draw.window_closed {
		sync.job_queue.terminate = true
		return }
	job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Clock", clock_tick, clock_tick_filters, Clock_Tick_Data{ clock=clock })
	// 	watch_data()
	job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Input", input_tick, input_tick_filters, Input_Tick_Data{ input=input })
	if clock.frame_rate_controller.should_tick && ! job_queue_contains(&sync.job_queue, draw_tick) {
		job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Draw", draw_tick, draw_tick_filters, Draw_Tick_Data{ draw=draw, camera=camera, physics=physics, clock=clock, sync=sync, input=input, working_directory_path=working_directory_path }) }
	job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Physics", physics_tick, physics_tick_filters, Physics_Tick_Data{ physics=physics, clock=clock, camera=camera })
	job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Camera", camera_tick, camera_tick_filters, Camera_Tick_Data{ camera=camera, input=input, ui=ui, physics=physics, clock=clock })
	// 	audio_tick()
	job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Sync", sync_tick, sync_tick_filters, Sync_Tick_Data{ sync=sync, clock=clock, draw=draw, camera=camera, physics=physics, input=input, ui=ui })
	// job_queue_append_non_duplicate(unwrap(&sync.job_queue), "Burnout", burnout_job, {}, Burnout_Job_Data{ job_queue=&sync.job_queue })
}


sync_start :: proc(sync: ^Sync) {
	for _, i in sync.threads {
		fmt.println("Starting thread", sync.threads[i].data.index)
		thread.start(sync.threads[i].handle) } }

*/