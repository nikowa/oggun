#+feature using-stmt
package willow
import "core:os"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:time"
import "core:odin/parser"
import "core:odin/tokenizer"
import "core:odin/ast"
import "core:path/filepath"
import "core:slice"

stub_error_handler :: proc(_: tokenizer.Pos, _: string, _: ..any) { }

Generator :: struct {
	prefix: string,
	builder: strings.Builder }

generators: map[string]Generator

gn_get_generator :: proc(member_path: string) -> ^Generator {
	prefix := strings.split(member_path, "_")[0]
	if prefix not_in generators {
		generator: Generator = gx_make_generator(prefix, 10_000)
		fmt.sbprintfln(&generator.builder, `package willow`)
		generators[prefix] = generator }
	return &generators[prefix] }

gn_generate :: proc(willow_path: string) {
	gn_generate_defaults(willow_path)
	gn_generate_stacks(willow_path) }

gn_generate_defaults :: proc(willow_path: string) {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, 10_000, context.allocator)
	fmt.sbprintln(&builder, "package willow")
	fmt.sbprintln(&builder, `import "core:time"`)
	timestamp_buf: [time.MIN_HMS_LEN]u8
	fmt.sbprintfln(&builder, "// Generated at %s //\n", time.time_to_string_hms(time.now(), timestamp_buf[:]))

	parse_file :: proc(source_path: string, source: string) -> (node: ast.Node) {
		NO_POS :: tokenizer.Pos{}
		pkg := ast.new_from_positions(ast.Package, NO_POS, NO_POS)
		pkg.fullpath = source_path
		file := ast.new(ast.File, NO_POS, NO_POS)
		file.pkg = pkg
		file.src = source
		file.fullpath = source_path
		pkg.files[file.fullpath] = file
		par := parser.default_parser()
		par.err, par.warn = stub_error_handler, stub_error_handler
		ok := parser.parse_file(&par, file)
		return file.node }

	node_to_string :: proc(source: string, node: ast.Node) -> string {
		return source[node.pos.offset : max(node.end.offset, node.pos.offset)] }

	// Collect Config types //
	Config_Type_Info :: struct {
		selected:     bool,
		name:         string,
		default_name: string,
		field_names:  []string,
		field_types:  []string }
	Config_Types_Data :: struct {
		source:            string,
		config_type_infos: ^[dynamic]Config_Type_Info }

	config_types_visitor :: proc(v: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
		if node == nil do return nil
		config_types_data: ^Config_Types_Data = cast(^Config_Types_Data)v.data
		using config_types_data
		#partial switch stmt in node.derived {
			case ^ast.Value_Decl:
				value_decl := node.derived.(^ast.Value_Decl)
				if len(value_decl.values) != 1 do return v
				if len(value_decl.names) != 1 do return v
				ident := value_decl.names[0].derived.(^ast.Ident)
				struct_type, ok := value_decl.values[0].derived.(^ast.Struct_Type)
				if ! ok do return v
				config_type_info: Config_Type_Info
				config_type_info.name = ident.name
				config_type_info.default_name = fmt.aprintf("DEFAULT_%s", strings.to_upper(ident.name, context.allocator))
				field_names := make([dynamic]string, context.allocator)
				field_types := make([dynamic]string, context.allocator)
				for field in struct_type.fields.list do for name in field.names {
					append(&field_names, node_to_string(source, name.expr_base))
					append(&field_types, node_to_string(source, field.type.expr_base)) }
				shrink(&field_names)
				shrink(&field_types)
				config_type_info.field_names = field_names[:]
				config_type_info.field_types = field_types[:]
				append(config_type_infos, config_type_info) }
		return v }

	config_type_infos := make([dynamic]Config_Type_Info, context.allocator)
	file_infos, _ := os.read_directory_by_path(willow_path, -1, context.allocator)
	for file_info in file_infos {
		source_path: string = file_info.fullpath
		if os.ext(source_path) != ".odin" do continue
		source_bytes, _ := os.read_entire_file_from_path(source_path, context.allocator)
		source: string = string(source_bytes)
		file_node := parse_file(source_path, source)
		config_types_data: Config_Types_Data = {
			source = source,
			config_type_infos = &config_type_infos }
		visitor := &ast.Visitor {
			visit = config_types_visitor,
			data = &config_types_data }
		ast.walk(visitor, &file_node) }

	// Collect Config instances //
	Config_Instances_Data :: struct {
		source:            string,
		config_type_infos: ^[dynamic]Config_Type_Info }

	config_instances_visitor :: proc(v: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
		if node == nil do return nil
		config_instances_data: ^Config_Instances_Data = cast(^Config_Instances_Data)v.data
		using config_instances_data
		value_decl, ok := node.derived.(^ast.Value_Decl)
		if ! ok do return v
		if len(value_decl.values) != 1 do return v
		if len(value_decl.names) != 1 do return v
		name_ident := value_decl.names[0].derived.(^ast.Ident)
		if value_decl.type != nil {
			type_ident, ok := value_decl.type.derived.(^ast.Ident)
			if ! ok do return v
			selected: bool = false
			for _, i in config_type_infos[:] {
				type_info := &config_type_infos[i]
				if name_ident.name == type_info.default_name {
					selected = true
					type_info.selected = true
					break } }
			if ! selected do return v }
		return v }

	for file_info in file_infos {
		source_path: string = file_info.fullpath
		if os.ext(source_path) != ".odin" do continue
		source_bytes, _ := os.read_entire_file_from_path(source_path, context.allocator)
		source: string = string(source_bytes)
		file_node := parse_file(source_path, source)
		config_instances_data: Config_Instances_Data = {
			source = source,
			config_type_infos = &config_type_infos }
		visitor := &ast.Visitor {
			visit = config_instances_visitor,
			data = &config_instances_data }
		ast.walk(visitor, &file_node) }

	// Generate default helpers //
	selected_config_type_infos := make([dynamic]Config_Type_Info, context.allocator)
	for type_info in config_type_infos do if type_info.selected do append(&selected_config_type_infos, type_info)

	for type_info in selected_config_type_infos {
		fmt.sbprintfln(&builder, "%s :: proc(", strings.to_lower(type_info.default_name))
		for _, i in type_info.field_names do if type_info.field_types[i] == "typeid" {
			fmt.sbprintf(&builder, "\t\t%s: %s",
				type_info.field_names[i],
				type_info.field_types[i])
			fmt.sbprint(&builder, ",\n") }
		for _, i in type_info.field_names do if type_info.field_types[i] != "typeid" {
			fmt.sbprintf(&builder, "\t\t%s: %s = %s.%s",
				type_info.field_names[i],
				type_info.field_types[i],
				type_info.default_name,
				type_info.field_names[i])
			fmt.sbprint(&builder, ",\n")
		}
		fmt.sbprintfln(&builder, ") -> %s {{\n\treturn {{", type_info.name)
		for _, i in type_info.field_names {
			fmt.sbprintf(&builder, "\t\t%s = %s",
				type_info.field_names[i],
				type_info.field_names[i])
			if i < len(type_info.field_names) - 1 do fmt.sbprintln(&builder, ",") }
		fmt.sbprintln(&builder, " } }\n")
	}

	path, _ := os.join_path({ willow_path, "generated.odin" }, context.allocator)
	_ = os.write_entire_file(path, strings.to_string(builder)) }

