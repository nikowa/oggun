#+feature using-stmt
package example_input
import "shared:oggun"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"
import "core:mem"

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

}