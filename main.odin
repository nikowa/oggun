package game
import base "engine/base"
import fmt "core:fmt"
import mem "core:mem"
import db "engine/database"


RO_State :: struct {
	_: u8 }


main :: proc() {
	fmt.println("Welcome to Willow!")

	path: string = `C:\Code\willow\assets\grass-tile.jpg`
	relpath: string = `assets\grass-tile.jpg`
	fmt.println(db.relpath_to_path(relpath))
	fmt.println(db.path_to_relpath(path))
	assert(db.relpath_to_path(relpath) == path)
	assert(db.path_to_relpath(path) == relpath)


	// Allocate some array of data for cage 1 then some for cage 2.
	//  * How would threads use these?
	//  * How do I make sure that thread A won't write to some element of cage 1 before acquiring its lock?
	//  * How do I make sure that after thread A acquires the lock of cage 1, it can use all data within it?
	// cage_allocator: ^base.Cage_Allocator = new(base.Cage_Allocator)
	// base.cage_allocator_init(cage_allocator, make([]u8, 512))
	// context.allocator = base.cage_allocator(cage_allocator)
	// base.cage_allocator_new_cage(cage_allocator, 64, true)
	// append(&cage_allocator.cages, base.Cage{ 0, 16 })
	// x0: ^u32 = new(u32)
	// x1: ^u32 = new(u32)
	// y0: ^u32 = new(u32)
	// y1: ^u32 = new(u32)

	base.start(entry_point, n_workers_override = 1)
}


entry_point :: proc(thread_data: ^base.Thread_Data) {
	fmt.println(thread_data.index)
	return }

