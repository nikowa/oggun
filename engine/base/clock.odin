#+feature using-stmt
package base
import fmt "core:fmt"
import tm "core:time"



// Clock :: struct {
// 	stopwatch_zero: time.Stopwatch,
// 	frame_rate_controller: Tick_Rate_Controller,
// 	net_time: f32,
// 	net_time_to_last_frame: f32 }


// Tick_Rate_Controller :: struct {
// 	tickrate_config:           Tickrate_Config,
// 	stopwatch:                 time.Stopwatch,
// 	tick_period_nsec:          i64,
// 	tick_period_sec:           f32,
// 	accumulation_to_now:       i64,
// 	accumulation_to_last_tick: i64,
// 	should_tick:               bool } // NOTE: "should_tick" must be set to false after the respective tick procedure has been executed.


// clock_init :: proc(clock: ^Clock, framerate_config: Tickrate_Config) {
// 	time.stopwatch_start(&clock.stopwatch_zero)
// 	tick_rate_controller_init(&clock.frame_rate_controller, framerate_config)
// 	clock.net_time = 0.0
// 	clock.net_time_to_last_frame = 0.0 }


// tick_rate_controller_init :: proc(controller: ^Tick_Rate_Controller, tickrate_config: Tickrate_Config) {
// 	controller.tickrate_config = tickrate_config
// 	time.stopwatch_start(&controller.stopwatch)
// 	controller.tick_period_nsec = FRAME_PERIODS_NSEC[cast(int)tickrate_config]
// 	controller.tick_period_sec = FRAME_PERIODS_SEC[cast(int)tickrate_config]
// 	controller.accumulation_to_now = 0.0
// 	controller.accumulation_to_last_tick = 0.0
// 	controller.should_tick = true }


// tick_rate_controller_tick :: proc(controller: ^Tick_Rate_Controller) {
// 	using controller
// 	accumulation_to_now = time.duration_nanoseconds(time.stopwatch_duration(stopwatch))
// 	if accumulation_to_now - accumulation_to_last_tick >= tick_period_nsec {
// 		should_tick = true
// 		accumulation_to_last_tick += tick_period_nsec } }


// FRAME_PERIODS_NSEC := [?]i64{
// 	PERIOD_30FPS_NSEC,
// 	PERIOD_60FPS_NSEC,
// 	PERIOD_120FPS_NSEC,
// 	PERIOD_144FPS_NSEC,
// 	PERIOD_240FPS_NSEC,
// 	PERIOD_540FPS_NSEC,
// 	PERIOD_UNLIMITED_NSEC }


// PERIOD_30FPS_NSEC:i64:33_333_333
// PERIOD_60FPS_NSEC:i64:16_666_666
// PERIOD_120FPS_NSEC:i64:8_333_333
// PERIOD_144FPS_NSEC:i64:6_944_444
// PERIOD_240FPS_NSEC:i64:4_166_666
// PERIOD_540FPS_NSEC:i64:1_851_851
// PERIOD_UNLIMITED_NSEC:i64:0


// FRAME_PERIODS_SEC := [?]f32{
// 	PERIOD_30FPS_SEC,
// 	PERIOD_60FPS_SEC,
// 	PERIOD_120FPS_SEC,
// 	PERIOD_144FPS_SEC,
// 	PERIOD_240FPS_SEC,
// 	PERIOD_540FPS_SEC,
// 	PERIOD_UNLIMITED_SEC }


// PERIOD_30FPS_SEC:f32:f32(33_333_333)/f32(time.Second)
// PERIOD_60FPS_SEC:f32:f32(16_666_666)/f32(time.Second)
// PERIOD_120FPS_SEC:f32:f32(8_333_333)/f32(time.Second)
// PERIOD_144FPS_SEC:f32:f32(6_944_444)/f32(time.Second)
// PERIOD_240FPS_SEC:f32:f32(4_166_666)/f32(time.Second)
// PERIOD_540FPS_SEC:f32:f32(1_851_851)/f32(time.Second)
// PERIOD_UNLIMITED_SEC:f32:0


// Tickrate_Config :: enum {
// 	LIMITED_30_FPS = 0,
// 	LIMITED_60_FPS,
// 	LIMITED_120_FPS,
// 	LIMITED_144_FPS,
// 	LIMITED_240_FPS,
// 	LIMITED_540_FPS,
// 	UNLIMITED }


// zero_stopwatch::proc(timer:^time.Stopwatch) {
// 	if timer.running {
// 		time.stopwatch_reset(timer) }
// 	time.stopwatch_start(timer) }


// read_stopwatch::proc(timer:^time.Stopwatch)->f32 {
// 	return f32(time.duration_seconds(time.stopwatch_duration(timer^))) }


// Clock_Tick_Data :: struct {
// 	clock: ^Locked_Struct(Clock) }
// clock_tick_filters: Thread_Filters : { .MAIN_THREAD }
// @(tag="job") clock_tick :: proc(data_ptr: rawptr) {
// 	// fmt.println("Clock Tick")
// 	data := cast(^Clock_Tick_Data)data_ptr
// 	defer free(data)
// 	using data
// 	lock_guard(&clock.lock)
// 	tick_rate_controller_tick(&clock.frame_rate_controller)
// 	clock.net_time = read_stopwatch(&clock.stopwatch_zero)
// 	clock.net_time_to_last_frame = cast(f32)time.duration_seconds(cast(time.Duration)clock.frame_rate_controller.accumulation_to_last_tick)
// 	// if frame_count % 30 == 0 { fps = f32(f32(frame_count) / net_time) }
// 	}
