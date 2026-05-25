package willow
import "core:mem"
import "core:slice"

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

// Phases of command processing:
// (1) all commands are stored in a dynamic array
// (2) pointers to the commands are stored in nodes
// (3) nodes are grouped

Command_Node :: struct {
	command: ^Command,
	tree_parent: [dynamic]^Command_Node,
	tree_child: ^Command_Node }

Command_Tree :: struct {
	sub_trees: ^Command_Node }

// (NOTE): Initially all commands are appended to "commands", then when it's time to submit, they are grouped. //
Command_Buffer :: struct {
	commands: [dynamic]Command,
	command_groups: [dynamic]Command_Group,
	_command_cache: ^Command,
	_command_group_cache: ^Command_Group }

Command_Group :: [dynamic]^Command

// (TODO): params_union is defined in a tarnsparent way, so that it can be easily compared byte-by-byte, without checking for the underlying type.
Command_Config :: struct {
	base: union {
		Generic_Command,
		Render_Image_Command,
		Render_Text_Command,
		Render_Rect_Command,
		Render_Line_Command } }

Generic_Command :: struct {
	group_params_size: u16 }

Command :: struct {
	using config: Command_Config,
	submitted: bool }

command_buffer_search_group :: proc(command_buffer: ^Command_Buffer, search_command: ^Command) -> (group: ^Command_Group) {
	for &command_group in command_buffer.command_groups {
		if len(command_group) == 0 do continue
		if commands_belong_to_same_group({ command_group[0], search_command }) do return &command_group }
	return nil }

generic_command_params :: proc(generic_command: ^Generic_Command) -> (params: []u8) {
	ptr: [^]u8 = auto_cast (cast(uintptr)generic_command + size_of(Generic_Command))
	return slice.from_ptr(ptr, cast(int)generic_command.group_params_size) }

@(deprecated="Unimplemented.") command_variant_verify :: proc(Command_Variant: $T) -> bool {
	// (1) The first field must be "using base: Generic_Command"
	// (2) The second field must be named "using *_params: *"
	return true }

command_buffer_init :: proc(command_buffer: ^Command_Buffer) {
	command_buffer.command_groups = make([dynamic]Command_Group, context.allocator) }

// last_command
command_buffer_record :: proc(command_buffer: ^Command_Buffer, config: Command_Config) {
	append(&command_buffer.commands, Command{ config = config, submitted = false })
	command := &command_buffer.commands[len(command_buffer.commands) - 1]
}

command_submit :: proc(graphics_man: ^Graphics_Manager, command: Command, index: int) {
	if command.submitted do return
	switch variant in command.base {
	case Generic_Command: return
	case Render_Image_Command: submit_render_image(graphics_man, command, index)
	case Render_Text_Command:  submit_render_text(graphics_man, command, index)
	case Render_Rect_Command:  submit_render_rect(graphics_man, command, index)
	case Render_Line_Command:  submit_render_line(graphics_man, command, index) }
	graphics_man.command_buffer.commands[index].submitted = true }

command_buffer_submit :: proc(graphics_man: ^Graphics_Manager, command_buffer: ^Command_Buffer) {
	// log.infof("Submitting %v commands.", len(command_buffer.commands))
	for command, index in command_buffer.commands do command_submit(graphics_man, command, index)
	clear(&command_buffer.commands) }

commands_belong_to_same_group :: proc(commands: [2]^Command) -> bool {
	generic_0, _ := (commands[0].base).(Generic_Command)
	generic_1, _ := (commands[1].base).(Generic_Command)
	return slice.equal(generic_command_params(&generic_0), generic_command_params(&generic_1)) }

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
	command_0 := _command_0.base.(Command_Type)
	command_1 := _command_1.base.(Command_Type) or_return
	return command_0.group_params == command_1.group_params }
