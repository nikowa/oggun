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

prompt: string :
`Usage:
	oggun <command> [arguments]
Commands:
	install   Install the Oggun library.`

print_prompt :: proc() {
	fmt.printfln("Oggun %d.%d.%d--", OGGUN_VERSION.x, OGGUN_VERSION.y, OGGUN_VERSION.z)
	fmt.println(prompt) }

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.options = { .Level }
	no_command: bool = false
	if len(os.args) > 1 do switch os.args[1] {
	case "install":
		src_dir, _ := os.get_executable_directory(context.allocator)
		src_dir, _ = os.join_path({ src_dir, "shared", "oggun" }, context.allocator)
		dst_dir, _ := os.join_path({ ODIN_ROOT, "shared", "oggun" }, context.allocator)
		gn_generate(src_dir)
		os.remove_all(dst_dir)
		err := os.copy_directory_all(dst_dir, src_dir)
		if err != nil {
			fmt.println("Error:", err)
			return }
		fmt.printfln("Installed Oggun in %s.", dst_dir)
	case: no_command = true }
	else do no_command = true
	if no_command do print_prompt() }
