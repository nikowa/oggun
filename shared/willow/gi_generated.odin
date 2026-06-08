package willow
// Generated at 14:06:57 //


gi_disabled_get :: proc() -> bool {
	if len(engine.gi_manager.disabled_stack) == 0 do return false
	return engine.gi_manager.disabled_stack[len(engine.gi_manager.disabled_stack) - 1] }

@(deferred_none=gi_disabled_pop)
gi_disabled_scope :: proc(disabled: bool) {
	gi_disabled_push(disabled) }

gi_disabled_push :: proc(disabled: bool) {
	append(&engine.gi_manager.disabled_stack, disabled) }

gi_disabled_pop :: proc() -> (res: bool, ok: bool) {
	return pop_safe(&engine.gi_manager.disabled_stack) }

gi_button_shape_get :: proc() -> GI_Button_Shape {
	if len(engine.gi_manager.button_shape_stack) == 0 do return .ROUNDED
	return engine.gi_manager.button_shape_stack[len(engine.gi_manager.button_shape_stack) - 1] }

@(deferred_none=gi_button_shape_pop)
gi_button_shape_scope :: proc(button_shape: GI_Button_Shape) {
	gi_button_shape_push(button_shape) }

gi_button_shape_push :: proc(button_shape: GI_Button_Shape) {
	append(&engine.gi_manager.button_shape_stack, button_shape) }

gi_button_shape_pop :: proc() -> (res: GI_Button_Shape, ok: bool) {
	return pop_safe(&engine.gi_manager.button_shape_stack) }

gi_appearance_get :: proc() -> GI_Appearance {
	if len(engine.gi_manager.appearance_stack) == 0 do return .DEFAULT
	return engine.gi_manager.appearance_stack[len(engine.gi_manager.appearance_stack) - 1] }

@(deferred_none=gi_appearance_pop)
gi_appearance_scope :: proc(appearance: GI_Appearance) {
	gi_appearance_push(appearance) }

gi_appearance_push :: proc(appearance: GI_Appearance) {
	append(&engine.gi_manager.appearance_stack, appearance) }

gi_appearance_pop :: proc() -> (res: GI_Appearance, ok: bool) {
	return pop_safe(&engine.gi_manager.appearance_stack) }

gi_text_style_get :: proc() -> Text_Style {
	if len(engine.gi_manager.text_style_stack) == 0 do return engine.gi_manager.text_style
	return engine.gi_manager.text_style_stack[len(engine.gi_manager.text_style_stack) - 1] }

@(deferred_none=gi_text_style_pop)
gi_text_style_scope :: proc(text_style: Text_Style) {
	gi_text_style_push(text_style) }

gi_text_style_push :: proc(text_style: Text_Style) {
	append(&engine.gi_manager.text_style_stack, text_style) }

gi_text_style_pop :: proc() -> (res: Text_Style, ok: bool) {
	return pop_safe(&engine.gi_manager.text_style_stack) }
