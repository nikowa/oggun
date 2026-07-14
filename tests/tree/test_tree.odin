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
	B :: i16
	arena: mem.Arena
	mem.arena_init(&arena, make([]u8, 10 * mem.Megabyte))
	b := og.make_tree_builder(V, B, mem.arena_allocator(&arena))
	// log.warn(og.tree_builder_capacity(&b))
	value: V = 1
	{
		root := og.tree_build_root_begin(&b, value); value += 1
		// log.info(size_of(root^))
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
	// log.infof("\n%s", og.aprint_tree(b.root))

	px := new(relative.Pointer(^uint, u8))
	x: uint = 4
	err := relative.pointer_set_safe(px, &x)
	// log.warn(err, relative.pointer_get(px))
	// log.warn(uintptr(px) - uintptr(&x))

	// ITERATOR TEST //
	mem.arena_free_all(&arena)
	b2 := og.make_tree_builder(rune, B, mem.arena_allocator(&arena))
	{
		root := og.tree_build_root_begin(&b2, 'A')
		defer og.tree_build_root_end(&b2)
		{
			og.tree_build_child_begin(&b2, 'B')
			defer og.tree_build_child_end(&b2)
			{
				og.tree_build_child_begin(&b2, 'D')
				defer og.tree_build_child_end(&b2)
				{
					og.tree_build_child_begin(&b2, 'H')
					defer og.tree_build_child_end(&b2)
					og.tree_build_child(&b2, 'P')
				}
				og.tree_build_child(&b2, 'I')
			}
			{
				og.tree_build_child_begin(&b2, 'E')
				defer og.tree_build_child_end(&b2)
				og.tree_build_child(&b2, 'J')
				{
					og.tree_build_child_begin(&b2, 'K')
					defer og.tree_build_child_end(&b2)
					og.tree_build_child(&b2, 'Q')
					og.tree_build_child(&b2, 'R')
				}
			}
		}
		{
			og.tree_build_child_begin(&b2, 'C')
			defer og.tree_build_child_end(&b2)
			{
				og.tree_build_child_begin(&b2, 'F')
				defer og.tree_build_child_end(&b2)
				og.tree_build_child(&b2, 'L')
				og.tree_build_child(&b2, 'M')
				{
					og.tree_build_child_begin(&b2, 'N')
					defer og.tree_build_child_end(&b2)
					og.tree_build_child(&b2, 'S')
					og.tree_build_child(&b2, 'T')
					og.tree_build_child(&b2, 'U')
				}
				og.tree_build_child(&b2, 'O')
			}
			og.tree_build_child(&b2, 'G')
		}
	}
	// log.infof("\n%s", og.aprint_tree(b2.root))
	it2 := og.make_tree_preorder_iterator(b2.root)
	// log.info("Pre-order:")
	pre_order: string = "ABDHPIEJKQRCFLMNSTUOG"
	i := 0
	for node in it2.next(&it2) {
		testing.expect(t, cast(rune)pre_order[i] == node.value)
		i += 1 }
		// log.info(node.value) }
	it2 = og.make_tree_postorder_iterator(b2.root)
	// log.info("Post-order:")
	post_order: string = "PHIDJQRKEBLMSTUNOFGCA"
	i = 0
	for node in it2.next(&it2) {
		testing.expect(t, cast(rune)post_order[i] == node.value)
		// log.info(node.value)
		i += 1 }

	free_all(context.temp_allocator) }
