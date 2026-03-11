#+feature using-stmt
package base
import "base:runtime"
import "core:reflect"
import "core:fmt"
import "core:time"
import "core:math"
import "core:mem"
import "core:os"
import "core:math/linalg"
import "core:path/filepath"
import "core:slice"
import "core:strings"
import "core:sys/windows"

DATE: string : "\e[0;34m date | \e[0m"
LOG: string : "\e[0;36m log  | \e[0m"
BAD: string : "\e[0;31m bad  | \e[0m"
WARN: string : "\e[0;33m warn | \e[0m"

/*
print_log :: proc(args: ..any, sep := " ", flush := true) -> int{
	when PRINT_LOGS { fmt.print(LOG); return fmt.println(..args, sep = sep, flush = flush) } else { return 0 } }


print_bad :: proc(args: ..any, sep := " ", flush := true) -> int{
	when PRINT_BADS { fmt.print(BAD); return fmt.println(..args, sep = sep, flush = flush) } else { return 0 } }


print_warn :: proc(args: ..any, sep := " ", flush := true) -> int{
	when PRINT_WARNS { fmt.print(WARN); return fmt.println(..args, sep = sep, flush = flush) } else { return 0 } }


print_date :: proc(args: ..any, sep := " ", flush := true) -> int{
	when PRINT_DATES { fmt.print(DATE); return fmt.println(..args, sep = sep, flush = flush) } else { return 0 } }


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


get_executable_path :: proc() -> string {
	length: u32 = 256
	buffer: [^]u16 = make([^]u16, length)
	res_length: u32 = windows.GetModuleFileNameW(nil, buffer, 256)
	assert(res_length > 0)
	path, _ := windows.wstring_to_utf8_alloc(cast(cstring16)buffer, int(res_length), context.allocator)
	return path }
// TODO There is an odin macro for this. Employ that instead. And make sure it works. //
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