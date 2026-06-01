#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"

TGUI_Anim_Transition :: struct {
	value: f32,
	action_time: time.Duration,
	action_value: f32,
	direction: bool }

tgui_anim_transition :: proc(range: [2]f32, initial_value: f32, speed: f32, initial_direction: bool, action: bool, location := #caller_location) -> (value: f32) {
	assert(range[1] > range[0])
	action := action
	state, ok := engine.tgui_manager.anim_transitions[location]
	time_now := time.stopwatch_duration(engine.stopwatch)
	if ! ok {
		action = true
		state = { value = initial_value, action_time = time_now, action_value = initial_value, direction = initial_direction } }
	if action {
		state.action_time = time_now
		state.action_value = state.value
		state.direction = ! state.direction }
	time_passed := time.duration_seconds(time_now - state.action_time)
	if state.direction {
		period: f32 = (1 / speed) * (range[1] - state.action_value) / (range[1] - range[0])
		if period > 0 do state.value = math.lerp(state.action_value, range[1], f32(time_passed) / period) }
	else {
		period: f32 = (1 / speed) * (state.action_value - range[0]) / (range[1] - range[0])
		if period > 0 do state.value = math.lerp(state.action_value, range[0], f32(time_passed) / period) }
	state.value = clamp(state.value, range[0], range[1])
	engine.tgui_manager.anim_transitions[location] = state
	// fmt.println(state.value)
	return state.value }
