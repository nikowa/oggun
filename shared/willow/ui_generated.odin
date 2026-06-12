package willow
// Generated at 19:55:03 //


ui_disabled_get :: proc() -> bool {
	if len(engine.ui_manager.disabled_stack) == 0 do return false
	return engine.ui_manager.disabled_stack[len(engine.ui_manager.disabled_stack) - 1] }

@(deferred_none=ui_disabled_pop)
ui_disabled_scope :: proc(disabled: bool) {
	ui_disabled_push(disabled) }

ui_disabled_push :: proc(disabled: bool) {
	append(&engine.ui_manager.disabled_stack, disabled) }

ui_disabled_pop :: proc() -> (res: bool, ok: bool) {
	return pop_safe(&engine.ui_manager.disabled_stack) }

ui_button_shape_get :: proc() -> UI_Button_Shape {
	if len(engine.ui_manager.button_shape_stack) == 0 do return .ROUNDED
	return engine.ui_manager.button_shape_stack[len(engine.ui_manager.button_shape_stack) - 1] }

@(deferred_none=ui_button_shape_pop)
ui_button_shape_scope :: proc(button_shape: UI_Button_Shape) {
	ui_button_shape_push(button_shape) }

ui_button_shape_push :: proc(button_shape: UI_Button_Shape) {
	append(&engine.ui_manager.button_shape_stack, button_shape) }

ui_button_shape_pop :: proc() -> (res: UI_Button_Shape, ok: bool) {
	return pop_safe(&engine.ui_manager.button_shape_stack) }

ui_appearance_get :: proc() -> UI_Appearance {
	if len(engine.ui_manager.appearance_stack) == 0 do return .DEFAULT
	return engine.ui_manager.appearance_stack[len(engine.ui_manager.appearance_stack) - 1] }

@(deferred_none=ui_appearance_pop)
ui_appearance_scope :: proc(appearance: UI_Appearance) {
	ui_appearance_push(appearance) }

ui_appearance_push :: proc(appearance: UI_Appearance) {
	append(&engine.ui_manager.appearance_stack, appearance) }

ui_appearance_pop :: proc() -> (res: UI_Appearance, ok: bool) {
	return pop_safe(&engine.ui_manager.appearance_stack) }

ui_text_style_get :: proc() -> Text_Style {
	if len(engine.ui_manager.text_style_stack) == 0 do return engine.ui_manager.text_style
	return engine.ui_manager.text_style_stack[len(engine.ui_manager.text_style_stack) - 1] }

@(deferred_none=ui_text_style_pop)
ui_text_style_scope :: proc(text_style: Text_Style) {
	ui_text_style_push(text_style) }

ui_text_style_push :: proc(text_style: Text_Style) {
	append(&engine.ui_manager.text_style_stack, text_style) }

ui_text_style_pop :: proc() -> (res: Text_Style, ok: bool) {
	return pop_safe(&engine.ui_manager.text_style_stack) }
