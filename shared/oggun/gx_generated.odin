package oggun
// Generated at 10:51:54 //


gx_clip_get :: proc() -> Clip {
	if len(state.graphics_manager.clip_stack) == 0 do return { ui_rect_screen(), 0 }
	return state.graphics_manager.clip_stack[len(state.graphics_manager.clip_stack) - 1] }

@(deferred_none=gx_clip_pop)
gx_clip_scope :: proc(clip: Clip) {
	gx_clip_push(clip) }

gx_clip_push :: proc(clip: Clip) {
	append(&state.graphics_manager.clip_stack, clip) }

gx_clip_pop :: proc() -> (res: Clip, ok: bool) {
	return pop_safe(&state.graphics_manager.clip_stack) }

gx_depth_get :: proc() -> f32 {
	if len(state.graphics_manager.depth_stack) == 0 do return 0.999999
	return state.graphics_manager.depth_stack[len(state.graphics_manager.depth_stack) - 1] }

@(deferred_none=gx_depth_pop)
gx_depth_scope :: proc(depth: f32) {
	gx_depth_push(depth) }

gx_depth_push :: proc(depth: f32) {
	append(&state.graphics_manager.depth_stack, depth) }

gx_depth_pop :: proc() -> (res: f32, ok: bool) {
	return pop_safe(&state.graphics_manager.depth_stack) }
