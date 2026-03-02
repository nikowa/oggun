#+feature using-stmt
package base
import rt "base:runtime"
import "core:fmt"
import tr "core:thread"
import sn "core:sync"
import q "core:container/queue"
import l "core:container/intrusive/list"
import win "core:sys/windows"
import "core:math/rand"
import "core:mem"
import "shared:ranked_mutex"
import sl "core:slice"



/* ~~~~~~~~~~~~~~~~
    CAGE ALLOCATOR
   ~~~~~~~~~~~~~~~~ */

Cage :: struct {
	range: [2]uintptr,
	lock: Lock }

Cage_Allocator :: struct {
	cages: [dynamic]Cage,
	backing: mem.Allocator }

@(no_sanitize_address)
cage_allocator_init :: proc(allocator: ^Cage_Allocator, backing_allocator: mem.Allocator) {
	allocator.backing = backing_allocator
	allocator.cages = make_dynamic_array_len_cap([dynamic]Cage, 0, 256, backing_allocator) }

@(require_results, no_sanitize_address)
cage_allocator :: proc(data: ^Cage_Allocator) -> mem.Allocator {
	return mem.Allocator{
		data = data,
		procedure = cage_allocator_proc } }

current_cage_allocator :: proc() -> (allocator: ^Cage_Allocator) {
	return cast(^Cage_Allocator)context.allocator.data }

// cage_allocator_new_cage :: proc(cage: ^Cage_Allocator, )

@(no_sanitize_address)
cage_allocator_proc :: proc(allocator_data: rawptr, mode: mem.Allocator_Mode, size, alignment: int, old_memory: rawptr, old_size: int, loc := #caller_location) -> ([]byte, rt.Allocator_Error) {
	cage_allocator: ^Cage_Allocator = cast(^Cage_Allocator)allocator_data
	switch mode {
	case .Alloc, .Alloc_Non_Zeroed:
		ptr, error := mem.alloc(size, alignment, cage_allocator.backing)
		if ptr != nil do return sl.bytes_from_ptr(ptr, size), nil
		else do return nil, error
	case .Free:
		return nil, mem.free(old_memory)
	case .Free_All:
		return nil, .Mode_Not_Implemented
	case .Resize, .Resize_Non_Zeroed:
		ptr, error := mem.resize(old_memory, old_size, size, alignment, cage_allocator.backing)
		if ptr != nil do return sl.bytes_from_ptr(ptr, size), nil
		else do return sl.bytes_from_ptr(old_memory, old_size), error
	case .Query_Features:
		set := (^mem.Allocator_Mode_Set)(old_memory)
		if set != nil {
			set^ = {.Alloc, .Alloc_Non_Zeroed, .Free, .Resize, .Resize_Non_Zeroed, .Query_Features} }
		return nil, nil
	case .Query_Info:
		return nil, .Mode_Not_Implemented }
	return nil, nil }



/* ~~~~~~
    LOCK
   ~~~~~~ */

Lock :: struct {
	_mutex: sn.Ticket_Mutex,
	id: u32 }

lock_acquire :: #force_inline proc "contextless" (lock: ^Lock) {
	sn.ticket_mutex_lock(&lock._mutex) }

lock_release :: #force_inline proc "contextless" (lock: ^Lock) {
	sn.ticket_mutex_unlock(&lock._mutex) }

@(deferred_in=lock_release)
lock_guard :: proc "contextless" (lock: ^Lock) -> bool {
	lock_acquire(lock)
	return true }


Keeper :: struct {
	locks: [2]^Lock,
	len: u32 }


keeper_acquire_lock_unsafe :: #force_inline proc "contextless" (keeper: ^Keeper, lock: ^Lock) -> bool {
	if keeper.len >= 2 do return false
	lock_acquire(lock)
	keeper.locks[keeper.len] = lock
	keeper.len += 1
	return true }


