package runner
import db "core:dynlib"



main :: proc() {
	context.logger = log.create_console_logger()
	base.start(entry_point, n_workers_override = 1) }
