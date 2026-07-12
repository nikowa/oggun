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
	file_node, source := mt_parse_file(odin_source_path)
	return "" }
