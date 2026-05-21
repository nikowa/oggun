package willow

// Command_Buffer :: struct {
// 	allocator: runtime.Allocator,
// 	commands: [dynamic]Command,
// 	batches: [dynamic]Command_Batch }

// Command_Batch :: struct {
// 	using params: Command_Batch_Params,
// 	commands: []Command }

// Command :: struct #raw_union {
// 	using render_image: Render_Image_Params }

// Command_Batch_Params :: struct {
// 	variant: Command_Variant,
// 	using _: struct #raw_union {
// 		using render_image: Render_Image_Batch_Params } }

// Command_Variant :: enum {
// 	RENDER_IMAGE }

// // Procedure for recording a command.

// command_buffer_record :: proc(buffer: ^Command_Buffer, variant: Command_Variant, batch_params: Command_Batch_Params, params: Command) {
// 	batch_params := batch_params
// 	batch_params.variant = variant
// 	last_batch: ^Command_Batch = len(buffer.batches) > 0 ? &buffer.batches[len(buffer.batches) - 1] : nil
// 	if (last_batch == nil) || (last_batch.params != batch_params) {
// 		append(&buffer.batches, Command_Batch{ })
// 		last_batch = &buffer.batches[len(buffer.batches) - 1] }
// 	append(&buffer.commands, params)
// 	n: int = len(buffer.commands)
// 	if len(last_batch.commands) == 0 {
// 		last_batch.commands = buffer.commands[n - 1 : n] }
// 	else {
// 		i: int = int((uintptr(&last_batch.commands[0]) - uintptr(&buffer.commands[0])) / size_of(Command))
// 		last_batch.commands = buffer.commands[i : n] } }

Command_Buffer :: struct {
	commands: [dynamic]Command }

Command_Config :: struct {
	variant: union {
		Render_Image_Command,
		Render_Text_Command,
		Render_Rect_Command } }

Command :: struct {
	using config: Command_Config,
	submitted: bool }

Command_Variant :: enum {
	RENDER_IMAGE,
	RENDER_BITMAP_TEXT,
	RENDER_RECT }

command_buffer_record :: proc(buffer: ^Command_Buffer, config: Command_Config) {
	append(&buffer.commands, Command{ config = config, submitted = false }) }

command_submit :: proc(graphics_man: ^Graphics_Manager, command: Command, index: int) {
	if command.submitted do return
	switch variant in command.variant {
	case Render_Image_Command:       submit_render_image(graphics_man, command, index)
	case Render_Text_Command: submit_render_text(graphics_man, command, index)
	case Render_Rect_Command:        submit_render_rect(graphics_man, command, index) }
	graphics_man.command_buffer.commands[index].submitted = true }

command_buffer_submit :: proc(graphics_man: ^Graphics_Manager, command_buffer: ^Command_Buffer) {
	// log.infof("Submitting %v commands.", len(command_buffer.commands))
	for command, index in command_buffer.commands do command_submit(graphics_man, command, index)
	clear(&command_buffer.commands) }

command_buffer_get_group :: proc(command_buffer: ^Command_Buffer, index: int, cond: proc(command_0, command_1: Command) -> bool) -> ([]Command) {
	index_max: int = index + 1
	command := command_buffer.commands[index]
	for ; index_max < len(command_buffer.commands); index_max += 1 {
		command_max := &command_buffer.commands[index_max]
		if ! (cond(command, command_max^)) do break
		command_max.submitted = true }
	return command_buffer.commands[index:index_max] }

commands_compare_params :: proc($Command_Type: typeid, _command_0, _command_1: Command) -> (ok: bool) {
	ok = false
	command_0 := _command_0.variant.(Command_Type)
	command_1 := _command_1.variant.(Command_Type) or_return
	return command_0.group_params == command_1.group_params }
