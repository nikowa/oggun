package graphics
import "base:runtime"

Command_Buffer :: struct {
	allocator: runtime.Allocator,
	commands: [dynamic]Command,
	batches: [dynamic]Command_Batch }

Command_Batch :: struct {
	using params: Command_Batch_Params,
	commands: []Command }

Command :: struct #raw_union {
	using render_image: Render_Image_Params }

Command_Batch_Params :: struct {
	variant: Command_Variant,
	using _: struct #raw_union {
		using render_image: Render_Image_Batch_Params } }

Command_Variant :: enum {
	RENDER_IMAGE }

// Procedure for recording a command.

command_buffer_record :: proc(buffer: ^Command_Buffer, variant: Command_Variant, batch_params: Command_Batch_Params, params: Command) {
	batch_params := batch_params
	batch_params.variant = variant
	last_batch: ^Command_Batch = len(buffer.batches) > 0 ? &buffer.batches[len(buffer.batches) - 1] : nil
	if (last_batch == nil) || (last_batch.params != batch_params) {
		append(&buffer.batches, Command_Batch{ })
		last_batch = &buffer.batches[len(buffer.batches) - 1] }
	append(&buffer.commands, params)
	n: int = len(buffer.commands)
	if len(last_batch.commands) == 0 {
		last_batch.commands = buffer.commands[n - 1 : n] }
	else {
		i: int = int((uintptr(&last_batch.commands[0]) - uintptr(&buffer.commands[0])) / size_of(Command))
		last_batch.commands = buffer.commands[i : n] } }
