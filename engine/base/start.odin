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
import "shared:ranked_mutex"
import ts "../container/two_stack"


worker_proc :: proc(data: rawptr) {
	thread_data: ^Thread_Data = cast(^Thread_Data)data
	thread_data._entry_point(thread_data) }


start :: proc(entry_point: Entry_Point, n_workers_override: Maybe(u32) = nil) {

	////////////////////////////
	// Determine worker count //
	HEADROOM: u32 : 3
	system_info: win.SYSTEM_INFO
	win.GetSystemInfo(&system_info)
	n_logical_cores: u32 = system_info.dwNumberOfProcessors
	info_size: u32
	win.GetLogicalProcessorInformation(nil, &info_size)
	logical_processor_info: []win.SYSTEM_LOGICAL_PROCESSOR_INFORMATION = make([]win.SYSTEM_LOGICAL_PROCESSOR_INFORMATION, info_size / size_of(win.SYSTEM_LOGICAL_PROCESSOR_INFORMATION))
	win.GetLogicalProcessorInformation(&logical_processor_info[0], &info_size)
	n_physical_cores: u32 = 0
	for info in logical_processor_info do if info.Relationship == .RelationProcessorCore do n_physical_cores += 1
	n_workers: u32 = n_logical_cores - HEADROOM
	if n_workers_override != nil do n_workers = n_workers_override.(u32)

	///////////////////
	// Start workers //
	for i in 0 ..< n_workers {
		data: ^Thread_Data = make_thread_data(entry_point, i)
		thread_context: rt.Context = rt.default_context()
		thread_context.user_ptr = data
		if i > 0 do tr.create_and_start_with_data(data, worker_proc, thread_context, .Normal)
		else do worker_proc(data) } }