keeper_acquire_lock :: #force_inline proc "contextless" (keeper: ^Keeper, lock: ^Lock, to_replace: ^Lock) -> bool {
	switch len(keeper.locks) {
	case 0:
		keeper_acquire_lock_unsafe(keeper, lock)
	case 1:
		other_lock: ^Lock = keeper.locks[0]
		if other_lock.id == lock.id do return false
		if other_lock.id < lock.id {
			keeper_acquire_lock_unsafe(keeper, lock) }
		else {
			keeper_release_lock(keeper, other_lock)
			keeper_acquire_lock_unsafe(keeper, lock)
			keeper_acquire_lock_unsafe(keeper, other_lock) }
	case 2:
		if to_replace == nil do return false
		keeper_release_lock(keeper, to_replace)
		other_lock: ^Lock = keeper.locks[0]
		if other_lock.id == lock.id do return false
		if other_lock.id < lock.id {
			keeper_acquire_lock_unsafe(keeper, lock) }
		else {
			keeper_release_lock(keeper, other_lock)
			keeper_acquire_lock_unsafe(keeper, lock)
			keeper_acquire_lock_unsafe(keeper, other_lock) } }
	return true }


keeper_release_lock :: #force_inline proc "contextless" (keeper: ^Keeper, lock: ^Lock) -> bool {
	if keeper.len == 0 do return false
	if keeper.locks[0] == lock {
		keeper.locks[0] = keeper.locks[1]
		keeper.locks[1] = nil }
	else if keeper.locks[1] == lock {
		keeper.locks[1] = nil }
	else do return false
	keeper.len -= 1
	return true }


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
	handle:  ^tr.Thread,
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


thread_proc :: proc(handle: ^tr.Thread) {
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
	sn.job_queue.allocator = context.allocator
	fmt.println(LOG, "Number of logical cores:", n_logical_cores)
	fmt.println(LOG, "Number of physical cores:", n_physical_cores)
	sn.n_logical_cores = min(n_physical_cores, n_logical_cores - n_relieved_cores)
	// sn.n_logical_cores = 1 // TEMP
	fmt.println(LOG, "Number of threads:", sn.n_logical_cores)
	for i in 0 ..< sn.n_logical_cores - 1 {
		thread = {}
		thread.data = new(Thread_Proc_Data)
		thread.data^ = {
			index = i + 1,
			job_queue = &sn.job_queue,
			thread_filters = { } }
		thread.filters = {}
		thread.handle = tr.create(procedure=thread_proc, priority=.Normal)
		thread.handle.data = cast(rawptr)thread.data
		thread.handle.init_context = runtime.default_context()
		append(&sn.threads, thread) } }


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
	lock_guard(&sn.lock)
	lock_guard(&sn.job_queue.lock)
	if draw.window_closed {
		sn.job_queue.terminate = true
		return }
	job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Clock", clock_tick, clock_tick_filters, Clock_Tick_Data{ clock=clock })
	// 	watch_data()
	job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Input", input_tick, input_tick_filters, Input_Tick_Data{ input=input })
	if clock.frame_rate_controller.should_tick && ! job_queue_contains(&sn.job_queue, draw_tick) {
		job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Draw", draw_tick, draw_tick_filters, Draw_Tick_Data{ draw=draw, camera=camera, physics=physics, clock=clock, sync=sync, input=input, working_directory_path=working_directory_path }) }
	job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Physics", physics_tick, physics_tick_filters, Physics_Tick_Data{ physics=physics, clock=clock, camera=camera })
	job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Camera", camera_tick, camera_tick_filters, Camera_Tick_Data{ camera=camera, input=input, ui=ui, physics=physics, clock=clock })
	// 	audio_tick()
	job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Sync", sync_tick, sync_tick_filters, Sync_Tick_Data{ sync=sync, clock=clock, draw=draw, camera=camera, physics=physics, input=input, ui=ui })
	// job_queue_append_non_duplicate(unwrap(&sn.job_queue), "Burnout", burnout_job, {}, Burnout_Job_Data{ job_queue=&sn.job_queue })
}


sync_start :: proc(sync: ^Sync) {
	for _, i in sn.threads {
		fmt.println("Starting thread", sn.threads[i].data.index)
		tr.start(sn.threads[i].handle) } }

*/