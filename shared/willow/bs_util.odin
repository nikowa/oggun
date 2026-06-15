#+feature using-stmt
package willow
import "base:runtime"
import "core:time"
import "core:strings"
import "core:mem"
import "core:container/intrusive/list"
import "core:slice"
import "core:log"
import "vendor:compress/lz4"
import "core:fmt"
import "core:math/linalg"
import "core:math"

ID :: uintptr

time_max :: proc(a, b: time.Time) -> (time.Time) {
	return time.diff(b, a) >= 0 ? a : b }

once :: proc(done_onces: ^map[runtime.Source_Code_Location]bool, this_once := #caller_location) -> bool {
	if this_once not_in done_onces {
		done_onces[this_once] = true
		return true }
	else do return false }

list_len :: proc(l: list.List, $T: typeid, $field_name: string) -> (n: int) {
	iter := list.iterator_head(l, T, field_name)
	for _ in list.iterate_next(&iter) do n += 1
	return n }

compress :: proc(bytes: []u8, allocator: runtime.Allocator) -> (compressed_bytes: []u8) {
	compress_bound: i32 = lz4.compressBound(cast(i32)len(bytes))
	compressed_bytes_buffer: []u8 = make([]u8, cast(int)compress_bound, allocator)
	compressed_size: i32 = lz4.compress_default(&bytes[0], &compressed_bytes_buffer[0], cast(i32)len(bytes), compress_bound)
	assert(compressed_size != 0)
	compressed_bytes = slice.clone(compressed_bytes_buffer[0:compressed_size], allocator)
	delete(compressed_bytes_buffer, allocator)
	return compressed_bytes }

decompress :: proc(compressed_bytes: []u8, allocator: runtime.Allocator) -> (bytes: []u8) {
	estimated_compression_ratio: f32 = 0.35
	for {
		decompress_bound: i32 = cast(i32)(cast(f32)len(compressed_bytes) / estimated_compression_ratio)
		bytes_buffer: []u8 = make([]u8, cast(int)decompress_bound, allocator)
		decompressed_size: i32 = lz4.decompress_safe(&compressed_bytes[0], &bytes_buffer[0], cast(i32)len(compressed_bytes), decompress_bound)
		if decompressed_size < 0 {
			log.warn("Decompress bound", decompress_bound, "not sufficient.")
			estimated_compression_ratio /= 2.0
			delete(bytes_buffer, allocator)
			continue }
		bytes = slice.clone(bytes_buffer[0:decompressed_size], allocator)
		delete(bytes_buffer, allocator)
		return bytes } }

extract_location :: proc(location := #caller_location, dest: ^runtime.Source_Code_Location) -> runtime.Source_Code_Location {
	dest^ = location
	return location }

/*
mix :: proc(x: f32, y: f32, t: f32) -> f32 {
	return x + (y - x) * t }


mag :: proc(vec: [2]f32) -> f32 {
	return math.sqrt(vec.x * vec.x + vec.y * vec.y) }


clamp_ceil :: proc(val: f32, ceil: f32) -> f32 {
	if val > ceil {
		return ceil }
	else {
		return val } }


clamp_floor :: proc(val: f32, floor: f32) -> f32 {
	if val < floor {
		return floor }
	else {
		return val } }


angle_vec :: proc(angle: f32, mag: f32) -> [2]f32 {
	return linalg.normalize([2]f32{ linalg.cos(angle), linalg.sin(angle) }) * mag }


vec_angle :: proc(vec: [2]f32) -> f32 {
	vec := vec
	vec = linalg.normalize(vec)
	angle: f32
	if vec.y > 0 {
		angle = linalg.acos(vec.x) }
	else {
		angle = -linalg.acos(vec.x) }
	return angle }


iconv :: proc(i: []int, dim_a: []int, dim_b: []int) -> []int {
	return dim_b }


/*
make_if_none :: proc (dir: string) -> (was_none : bool) {
	if os.exists(dir) == false {
		handle, errno := os.open(dir, os.O_CREATE, 0o777)
		assert(errno==os.ERROR_NONE)
		os.close(handle)
		return true
	} else {
		return false
	}
}
*/


