#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

gi_logic_button :: proc(rect: Rect) -> (actions: bit_set[GUI_Action]) {
	hovered := rect_hovered(rect)
	pressed := hovered && input_query(.Mouse_Left, .PRESSED)
	disabled := gi_get_disabled()
	if hovered do actions += { .HOVER }
	if pressed do actions += { .PRESS }
	if hovered {
		if disabled do set_cursor(.Disabled)
		else do set_cursor(.Hand) }
	return actions }
