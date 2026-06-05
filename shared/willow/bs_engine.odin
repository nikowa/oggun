#+feature using-stmt
package willow
import "base:runtime"
import "core:thread"
import "core:sys/windows"
import "core:log"
import "core:mem"
import "core:time"

// asset_manager: Asset_Manager
// input_manager: Input_Manager
// graphics_manager: Graphics_Manager
// window_manager: Window_Manager
// tick_manager: Tick_Manager
// stopwatch: time.Stopwatch
// gi_manager: GI_Manager

WILLOW_VERSION: [3]u16 : { 0, 0, 1 }
nil_stub: rawptr
NIL_STUB_SIZE :: 1 * mem.Megabyte
DEFAULT_NAME :: "unnamed"

Entry_Point :: #type proc(data: ^Thread_Data)

Engine :: struct {
	game_name: string,
	ticked: bool,
	stopwatch: time.Stopwatch,
	backing_allocator: runtime.Allocator,
	asset_manager: Asset_Manager,
	input_manager: Input_Manager,
	graphics_manager: Graphics_Manager,
	window_manager: Window_Manager,
	tick_manager: Tick_Manager,
	gi_manager: GI_Manager,
	settings_manager: Settings_Manager }

engine_loop_context :: proc() -> runtime.Context {
	// (NOTE): During the game loop, all allocation will use the temp allocator by default. Non-transient allocations should
	// explicitly use "engine.backing_allocator".
	engine.backing_allocator = context.allocator
	context.allocator = context.temp_allocator
	return context }

engine: ^Engine

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

ptr_is_nil :: proc(ptr: ^$T) -> bool {
	return (ptr == nil) || (ptr == nil_stub) }

engine_init :: proc(
		game_name: string,
		asset_config: Asset_Manager_Config = DEFAULT_ASSET_MANAGER_CONFIG,
		window_config: Window_Config = DEFAULT_WINDOW_CONFIG,
		graphics_config: Graphics_Config = DEFAULT_GRAPHICS_CONFIG,
		tick_config: Tick_Manager_Config = DEFAULT_TICK_MANAGER_CONFIG,
		input_config: Input_Config = DEFAULT_INPUT_CONFIG,
		settings_config: Settings_Manager_Config = DEFAULT_SETTINGS_MANAGER_CONFIG,
		backing_allocator := context.allocator) {
	engine = new(Engine)
	engine.backing_allocator = backing_allocator
	engine.game_name = game_name
	am_init(asset_config, backing_allocator)
	wd_init(window_config)
	graphics_init(graphics_config)
	gi_init()
	input_init(input_config)
	settings_manager_init(&engine.settings_manager, settings_config)
	tick_manager_init(&engine.tick_manager, tick_config)
	zero_stopwatch(&engine.stopwatch) }

engine_running :: proc() -> bool {
	return ! engine.graphics_manager.window_closed }

@(deferred_none=engine_tick_end)
engine_tick :: proc() -> bool {
	return engine_tick_begin() }

engine_tick_begin :: proc() -> bool {
	if tick_manager_tick(&engine.tick_manager) {
		am_tick()
		window_tick()
		tick_graphics_manager()
		input_manager_tick()
		engine.ticked = true
		return true }
	return false }

engine_tick_end :: proc() {
	if engine.ticked {
		tick_manager_reset(&engine.tick_manager)
		engine.ticked = false }
	free_all(context.allocator) }

start :: proc(entry_point: Entry_Point, n_workers_override: Maybe(u32) = nil) {
	log.info("Starting engine.")

	stub := make([]u8, NIL_STUB_SIZE)
	nil_stub = cast(rawptr)&stub[0]

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

	// Start workers //
	for i in 0 ..< n_workers {
		data: ^Thread_Data = make_thread_data(entry_point, i)
		thread_context: runtime.Context = runtime.default_context()
		thread_context.user_ptr = data
		if i > 0 do thread.create_and_start_with_data(data, worker_proc, thread_context, .Normal)
		else do worker_proc(data) } }
