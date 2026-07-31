#+feature using-stmt
#+feature dynamic-literals
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
	install   Install the oggun library in your Odin directory.
	build     Build a package using oggun.
	check     Run the oggun checker on a project directory.
	audit     Analyze the oggun source and documentation.
	version   Print the version of oggun.
	help      Detailed description of command.`

check_prompt: string :
`Usage:
	oggun check <project-dir>`

audit_prompt: string :
`Usage:
	oggun audit [files]`

help_prompt: string :
`Usage:
	oggun check <project-dir>`

build_prompt: string :
`Usage:
	oggun build <package-dir> [build-args]`

help_prompts: map[string]string = {
	"check" = check_prompt,
	"audit" = audit_prompt,
	"help" = help_prompt,
	"build" = build_prompt }

main :: proc() {
	context.logger = log.create_console_logger()
	context.logger.options = { .Level }
	executable_directory, _ := os.get_executable_directory(context.allocator)
	oggun_source_dir, _ := os.join_path({ executable_directory, "shared", "oggun" }, context.allocator)
	oggun_install_dir, _ := os.join_path({ ODIN_ROOT, "shared", "oggun" }, context.allocator)
	if len(os.args) < 2 do fmt.println(prompt)
	else do switch os.args[1] {
	case "install":
		log.info("Installing OGGUN...")
		mt_generate_on_install(oggun_source_dir)
		tested, untested := mt_test_coverage(oggun_source_dir)
		os.remove_all(oggun_install_dir)
		err := os.copy_directory_all(oggun_install_dir, oggun_source_dir)
		if err != nil {
			fmt.println("Error:", err)
			return }
		fmt.printfln("Installed Oggun in %s.", oggun_install_dir)
	case "build":
		if len(os.args) < 3 {
			fmt.println(build_prompt)
			return }
		package_path, _ := os.get_absolute_path(os.args[2], context.allocator)
		if ! os.exists(package_path) {
			fmt.printfln("Error: Package path does not exist: %s.", package_path)
			fmt.println(build_prompt)
			return }
		log.infof("Building %s", package_path)
		mt_generate_on_compile(oggun_install_dir, package_path)
	case "version":
		fmt.printfln("oggun-%d.%d.%d", OGGUN_VERSION.x, OGGUN_VERSION.y, OGGUN_VERSION.z)
	case "check":
		if len(os.args) < 3 {
			fmt.println(check_prompt)
			return }
		project_path, _ := os.get_absolute_path(os.args[2], context.allocator)
		if ! os.exists(project_path) do fmt.eprintfln("Error: %s is not a valid path.", project_path)
		mt_list_untested(oggun_source_dir, project_path)
	case "audit":
		mt_list_untested(oggun_source_dir, oggun_source_dir, prefix="", files=os.args[2:])
	case "help":
		if len(os.args) < 3 {
			fmt.println("Error: No command to provide help for.")
			fmt.println(help_prompt)
			return }
		command := os.args[2]
		if command not_in help_prompts {
			fmt.println("Error: Unrecognized command.")
			fmt.println(help_prompt)
			return }
		fmt.println(help_prompts[command])
	case:
		fmt.println("Error: Unrecognized command.")
		fmt.println(prompt) } }
