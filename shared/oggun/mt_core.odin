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
import "core:slice"

Walker :: struct {
	source: string,
	walk_proc: proc(walker: ^Walker, node: ^ast.Node) -> bool,
	user_data: rawptr }

mt_parse_file :: proc(source_path: string) -> (node: ast.Node, source: string) {
	assert(os.ext(source_path) == ".odin")
	bytes, err := os.read_entire_file_from_path(source_path, context.allocator)
	source = string(bytes)
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
	return file.node, source }

mt_node_string :: proc(walker: ^Walker, node: ast.Node) -> string {
	return walker.source[node.pos.offset : max(node.end.offset, node.pos.offset)] }

mt_walk_file :: proc(source_path: string, user_data: rawptr, walk_proc: proc(walker: ^Walker, node: ^ast.Node) -> bool) {
	node, source := mt_parse_file(source_path)
	mt_walk_node(&node, source, user_data, walk_proc) }

mt_walk_node :: proc(node: ^ast.Node, source: string, user_data: rawptr, walk_proc: proc(walker: ^Walker, node: ^ast.Node) -> bool) {
	visit_proc :: proc(visitor: ^ast.Visitor, node: ^ast.Node) -> ^ast.Visitor {
		if visitor == nil || node == nil do return nil
		walker: ^Walker = auto_cast visitor.data
		if walker.walk_proc(walker, node) do return visitor
		else do return nil }
	walker: Walker = {
		source = source,
		walk_proc = walk_proc,
		user_data = user_data }
	visitor := &ast.Visitor {
		visit = visit_proc,
		data = &walker }
	ast.walk(visitor, node) }
