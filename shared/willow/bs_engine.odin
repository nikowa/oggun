#+feature using-stmt
package willow
import "base:runtime"
import "core:thread"
import "core:sys/windows"
import "core:log"
import "core:mem"
import "core:time"
import "core:slice"

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

Engine_Config :: struct {
	game_name: string,
	backing_allocator: runtime.Allocator,
	temp_allocator_cap: uintptr,
	log_backing_allocations: bool,
	log_temp_allocations: bool,
	track_backing_allocations: bool,
	track_temp_allocations: bool }

DEFAULT_ENGINE_CONFIG: Engine_Config : {
	game_name = "Willow Game",
	backing_allocator = {},
	temp_allocator_cap = 100 * mem.Megabyte,
	log_backing_allocations = false,
	log_temp_allocations = false,
	track_backing_allocations = false,
	track_temp_allocations = false }

Engine :: struct {
	using engine_config: Engine_Config,
	ticked: bool,
	tick_count: uint,
	stopwatch: time.Stopwatch,
	temp_arena: mem.Arena,
	asset_manager: Asset_Manager,
	input_manager: Input_Manager,
	graphics_manager: Graphics_Manager,
	window_manager: Window_Manager,
	tick_manager: Tick_Manager,
	gi_manager: GI_Manager,
	settings_manager: Settings_Manager,
	log_allocator: log.Log_Allocator,
	log_temp_allocator: log.Log_Allocator,
	tracking_allocator: mem.Tracking_Allocator,
	tracking_temp_allocator: mem.Tracking_Allocator }

engine_end_init :: proc() -> runtime.Context {
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

ptr_is_temp :: proc(ptr: rawptr) -> bool {
	return (cast(uintptr)ptr >= cast(uintptr)slice.first_ptr(engine.temp_arena.data)) &&
	       (cast(uintptr)ptr <= cast(uintptr)slice.last_ptr(engine.temp_arena.data)) }

@require_results
engine_begin_init :: proc(
		engine_config: Engine_Config = DEFAULT_ENGINE_CONFIG,
		asset_config: Asset_Manager_Config = DEFAULT_ASSET_MANAGER_CONFIG,
		window_config: Window_Config = DEFAULT_WINDOW_CONFIG,
		graphics_config: Graphics_Config = DEFAULT_GRAPHICS_CONFIG,
		tick_config: Tick_Manager_Config = DEFAULT_TICK_MANAGER_CONFIG,
		input_config: Input_Config = DEFAULT_INPUT_CONFIG,
		settings_config: Settings_Manager_Config = DEFAULT_SETTINGS_MANAGER_CONFIG) -> runtime.Context {
	engine = new(Engine)
	engine.engine_config = engine_config
	context.logger = log.create_console_logger()
	mem.arena_init(&engine.temp_arena, make([]u8, engine.temp_allocator_cap))
	context.temp_allocator = mem.arena_allocator(&engine.temp_arena)
	allocator := context.allocator
	temp_allocator := context.temp_allocator
	if engine.log_backing_allocations {
		log.log_allocator_init(&engine.log_allocator, level=.Debug, size_fmt=.Human, allocator=allocator)
		allocator = log.log_allocator(&engine.log_allocator) }
	if engine.log_temp_allocations {
		log.log_allocator_init(&engine.log_temp_allocator, level=.Debug, size_fmt=.Human, allocator=temp_allocator)
		temp_allocator = log.log_allocator(&engine.log_temp_allocator) }
	if engine.track_backing_allocations {
		mem.tracking_allocator_init(&engine.tracking_allocator, allocator)
		allocator = mem.tracking_allocator(&engine.tracking_allocator) }
	if engine.track_temp_allocations {
		mem.tracking_allocator_init(&engine.tracking_temp_allocator, temp_allocator)
		temp_allocator = mem.tracking_allocator(&engine.tracking_temp_allocator) }
	context.allocator = allocator
	context.temp_allocator = temp_allocator
	if engine.backing_allocator == {} do engine.backing_allocator = context.allocator
	am_init(asset_config)
	wd_init(window_config)
	graphics_init(graphics_config)
	gi_init()
	input_init(input_config)
	settings_manager_init(&engine.settings_manager, settings_config)
	tick_manager_init(&engine.tick_manager, tick_config)
	zero_stopwatch(&engine.stopwatch)
	return context }

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
		engine.tick_count += 1
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
