// #+feature using-stmt
// package surf_game
// import "base:runtime"
// import "core:fmt"
// import "core:mem"
// import "core:path/filepath"
// import "core:time"
// import tr "core:thread"
// import "vendor:glfw"


// // TODO: Each thread will have it's own temporary allocator.
// // state:^State
// // TEMP_ARENA_SIZE::64*mem.Megabyte
// // mem.arena_init(&temp_arena,make([]u8,TEMP_ARENA_SIZE))
// // temp_allocator=mem.arena_allocator(&temp_arena)
// // context.temp_allocator=temp_allocator


// // (NOTE): All globals much be locked, in order to avoid conflicts between threads. If a thread wants to


// // (DESC): Read & Write //
// // (NOTE): All the locked objects have to defined in a sequence of adjacent lines, otherwise the ordering system will not work. //
// cache:               Locked_Struct(Cache)             = { rank = #line }
// camera:              Locked_Struct(Camera)            = { rank = #line }
// clock:               Locked_Struct(Clock)             = { rank = #line }
// draw:                Locked_Struct(Draw)              = { rank = #line }
// input:               Locked_Struct(Input)             = { rank = #line }
// physics:             Locked_Struct(Physics)           = { rank = #line }
// settings:            Locked_Struct(Settings)          = { rank = #line }
// ui:                  Locked_Struct(UI)                = { rank = #line }
// audio:               Locked_Struct(Audio)             = { rank = #line }
// sync:                Locked_Struct(Sync)              = { rank = #line,
// 	job_queue = { rank = #line } }
// backing_allocator:   Locked_Object(runtime.Allocator) = { rank = #line }
// main_allocator:      Locked_Object(runtime.Allocator) = { rank = #line }
// frame_count:         Locked_Object(u64)               = { rank = #line }
// fps:                 Locked_Object(f32)               = { rank = #line }
// net_time:            Locked_Object(f32)               = { rank = #line }
// reload_scene:        Locked_Object(bool)              = { rank = #line }
// crosshair_gap:       Locked_Object(int)               = { rank = #line }
// crosshair_thickness: Locked_Object(int)               = { rank = #line }
// crosshair_length:    Locked_Object(int)               = { rank = #line }
// crosshair_color:     Locked_Object([3]f32)            = { rank = #line }


// // (DESC): Read-only //
// working_directory_path: string


// main :: proc() {
// 	MAIN_ARENA_SIZE:    int : 2048 * mem.Megabyte
// 	mutex_allocator:    mem.Mutex_Allocator
// 	main_arena:         mem.Arena
// 	thread_proc_data:   Thread_Proc_Data
// 	main_thread_handle: tr.Thread

// 	mem.mutex_allocator_init(&mutex_allocator, context.allocator)
// 	backing_allocator.object = mem.mutex_allocator(&mutex_allocator)
// 	mem.arena_init(&main_arena, make([]u8, MAIN_ARENA_SIZE))
// 	main_allocator = { object=mem.arena_allocator(&main_arena) }
// 	context.allocator = main_allocator.object
// 	working_directory_path = filepath.dir(get_executable_path())
// 	settings_default(unwrap(&settings))
// 	// (TODO): Why aren't the initialization functions called in separate threads?
// 	sync_init(unwrap(&sync))
// 	cache_init(unwrap(&cache))
// 	clock_init(unwrap(&clock), .LIMITED_60_FPS)
// 	audio_init(unwrap(&audio))
// 	graphics_init(unwrap(&draw), unwrap(&cache), working_directory_path, &settings.graphics)
// 	input_init(unwrap(&input), draw.window)
// 	shaders_init(unwrap(&draw), working_directory_path)
// 	physics_init(unwrap(&physics), &draw.model_instances)
// 	camera_init(unwrap(&camera), draw.window_size)
// 	ui_init(unwrap(&ui))
// 	ink_init()
// 	play_sound(&audio, clock.net_time, "music", true)
// 	fmt.println(LOG, "Initialized.")
// 	{
// 		lock_guard(&sync.job_queue.lock)
// 		job_queue_append(unwrap(&sync.job_queue), "Sync", sync_tick, sync_tick_filters, Sync_Tick_Data{sync=&sync, clock=&clock, draw=&draw, camera=&camera, physics=&physics, input=&input, ui=&ui, working_directory_path = working_directory_path })
// 	}
// 	thread_proc_data = { job_queue = &sync.job_queue, thread_filters = { .MAIN_THREAD } }
// 	main_thread_handle = {
// 		data = cast(rawptr)&thread_proc_data,
// 		init_context = context,
// 		creation_allocator = context.allocator }
// 	{
// 		lock_guard(&sync.lock)
// 		sync_start(unwrap(&sync))
// 	}
// 	thread_proc(&main_thread_handle)
// 	draw_destroy(unwrap(&draw))
// 	free_all(context.allocator) }

