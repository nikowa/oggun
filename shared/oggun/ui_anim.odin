#+feature using-stmt
package oggun
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"

UI_Anim_Transition :: struct {
	value: f32,
	action_time: time.Duration,
	action_value: f32,
	direction: bool }

ui_anim_transition :: proc(range: [2]f32, initial_value: f32, speed: f32, initial_direction: bool, action: bool, location := #caller_location) -> (value: f32) {
	assert(range[1] > range[0])
	action := action
	transition, ok := state.ui_manager.anim_transitions[location]
	time_now := time.stopwatch_duration(state.stopwatch)
	if ! ok {
		action = true
		transition = { value = initial_value, action_time = time_now, action_value = initial_value, direction = initial_direction } }
	if action {
		transition.action_time = time_now
		transition.action_value = transition.value
		transition.direction = ! transition.direction }
	time_passed := time.duration_seconds(time_now - transition.action_time)
	if transition.direction {
		period: f32 = (1 / speed) * (range[1] - transition.action_value) / (range[1] - range[0])
		if period > 0 do transition.value = math.lerp(transition.action_value, range[1], f32(time_passed) / period) }
	else {
		period: f32 = (1 / speed) * (transition.action_value - range[0]) / (range[1] - range[0])
		if period > 0 do transition.value = math.lerp(transition.action_value, range[0], f32(time_passed) / period) }
	transition.value = clamp(transition.value, range[0], range[1])
	state.ui_manager.anim_transitions[location] = transition
	// fmt.println(transition.value)
	return transition.value }
