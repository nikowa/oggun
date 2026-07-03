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

mt_odin_to_glsl :: proc(odin_source_path: string) -> (glsl_source: string) {
	assert(os.ext(odin_source_path) == ".odin")
	source_bytes, _ := os.read_entire_file_from_path(odin_source_path, context.allocator)
	source: string = string(source_bytes)
	file_node := mt_parse_file(odin_source_path, source)
	return "" }
