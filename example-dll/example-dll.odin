package dev_dll
import log "core:log"

@(export)
dev_tick :: proc() {
	log.info("Dev tick.") }
