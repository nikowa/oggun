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

mt_parse_file :: proc(source_path: string, source: string) -> (node: ast.Node) {
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