/*
make_dir::proc(dir:string) {
	print_log("making dir [", dir, "]")
	handle,errno:=os.open(dir,os.O_CREATE,0o777)
	assert(errno==os.ERROR_NONE)
	os.close(handle) }
*/


open_or_make :: proc(dir: string) -> (os.Handle, os.Errno) {
	if os.exists(dir) == false {
		handle, errno := os.open(dir, os.O_CREATE, 0o777)
		if errno != os.ERROR_NONE { return 0, 0 }
		os.close(handle) }
	return os.open(dir, os.O_RDWR) }


unordered_remove_soa :: proc(array: ^#soa[dynamic]$T, index: int, loc := #caller_location) {
	runtime.bounds_check_error_loc(loc, index, len(array))
	n := len(array)-1
	if index != n {
		array[index] = array[n]
	}
	resize_soa(array, n)
}


read_file::proc(filename:string)->(res:string,ok:bool) #optional_ok {
	bytes,success:=os.read_entire_file_from_filename(filename) // NOTE This is not freed. //
	return string(bytes),success }

*/

nth_line::proc(text:string,target_line:int)->(res:string) {
	curr_line:=0
	for r,i in text {
		if r=='\n' { curr_line+=1 }
		if curr_line==target_line {
			cap:=strings.index_rune(text[i+1:],'\n')
			return text[i:i+cap+1] } }
	return "" }

/*
write_slice::proc(handle:os.Handle,ptr:^[]$T)->(n:int,error:os.Error) {
	size:i32=i32(len(ptr))
	n,error=os.write_ptr(handle,rawptr(&size),4)
	n,error=os.write_ptr(handle,rawptr(&ptr[0]),int(size))
	return n,error }


read_slice::proc(handle:os.Handle,ptr:^[]$T,allocator:=context.allocator)->(n:int,error:os.Error) {
	size:i32=i32(len(ptr))
	n,error=os.read_ptr(handle,rawptr(&size),4)
	ptr^=make([]T,size)
	n,error=os.read_ptr(handle,rawptr(&ptr[0]),int(size))
	return n,error }
*/

starts_with_any::proc(s:string,prefixes:[]string)->(result:bool) {
	for prefix in prefixes {
		if strings.starts_with(s,prefix) {
			return true } }
	return false }

/*
name_from_path::proc(path:string)->string {
	return filepath.stem(filepath.base(path)) }


in_range::proc(x:f32,lo:f32,hi:f32)->bool {
	return (x>=lo)&&(x<=hi) }


coloumb::proc(r1:[2]f32,r2:[2]f32,q:f32)->[2]f32 {
	r:[2]f32=r2-r1
	r_len:f32=linalg.length(r)
	return  r_len!=0.0?((q*r/r_len)/(r_len*r_len)):{0.0,0.0} }


resize_arena_to_content::proc(arena:^mem.Arena,old_size:int) {
	bytes:=cast(rawptr)&arena.data[0]
	new_size:=arena.offset
	new_bytes,allocator_error:=mem.resize(ptr=bytes,old_size=old_size,new_size=new_size)
	assert(allocator_error==nil)
	arena.data=slice.bytes_from_ptr(bytes,new_size) }


apply_transform :: proc(point: [3]f32, transform: matrix[4, 4]f32) -> [3]f32 {
	point4 := transform * [4]f32{ point.x, point.y, point.z, 1 }
	return point4.xyz / point4.w }


u8_normalize :: proc(value: u8) -> (normal: f32) {
	return (cast(f32)value) / 255 }


rgb_normalize :: proc(color: [3]u8) -> [3]f32 {
	return { u8_normalize(color.r), u8_normalize(color.g), u8_normalize(color.b) } }


rgba_normalize :: proc(color: [4]u8) -> [4]f32 {
	return { u8_normalize(color.r), u8_normalize(color.g), u8_normalize(color.b), u8_normalize(color.a) } }


u8_denormalize :: proc(normal: f32) -> (value: u8) {
	return cast(u8)(clamp(normal, 0, 1) * 255) }


rgba_denormalize :: proc(color: [4]f32) -> [4]u8 {
	return { u8_denormalize(color.r), u8_denormalize(color.g), u8_denormalize(color.b), u8_denormalize(color.a) } }


rgb_denormalize :: proc(color: [3]f32) -> [3]u8 {
	return { u8_denormalize(color.r), u8_denormalize(color.g), u8_denormalize(color.b) } }

*/

