package willow
import "core:time"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:math/bits"
import "core:os"

// DEFAULT_AUTOSAVE_INTERVAL :: 3 * time.Second
DEFAULT_AUTOSAVE_INTERVAL :: 30 * time.Minute
DEFAULT_AUTOSAVE_CAP :: 10

@(private="file")
_file_is_autosave :: proc(name: string) -> bool {
	if ! strings.contains(name, "Data-") do return false
	if ! (os.ext(name) == ".bin") do return false
	return true }

autosave :: proc(database: ^Asset_Manager) {
	time_now: time.Time
	relpath: string
	saved: bool
	file_infos: []os.File_Info
	file_info_oldest: os.File_Info
	n_autosaves: u32
	err: os.Error

	time_now = time.now()
	if time.diff(database.last_autosave_time, time_now) > database.autosave_interval {
		relpath = fmt.tprintf("cache/Data-%d.bin", time.time_to_unix_nano(time_now))
		log.infof("Autosaving %s to %s.", database.relpath, relpath)
		database_write(database, context.temp_allocator, relpath)
		database.last_autosave_time = time_now
		file_infos, err = os.read_directory_by_path(relpath_to_path("cache", context.temp_allocator), -1, context.temp_allocator)
		file_info_oldest.creation_time = { bits.I64_MAX }
		n_autosaves = 0
		for file_info in file_infos do if _file_is_autosave(file_info.name) do n_autosaves += 1
		if n_autosaves <= database.autosave_cap do return
		for file_info in file_infos {
			if ! _file_is_autosave(file_info.name) do continue
			if time.diff(file_info_oldest.creation_time, file_info.creation_time) < 0 do file_info_oldest = file_info }
		os.remove(file_info_oldest.fullpath) } }


