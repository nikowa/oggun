#+feature using-stmt
package dialogue
import "base:runtime"
import "core:fmt"


Ink_Proc :: #type proc(data: rawptr)


Ink_Text :: struct {
	content: string,
	next:    Ink_Block,
	outcome: Ink_Proc }


Ink_Choices :: struct {
	choices: [dynamic]Ink_Text,
	next:    Ink_Block,
	outcome: Ink_Proc }


Ink_Block :: union {
	^Ink_Text,
	^Ink_Choices }


Ink :: struct {
	first:     Ink_Block,
	allocator: runtime.Allocator }


new_ink :: proc(allocator := context.allocator) -> (ink: Ink, next_ptr: ^Ink_Block) {
	ink.allocator = allocator
	return ink, &ink.first }


ink_text :: proc(next_ptr: ^Ink_Block, content: string, outcome: Ink_Proc = nil) -> (result_ptr: ^Ink_Text, next_next_ptr: ^Ink_Block) {
	text: ^Ink_Text

	text = new(Ink_Text)
	next_ptr^ = text
	text.content = content
	text.outcome = outcome
	return text, &text.next }


ink_choices :: proc(next_ptr: ^Ink_Block, outcome: Ink_Proc = nil) -> (result_ptr: ^Ink_Choices, next_next_ptr: ^Ink_Block) {
	choices: ^Ink_Choices

	choices = new(Ink_Choices)
	next_ptr^ = choices
	choices.outcome = outcome
	return choices, &choices.next }


ink_choice :: proc(choices_ptr: ^Ink_Choices, content: string, outcome: Ink_Proc = nil) -> (result_ptr: ^Ink_Text, next_next_ptr: ^Ink_Block) {
	text: Ink_Text

	text.content = content
	text.outcome = outcome
	append(&choices_ptr.choices, text)
	result_ptr = &choices_ptr.choices[len(choices_ptr.choices) - 1]
	return result_ptr, &result_ptr.next }


ink_continue :: proc(block: Ink_Block) -> (next_ptr: ^Ink_Block) {
	switch v in block {
	case ^Ink_Text:    return &v.next
	case ^Ink_Choices: return &v.next }
	return nil }


ink_init :: proc() {
	ink:         Ink
	next_ptr:    ^Ink_Block
	choices_ptr: ^Ink_Choices

	ink, next_ptr = new_ink()
	_, next_ptr = ink_text(next_ptr, content = "Beginning of story.")
	choices_ptr, _ = ink_choices(next_ptr)
	_, next_ptr = ink_choice(choices_ptr, content = "Choice A.")
	_, next_ptr = ink_choice(choices_ptr, content = "Choice B.")
	_, next_ptr = ink_text(ink_continue(choices_ptr), content = "Continuation of story.") }

