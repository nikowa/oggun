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

Generator :: struct {
	prefix: string,
	builder: strings.Builder }

gx_make_generator :: proc(prefix: string, cap: int) -> Generator {
	builder: strings.Builder
	strings.builder_init_len_cap(&builder, 0, cap, context.allocator)
	return {
		prefix=prefix,
		builder=builder } }

mt_generator_commit :: proc(generator: ^Generator, oggun_path: string) {
	path, _ := os.join_path({ oggun_path, fmt.aprintf("%s_generated.odin", generator.prefix) }, context.allocator)
	_ = os.write_entire_file(path, strings.to_string(generator.builder)) }
