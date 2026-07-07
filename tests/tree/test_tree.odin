package tree
import og "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"
import "core:math/rand"
import "core:fmt"
import "core:relative"
import "core:mem"

@(test)
test :: proc(t: ^testing.T) {
	context.allocator = context.temp_allocator

	V :: u8
	B :: i8
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 10 * mem.Megabyte))
	b := og.make_tree_builder(V, B, mem.arena_allocator(&arena))
	log.warn(og.tree_builder_capacity(&b))
	value: V = 1
	{
		root := og.tree_build_root_begin(&b, value); value += 1
		log.info(size_of(root^))
		defer og.tree_build_root_end(&b)
		og.tree_build_child(&b, value); value += 1
		{
			og.tree_build_child_begin(&b, value); value += 1
			defer og.tree_build_child_end(&b)
			og.tree_build_child(&b, value); value += 1
			og.tree_build_child(&b, value); value += 1
		}
		og.tree_build_child(&b, value); value += 1
		og.tree_build_child(&b, value); value += 1
		og.tree_build_child(&b, value); value += 1
		for i in 0 ..< 10 {
			og.tree_build_child(&b, value); value += 1
		}
	}
	log.warnf("\n%s", og.aprint_tree(b.root))

	px := new(relative.Pointer(^uint, u8))
	x: uint = 4
	err := relative.pointer_set_safe(px, &x)
	log.warn(err, relative.pointer_get(px))
	log.warn(uintptr(px) - uintptr(&x))

	free_all(context.temp_allocator) }
