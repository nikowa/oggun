#+feature using-stmt
package oggun
import "core:os"
import "core:fmt"
import "core:log"
import "core:strings"
import "core:time"
import "core:odin/parser"
import "core:odin/tokenizer"
import "core:odin/ast"
import "core:path/filepath"
import "core:path/slashpath"
import "core:slice"
import "core:math"

mt_test_coverage :: proc(directory_path: string) -> (tested, untested: []string) {
	untested_procs := make([dynamic]string)
	tests_directory_path, _ := os.join_path({ os.dir(os.dir(directory_path)), "tests" }, context.allocator)
	Data :: struct {
		procs: [dynamic]string,
		tested_procs: [dynamic]string }
	data: Data = {
		procs = make([dynamic]string),
		tested_procs = make([dynamic]string) }
	file_infos, err := os.read_directory_by_path(directory_path, -1, context.allocator)
	for file_info in file_infos do if os.ext(file_info.name) == ".odin" {
		mt_walk_file(file_info.fullpath, &data, proc(walker: ^Walker, node: ^ast.Node) -> bool {
			data: ^Data = auto_cast walker.user_data
			#partial switch derived in node.derived {
			case ^ast.Value_Decl:
				if len(derived.values) == 0 do return false
				proc_lit, ok := derived.values[0].derived.(^ast.Proc_Lit)
				if ! ok do return false
				append(&data.procs, mt_node_string(walker, derived.names[0])) }
			return true }) }
	test_directories: []os.File_Info
	test_directories, err = os.read_directory_by_path(tests_directory_path, -1, context.allocator)
	for test_directory in test_directories {
		tests: []os.File_Info
		tests, err = os.read_directory_by_path(test_directory.fullpath, -1, context.allocator)
		for file_info in tests {
			if os.ext(file_info.name) == ".odin" {
				mt_walk_file(file_info.fullpath, &data, proc(walker: ^Walker, node: ^ast.Node) -> bool {
					data: ^Data = auto_cast walker.user_data
					#partial switch derived in node.derived {
					case ^ast.Call_Expr:
						proc_name := mt_node_string(walker, derived.expr.expr_base)
						if ! strings.has_prefix(proc_name, "og.") do return true
						proc_name = proc_name[3:]
						if slice.contains(data.procs[:], proc_name) do append_deduplicate(&data.tested_procs, proc_name) }
					return true }) } } }
	shrink(&data.tested_procs)
	for proc_name in data.procs do if ! slice.contains(data.procs[:], proc_name) do append(&untested_procs, proc_name)
	shrink(&untested_procs)
	log.infof("Test coverage: %v%%", math.round(f32(len(data.tested_procs)) / f32(len(data.procs)) * 100))
	return data.tested_procs[:], untested_procs[:] }

mt_list_untested :: proc(project_path: string) {
	tested, untested := mt_test_coverage(project_path)

}
