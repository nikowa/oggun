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

prompt: string :
`Usage:
	willow <command> [arguments]
Commands:
	install   Install the Willow library.`

print_prompt :: proc() {
	fmt.printfln("Willow %d.%d.%d--", WILLOW_VERSION.x, WILLOW_VERSION.y, WILLOW_VERSION.z)
	fmt.println(prompt) }

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.options = { .Level }
	no_command: bool = false
	if len(os.args) > 1 do switch os.args[1] {
	case "install":
		src_dir, _ := os.get_executable_directory(context.allocator)
		src_dir, _ = os.join_path({ src_dir, "shared", "willow" }, context.allocator)
		dst_dir, _ := os.join_path({ ODIN_ROOT, "shared", "willow" }, context.allocator)
		generate(src_dir)
		os.remove_all(dst_dir)
		err := os.copy_directory_all(dst_dir, src_dir)
		if err != nil {
			fmt.println("Error:", err)
			return }
		fmt.printfln("Installed Willow in %s.", dst_dir)
	case: no_command = true }
	else do no_command = true
	if no_command do print_prompt() }
