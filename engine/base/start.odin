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


Entry_Point :: #type proc(data: ^Thread_Data)


Thread_Data :: struct {
	entry_point: Entry_Point,
	index: u32 }


worker_proc :: proc(data: rawptr) {
	thread_data: ^Thread_Data = cast(^Thread_Data)data
	thread_data.entry_point(thread_data) }


start :: proc(entry_point: Entry_Point) {

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

	///////////////////
	// Start workers //
	for i in 0 ..< n_workers {
		data: ^Thread_Data = new(Thread_Data)
		data.entry_point = entry_point
		data.index = i
		if i > 0 do tr.create_and_start_with_data(data, worker_proc, rt.default_context(), .Normal)
		else do worker_proc(data) } }

