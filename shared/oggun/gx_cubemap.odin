#+feature using-stmt
package oggun


// Cubemap :: [Cubemap_Direction]Render_Buffer


// Cubemap_Direction :: enum u8 { UP, DOWN, LEFT, RIGHT, BACK, FRONT }


// // (TODO): Make a shader that is like model shader, except it rasterizes a sphere and uses it to render a light, for the light baker. The sun will have full brightness, while point lights will be attenuated by distance.


// init_cubemap :: proc(cubemap: ^Cubemap, resolution: [2]int) {
// 	ok: bool
// 	for dir in Cubemap_Direction do cubemap[dir], ok = make_render_buffer_static(resolution, 1, {gl.RGBA8}, {gl.RGBA}, depth_component = true) }


// render_cubemap :: proc(draw: ^Draw, cubemap: ^Cubemap, position: [3]f32) {
// 	iterator := make_cubemap_camera_iterator(position)
// 	for camera, direction in cubemap_camera_iterate_next(&iterator) {
// 		camera := camera
// 		render_buffer := &cubemap[direction]
// 		clear_render_buffer(render_buffer)
// 		select_render_buffer(draw, render_buffer)
// 		set_depth_test(true)
// 		render_all_model_instances(draw, &camera) } }


// render_cubemap_preview :: proc(draw: ^Draw, cubemap: ^Cubemap, position: [2]f32, size: [2]f32) {
// 	cell_size: [2]f32
// 	cell_position:  [2]f32

// 	cell_size = size / [2]f32{ 4, 3 }
// 	cell_position = position - { 1.5 * cell_size.x, 0 }
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.LEFT].texture_handles[0], cell_position, cell_size)
// 	cell_position.x += cell_size.x
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.FRONT].texture_handles[0], cell_position, cell_size)
// 	cell_position.y += cell_size.y
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.UP].texture_handles[0], cell_position, cell_size)
// 	cell_position.y -= 2 * cell_size.y
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.DOWN].texture_handles[0], cell_position, cell_size)
// 	cell_position.y += cell_size.y
// 	cell_position.x += cell_size.x
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.RIGHT].texture_handles[0], cell_position, cell_size)
// 	cell_position.x += cell_size.x
// 	dr_texture_by_handle(draw, cubemap[Cubemap_Direction.BACK].texture_handles[0], cell_position, cell_size) }

