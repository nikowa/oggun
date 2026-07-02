#+feature using-stmt
package example_input
import "shared:oggun"
import "base:runtime"
import "core:fmt"
import "core:log"
import "core:time"
import "core:math"
import "core:math/rand"
import "core:math/linalg"
import "core:slice"
import "core:mem"

stopwatch: time.Stopwatch

main :: proc() {
	context.logger = log.create_console_logger()
	oggun.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^oggun.Thread_Data) {
	using oggun

	log.info(gx_color_lightness(WHITE), gx_color_lightness(BLACK))

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="Graph Example", temp_allocator_cap=1000 * mem.Megabyte),
		graphics_config={ clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT })
	ui_set_theme(ui_theme_ms_dark)
	// set_clear_color(BLACK)

	font_group: Font_Group
	font_group_init(&font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	bg_color := engine.ui_manager.theme[UI_Theme_Key.NEUTRAL_BACKGROUND_3][0]
	fg_color := engine.ui_manager.theme[UI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	stroke_color := engine.ui_manager.theme[UI_Theme_Key.NEUTRAL_STROKE_1][0]
	text_style: Text_Style = default_text_style(font_group = font_group, color = fg_color, font_size = 8)
	ui_text_style_push(text_style)
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	camera: Camera_2D
	sn_init_camera_2d(&camera, DEFAULT_CAMERA_2D_CONFIG)

	plot_graph: Plot_Graph
	pt_graph_init(&plot_graph, default_plot_graph_config(
		light_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_DARK,
		dark_foreground_color=COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
		text_style=ui_text_style_get(), margins=12, padding=4, radius=4, orientation=.Horizontal))

	// (TODO): Does dynamic array ever reallocate? //

	// pt_append_node(&plot_graph, default_plot_node(id=1, label="Node A with very long subtitle", position=[2]f32{ -0.8, 0 }))
	// b := pt_append_node(&plot_graph, default_plot_node(id=2, label="Node B", position=[2]f32{ 0.8, 0 }))
	// pt_append_edge(&plot_graph, default_plot_edge(ids={ 1, 2 }, xlabel="Connector", stroke_color=WHITE))
	for i in 0 ..< 16 {
		pt_append_node(&plot_graph, default_plot_node(id=1, label=fmt.aprintf("Node %d", i), size=[2]f32{ 50, 0 }))
	}

	layout_builder := pt_nudge_layout_builder(&plot_graph, { max_steps=100, radius=0.1 })
	pt_layout_initialize(&layout_builder)
	pt_layout_process(&layout_builder)
	pt_layout_post_process(&layout_builder)

	dest_rect: Rect = { { 400, 140 }, { 600, 400 } }
	scr_rect := ui_rect_screen()
	// dest_rect = scr_rect

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			// dest_rect.size.x = 600// + 100 * math.sin(2 * time)
			// dest_rect.size.y = 400// + 100 * math.cos(3 * time)
			dr_rect_outline(dest_rect, RED)

			// b_pos := b.position.([2]f32)
			// b_pos.x = 700 * math.sin(time)
			// b.position = b_pos

			// dr_line({ { 0, 0 }, engine.input_manager.mouse_position }, WHITE)
			// rect: Rect = { engine.input_manager.mouse_position, { 180, 120 } }
			// rect.size.x += 40 * math.sin(2 * time)
			// rect.size.y += 40 * math.sin(3 * time)
			// radius: f32 = 16
			// a, b, c, d := rect_top_left(rect), rect_top_right(rect), rect_bottom_right(rect), rect_bottom_left(rect)
			// deg0   := math.to_radians_f32(0)
			// deg90  := math.to_radians_f32(90)
			// deg180 := math.to_radians_f32(180)
			// deg270 := math.to_radians_f32(270)
			// deg360 := math.to_radians_f32(360)
			// dr_rect({ a, { 2, 2 } }, RED)
			// dr_rect({ b, { 2, 2 } }, RED)
			// dr_rect({ d, { 2, 2 } }, RED)
			// dr_rect({ c, { 2, 2 } }, RED)
			// dr_path_corner({ a, b, c }, radius, WHITE)
			// dr_path_corner({ b, c, d }, radius, WHITE)
			// dr_path_corner({ c, d, a }, radius, WHITE)
			// dr_path_corner({ d, a, b }, radius, WHITE)
			// dr_line(points={ a + { radius, 0 }, b + { -radius, 0 } }, color=WHITE, integer=false)
			// dr_line(points={ b + { 0, -radius }, c + { 0, radius } }, color=WHITE, integer=false)
			// dr_line(points={ c + { -radius, 0 }, d + { radius, 0 } }, color=WHITE, integer=false)
			// dr_line(points={ d + { 0, radius }, a + { 0, -radius } }, color=WHITE, integer=false)

			p: [2]f32 = { 0, 0 }
			a := p
			p.x += 60
			b := p
			p.y += 120
			c := p
			p.x += 20
			d := p
			p.y -= 160
			e := p
			p.x -= 50
			f := p
			p.y -= 60
			g := p
			// dr_point_labeled(a, "A", { 6, 6 }, GREEN)
			// dr_point_labeled(b, "B", { 6, 6 }, GREEN)
			// dr_point_labeled(c, "C", { 6, 6 }, GREEN)
			// dr_point_labeled(d, "D", { 6, 6 }, GREEN)
			// dr_point_labeled(e, "E", { 6, 6 }, GREEN)
			// dr_point_labeled(f, "F", { 6, 6 }, GREEN)
			// dr_point_labeled(g, "G", { 6, 6 }, GREEN)
			path: [][2]f32 = { a, b, c, d, e, f, g }
			assert(path_is_linear(path))
			// dr_path_rounded(path, 16, WHITE)

			// tail: [2]f32 = { -400, 100 }
			// head: [2]f32 = { 0, 200 }
			// head = engine.input_manager.mouse_position
			// vector := head - tail
			// angle: f32 = linalg.angle_between([2]f32{ 0, -1 }, vector) * (vector.x >= 0 ? 1 : -1)
			// dr_line({ tail, head }, text_style.color, integer = false)
			// arrow := head
			// // char: u8 = cast(u8)UI_Icon.Save
			// char: u8 = cast(u8)time
			// arrow_rect: Rect = { { 0, 200 }, { 24, 24 } }
			// { ui_text_style_scope(engine.ui_manager.icons_text_style); dr_text_symbol_rect(cast(u8)UI_Icon.Chevron, arrow_rect, angle = 1 * time) }
			// dr_icon_basic(.Chevron, { 0, 0 }, time, .M)
			// dr_arrow_rectilinear({ 0, 0 }, .East, .L)
			// dr_arrow_rectilinear({ 0, 50 }, .West, .L)
			// dr_arrow_rectilinear({ 0, 100 }, .North, .L)
			// dr_arrow_rectilinear({ 0, 150 }, .South, .L)

			// sn_camera_2d_tick(&camera)
			// camera.rect_normalized.position = ui_pan_control(loc_id(), dest_rect=dest_rect, src_rect=camera.rect, reset=input_query(.R, .PRESSED))
			// camera.scale = scr_rect.size.y * (1 + 32 * ui_zoom_control(loc_id(), scr_rect, initial_value=0, speed=2, reset=input_query(.R, .PRESSED)))
			ui_camera_2d_control(&camera, dest_rect, scale_range={ 0.1 * scr_rect.size.y, scr_rect.size.y })

			gx_clip_scope({ rect=dest_rect })
			dr_plot_graph(&plot_graph, &camera, dest_rect)

			// rect := make_rect(0, 0, 400 + 300/* * math.sin(0.05 * time)*/, 320)
			// rect.size.y = ui_measure_text_box(text, rect.size.x)


			// dr_rect(ui_rect_margins(rect, Interval(-8)), fill_color = bg_color, radius = 4, stroke_color = stroke_color/*BLACK*/, stroke = 1)
			// dr_text_box(text, rect, h_align = .JUSTIFY, v_align = .CENTER, integer = false)
		}
		free_all(context.temp_allocator) }
	return }
