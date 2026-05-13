#+feature using-stmt
package willow
import "base:runtime"
import "core:thread"
import "core:sys/windows"
import "core:log"

WILLOW_VERSION: [3]u16 : { 0, 0, 1 }

Entry_Point :: #type proc(data: ^Thread_Data)

@(private="file")
MAGIC_NUMBER :: 0b10110011_00001011_01010011_10001101
Thread_Data :: struct {
	index: u32,
	_magic_number: u32,
	_entry_point: Entry_Point }

make_thread_data :: proc(entry_point: Entry_Point, index: u32) -> (thread_data: ^Thread_Data) {
	thread_data = new(Thread_Data)
	thread_data._magic_number = MAGIC_NUMBER
	thread_data._entry_point = entry_point
	thread_data.index = index
	return thread_data }

get_thread_data :: #force_inline proc() -> (thread_data: ^Thread_Data) {
	thread_data = cast(^Thread_Data)context.user_ptr
	assert(thread_data._magic_number == MAGIC_NUMBER)
	return thread_data }

@private
worker_proc :: proc(data: rawptr) {
	thread_data: ^Thread_Data = cast(^Thread_Data)data
	thread_data._entry_point(thread_data) }

start :: proc(entry_point: Entry_Point, n_workers_override: Maybe(u32) = nil) {
	log.info("Starting engine.")

	////////////////////////////
	// Determine worker count //
	HEADROOM: u32 : 3
	system_info: windows.SYSTEM_INFO
	windows.GetSystemInfo(&system_info)
	n_logical_cores: u32 = system_info.dwNumberOfProcessors
	info_size: u32
	windows.GetLogicalProcessorInformation(nil, &info_size)
	logical_processor_info: []windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION = make([]windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION, info_size / size_of(windows.SYSTEM_LOGICAL_PROCESSOR_INFORMATION))
	windows.GetLogicalProcessorInformation(&logical_processor_info[0], &info_size)
	n_physical_cores: u32 = 0
	for info in logical_processor_info do if info.Relationship == .RelationProcessorCore do n_physical_cores += 1
	n_workers: u32 = n_logical_cores - HEADROOM
	if n_workers_override != nil do n_workers = n_workers_override.(u32)

	///////////////////
	// Start workers //
	for i in 0 ..< n_workers {
		data: ^Thread_Data = make_thread_data(entry_point, i)
		thread_context: runtime.Context = runtime.default_context()
		thread_context.user_ptr = data
		if i > 0 do thread.create_and_start_with_data(data, worker_proc, thread_context, .Normal)
		else do worker_proc(data) } }

