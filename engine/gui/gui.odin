#+feature using-stmt
package gui
// User interface and character controller. //


UI :: struct {
	screen:  Screen,
	control: Control,
	running: bool,
	prompts: bit_set[Prompts],
	hovered_index:int }


Screen::enum {
	TITLE,
	GAME }


Prompts :: enum {
	START,
	EXIT,
	RESPAWN,
	SWIM_FORWARD,
	GET_ON_THE_SURF,
	PADDLE,
	STAND_UP }


ui_init :: proc(ui: ^UI) {
	ui.prompts += { .START, .EXIT }
	ui.screen = .GAME
	ui.running = true
	ui.control = .SURFER }

