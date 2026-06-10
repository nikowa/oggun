#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

ui_control_camera_2d :: proc() {
}

ui_control_button :: proc(rect: Rect) -> (actions: bit_set[UI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	disabled := ui_disabled_get()
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }
