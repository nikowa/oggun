package database
import tm "core:time"
import log "core:log"
import fmt "core:fmt"
import str "core:strings"
import mb "core:math/bits"
import os "core:os"



DEFAULT_AUTOSAVE_INTERVAL :: 30 * tm.Minute
// DEFAULT_AUTOSAVE_INTERVAL :: 3 * tm.Second
DEFAULT_AUTOSAVE_CAP :: 10

@(private="file")
_file_is_autosave :: proc(name: string) -> bool {
	if ! str.contains(name, "Data-") do return false
	if ! (os.ext(name) == ".bin") do return false
	return true }

autosave :: proc(database: ^Database) {
	time_now: tm.Time
	relpath: string
	saved: bool
	file_infos: []os.File_Info
	file_info_oldest: os.File_Info
	n_autosaves: u32
	err: os.Error

	time_now = tm.now()
	if tm.diff(database.last_autosave_time, time_now) > database.autosave_interval {
		relpath = fmt.tprintf("cache/Data-%d.bin", tm.time_to_unix_nano(time_now))
		log.infof("Autosaving %s to %s.", database.relpath, relpath)
		write(database, context.temp_allocator, relpath)
		database.last_autosave_time = time_now
		file_infos, err = os.read_directory_by_path(relpath_to_path("cache", context.temp_allocator), -1, context.temp_allocator)
		file_info_oldest.creation_time = { mb.I64_MAX }
		n_autosaves = 0
		for file_info in file_infos do if _file_is_autosave(file_info.name) do n_autosaves += 1
		if n_autosaves <= database.autosave_cap do return
		for file_info in file_infos {
			if ! _file_is_autosave(file_info.name) do continue
			if tm.diff(file_info_oldest.creation_time, file_info.creation_time) < 0 do file_info_oldest = file_info }
		os.remove(file_info_oldest.fullpath) } }