// gi_get_appearance :: proc() -> GI_Appearance {
// 	if len(engine.gi_manager.appearance_stack) == 0 do return .DEFAULT
// 	return engine.gi_manager.appearance_stack[len(engine.gi_manager.appearance_stack) - 1] }

// @(deferred_none=gi_appearance_pop)
// gi_appearance_scope :: proc(appearance: GI_Appearance) {
// 	gi_appearance_push(appearance) }

// gi_appearance_push :: proc(appearance: GI_Appearance) {
// 	append(&engine.gi_manager.appearance_stack, appearance) }

// gi_appearance_pop :: proc() {
// 	pop(&engine.gi_manager.appearance_stack) }

gn_generate_stack :: proc(generator: ^Generator, name: string, type: string, default: string, field: string) {
	fmt.sbprintfln(&generator.builder, `
gi_get_%s :: proc() -> %s {{
	if len(engine.%s.%s_stack) == 0 do return %s
	return engine.%s.%s_stack[len(engine.%s.%s_stack) - 1] }}`,
		name, type, field, name, default, field, name, field, name)

	fmt.sbprintfln(&generator.builder, `
@(deferred_none=gi_%s_pop)
gi_%s_scope :: proc(%s: %s) {{
	gi_%s_push(%s) }}`,
		name, name, name, type, name, name)

	fmt.sbprintfln(&generator.builder, `
gi_%s_push :: proc(%s: %s) {{
	append(&engine.%s.%s_stack, %s) }}`,
		name, name, type, field, name, name)

	fmt.sbprintfln(&generator.builder, `
gi_%s_pop :: proc() {{
	pop(&engine.%s.%s_stack) }}`,
		name, field, name) }

gx_make_generator :: proc(prefix: string, cap: int) -> Generator {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, cap, context.allocator)
	return {
		prefix=prefix,
		builder=builder } }

gn_generator_commit :: proc(generator: ^Generator, willow_path: string) {
	path, _ := os.join_path({ willow_path, fmt.aprintf("%s_generated.odin", generator.prefix) }, context.allocator)
	_ = os.write_entire_file(path, strings.to_string(generator.builder)) }

gn_generate_stacks :: proc(willow_path: string) {
	generator := gn_get_generator("gi")
	// generator := gx_make_generator("gi", 10_000)
	gn_generate_stack(generator, "disabled", "bool", "false", "gi_manager")
	gn_generate_stack(generator, "button_shape", "GI_Button_Shape", ".ROUNDED", "gi_manager")
	gn_generate_stack(generator, "appearance", "GI_Appearance", ".DEFAULT", "gi_manager")
	gn_generator_commit(generator, willow_path)
}
