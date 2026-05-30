package willow

gui_button :: proc(rect: Rect, disabled: bool = false) -> (actions: bit_set[GUI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }
