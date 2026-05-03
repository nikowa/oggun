package willow
import os "core:os"
import fmt "core:fmt"
import bs "base"


prompt: string :
`Usage:
	willow <command> [arguments]
Commands:
	install   Install the Willow library.`


print_prompt :: proc() {
	fmt.printfln("Willow %d.%d.%d--", bs.WILLOW_VERSION.x, bs.WILLOW_VERSION.y, bs.WILLOW_VERSION.z)
	fmt.println(prompt) }


main :: proc() {
	no_command: bool = false
	if len(os.args) > 1 do switch os.args[1] {
	case "install":
		src_dir, _ := os.get_executable_directory(context.allocator)
		src_dir, _ = os.join_path({ src_dir, "shared", "willow" }, context.allocator)
		dst_dir, _ := os.join_path({ ODIN_ROOT, "shared", "willow" }, context.allocator)
		fmt.println(src_dir, dst_dir)
		err := os.copy_directory_all(dst_dir, src_dir)
		if err != nil do fmt.println("Error:", err)
	case: no_command = true }
	else do no_command = true
	if no_command do print_prompt() }

