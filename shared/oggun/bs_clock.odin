#+feature using-stmt
package oggun
import "core:time"

// Clock :: struct {
// 	stopwatch_zero: time.Stopwatch,
// 	frame_rate_manager: Tick_Manager,
// 	net_time: f32,
// 	net_time_to_last_frame: f32 }

// (TODO): Rename this to something other than "Manager". Manager is only for things that have one instance per game. //
Tick_Manager :: struct {
	using tick_manager_config: Tick_Manager_Config,
	stopwatch:                 time.Stopwatch,
	tick_period_nsec:          i64,
	tick_period_sec:           f32,
	accumulation_to_now:       i64,
	accumulation_to_last_tick: i64,
	delta_time:                f32,
	time_sec:                  f32,
	frame_rate:                f32,
	measure_sec:               i32,
	// measure_period_sec:        i32,
	flag:                      bool }

Tick_Manager_Config :: struct {
	tickrate_setting: Tickrate_Setting }

DEFAULT_TICK_MANAGER_CONFIG: Tick_Manager_Config : {
	tickrate_setting = .LIMITED_144_FPS }

Tickrate_Setting :: enum {
	LIMITED_30_FPS = 0,
	LIMITED_60_FPS,
	LIMITED_120_FPS,
	LIMITED_144_FPS,
	LIMITED_240_FPS,
	LIMITED_540_FPS,
	UNLIMITED }

// clock_init :: proc(clock: ^Clock, framerate_config: Tickrate_Setting) {
// 	time.stopwatch_start(&clock.stopwatch_zero)
// 	tick_manager_init(&clock.frame_rate_manager, framerate_config)
// 	clock.net_time = 0.0
// 	clock.net_time_to_last_frame = 0.0 }

tick_manager_init :: proc(tick_man: ^Tick_Manager, config: Tick_Manager_Config) {
	tick_man.tick_manager_config = config
	time.stopwatch_start(&tick_man.stopwatch)
	tick_man.tick_period_nsec = FRAME_PERIODS_NSEC[cast(int)config.tickrate_setting]
	tick_man.tick_period_sec = FRAME_PERIODS_SEC[cast(int)config.tickrate_setting]
	tick_man.accumulation_to_now = 0.0
	tick_man.accumulation_to_last_tick = 0.0 }

tick_manager_tick :: proc(tick_man: ^Tick_Manager) -> bool {
	tick_man.accumulation_to_now = time.duration_nanoseconds(time.stopwatch_duration(tick_man.stopwatch))
	tick_man.time_sec = read_stopwatch(&tick_man.stopwatch)
	if tick_man.time_sec > cast(f32)tick_man.measure_sec {
		tick_man.frame_rate = 1.0 / tick_man.delta_time
		tick_man.measure_sec += 1 }
	if tick_man.flag do return false
	delta_time_nsec: i64 = tick_man.accumulation_to_now - tick_man.accumulation_to_last_tick
	if delta_time_nsec >= tick_man.tick_period_nsec {
		tick_man.delta_time = f32(cast(f64)delta_time_nsec / cast(f64)time.Second)
		tick_man.accumulation_to_last_tick = tick_man.accumulation_to_now
		tick_man.flag = true
		return true }
	return false }

tick_manager_reset :: proc(tick_man: ^Tick_Manager) {
	tick_man.flag = false }

FRAME_PERIODS_NSEC: [7]i64 = {
	PERIOD_30FPS_NSEC,
	PERIOD_60FPS_NSEC,
	PERIOD_120FPS_NSEC,
	PERIOD_144FPS_NSEC,
	PERIOD_240FPS_NSEC,
	PERIOD_540FPS_NSEC,
	PERIOD_UNLIMITED_NSEC }

PERIOD_30FPS_NSEC     : i64 : 33_333_333
PERIOD_60FPS_NSEC     : i64 : 16_666_666
PERIOD_120FPS_NSEC    : i64 : 8_333_333
PERIOD_144FPS_NSEC    : i64 : 6_944_444
PERIOD_240FPS_NSEC    : i64 : 4_166_666
PERIOD_540FPS_NSEC    : i64 : 1_851_851
PERIOD_UNLIMITED_NSEC : i64 : 0

FRAME_PERIODS_SEC: [7]f32 = {
	PERIOD_30FPS_SEC,
	PERIOD_60FPS_SEC,
	PERIOD_120FPS_SEC,
	PERIOD_144FPS_SEC,
	PERIOD_240FPS_SEC,
	PERIOD_540FPS_SEC,
	PERIOD_UNLIMITED_SEC }

PERIOD_30FPS_SEC     : f32 : f32(33_333_333) / f32(time.Second)
PERIOD_60FPS_SEC     : f32 : f32(16_666_666) / f32(time.Second)
PERIOD_120FPS_SEC    : f32 : f32(8_333_333)  / f32(time.Second)
PERIOD_144FPS_SEC    : f32 : f32(6_944_444)  / f32(time.Second)
PERIOD_240FPS_SEC    : f32 : f32(4_166_666)  / f32(time.Second)
PERIOD_540FPS_SEC    : f32 : f32(1_851_851)  / f32(time.Second)
PERIOD_UNLIMITED_SEC : f32 : 0

zero_stopwatch :: proc(timer: ^time.Stopwatch) {
	if timer.running {
		time.stopwatch_reset(timer) }
	time.stopwatch_start(timer) }

read_stopwatch :: proc(timer: ^time.Stopwatch) -> f32 {
	return cast(f32)time.duration_seconds(time.stopwatch_duration(timer^)) }

// Clock_Tick_Data :: struct {
// 	clock: ^Locked_Struct(Clock) }
// clock_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag="job") clock_tick :: proc(data_ptr: rawptr) {
// 	// fmt.println("Clock Tick")
// 	data := cast(^Clock_Tick_Data)data_ptr
// 	defer free(data)
// 	using data
// 	lock_guard(&clock.lock)
// 	tick_manager_tick(&clock.frame_rate_manager)
// 	clock.net_time = read_stopwatch(&clock.stopwatch_zero)
// 	clock.net_time_to_last_frame = cast(f32)time.duration_seconds(cast(time.Duration)clock.frame_rate_manager.accumulation_to_last_tick)
// 	// if frame_count % 30 == 0 { fps = f32(f32(frame_count) / net_time) }
// 	}