string_to_cstring16 :: proc(s: string, allocator := context.allocator) -> (res: cstring16) {
	chars := make([]u16, len(s) + 1, allocator)
	for i in 0 ..< len(s) do chars[i] = cast(u16)s[i]
	return cstring16(&chars[0]) }

cstring16_to_string :: proc(s: cstring16, allocator := context.allocator) -> (res: string) {
	chars16: [^]u16 = cast([^]u16)s
	chars := make([]u8, len(s), allocator)
	for i in 0 ..< len(s) do chars[i] = cast(u8)chars16[i]
	return string(chars) }

clone_dynamic_array :: proc(array: $A/[dynamic]$T, allocator := context.allocator, loc := #caller_location) -> A {
	if len(array) == 0 do return nil
	res := make(A, len(array), allocator, loc)
	for elem, i in array do res[i] = elem
	return res }

aprint_size_symbolic :: proc(#any_int size: uint, allocator := context.allocator) -> string {
	if size > mem.Gigabyte do return fmt.aprintf("%f GB", cast(f32)size / cast(f32)mem.Gigabyte, allocator=allocator)
	if size > mem.Megabyte do return fmt.aprintf("%f MB", cast(f32)size / cast(f32)mem.Megabyte, allocator=allocator)
	if size > mem.Kilobyte do return fmt.aprintf("%f KB", cast(f32)size / cast(f32)mem.Kilobyte, allocator=allocator)
	return fmt.aprintf("%d B", size) }

// (TODO): Use these to generate "_get_ith" stack procedures. //
dynamic_array_get_top :: proc(dynamic_array: ^[dynamic]$T, default: T) -> T {
	if len(dynamic_array) == 0 do return default
	return dynamic_array[len(dynamic_array) - 1] }

dynamic_array_get_from_top :: proc(dynamic_array: ^[dynamic]$T, i: int, default: T) -> T {
	if len(dynamic_array) <= i do return default
	return dynamic_array[len(dynamic_array) - 1 - i] }

// (TODO): Test this
@require_results matrix3_translate_f32 :: proc "contextless" (v: [2]f32) -> matrix[3, 3]f32 #no_bounds_check {
	m := linalg.MATRIX3F32_IDENTITY
	m[2][0] = v[0]
	m[2][1] = v[1]
	return m }

// (TODO): Test this
@require_results matrix3_scale_f32 :: proc "contextless" (v: [2]f32) -> (m: matrix[3, 3]f32) #no_bounds_check {
	m[0][0] = v[0]
	m[1][1] = v[1]
	m[2][2] = 1
	return m }

// (TODO): Test this
@require_results matrix3_rotate_f32 :: proc "contextless" (angle_radians: f32) -> matrix[3, 3]f32 {
	c := math.cos(angle_radians)
	s := math.sin(angle_radians)
	return {
		c, -s, 0,
		s,  c, 0,
		0,  0, 1 } }

@require_results matrix3_apply :: proc "contextless" (m: matrix[3, 3]f32, v: [2]f32) -> [2]f32 {
	return (m * [3]f32{ v.x, v.y, 1 }).xy }

loc_id :: proc(location := #caller_location) -> ID {
	location := location
	return runtime.default_hasher(&location, 1, size_of(location)) }

// (TODO): Apply this wherever possible. //
tick_safe :: proc(x: ^$T) -> bool {
	if x.last_tick == engine.tick_count do return false
	x.last_tick = engine.tick_count
	return true }

skip_space :: proc(str: string, idx: ^int) {
	for str[idx^] == ' ' do idx^ += 1 }

points_are_rectilinear :: proc(points: [2][2]f32) -> bool {
	return (points[0].x == points[1].x) || (points[0].y == points[1].y) }

compass_normal :: proc(side: Compass) -> [2]f32 {
	switch side {
	case .East:  return { +1, 0 }
	case .West:  return { -1, 0 }
	case .North: return { 0, +1 }
	case .South: return { 0, -1 } }
	return { 0, 0 } }
