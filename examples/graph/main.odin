#+feature using-stmt
package example_input
import "shared:willow"
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
	willow.start(entry_point, n_workers_override = 1) }

@(export)
entry_point :: proc(thread_data: ^willow.Thread_Data) {
	using willow

	log.info(gx_color_lightness(WHITE), gx_color_lightness(BLACK))

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="Graph Example", temp_allocator_cap=1000 * mem.Megabyte),
		graphics_config={ clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT })
	ui_set_theme(ui_theme_ms_dark)

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
		text_style=ui_text_style_get(), margins=4, padding=4, radius=8))

	plot_node: Plot_Node = DEFAULT_PLOT_NODE
	// plot_node.background_color = BLUE
	// plot_node.stroke_color = RED
	plot_node.label = "A very very long label inside the node"
	plot_node.xlabel = "External Label"
	plot_node.size = [2]f32{ 140, 0 }
	plot_node.position = [2]f32{ 0, 0 }
// matrix3_translate_f32

	// (TODO): Does dynamic array ever reallocate? //
	node_ptr := pt_append_node(&plot_graph, plot_node)
	dest_rect: Rect = { { 400, 140 }, { 600, 400 } }
	scr_rect := rect_screen()

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			dest_rect.size.x = 600// + 100 * math.sin(2 * time)
			dest_rect.size.y = 400// + 100 * math.cos(3 * time)
			// node_ptr.position = [2]f32{ scr_rect.size.x / 2, -scr_rect.size.y / 2 }
			// node_ptr.position = matrix3_apply(matrix3_scale_f32(1 + math.sin(4 * time)) * matrix3_rotate_f32(time) * matrix3_translate_f32({ -400, 0 }), [2]f32{ 0, 0 })
			// dr_plot_node(&plot_node, &plot_graph, { 0, 0 }, 2.0 + math.sin(4 * time))
			dr_rect_outline(dest_rect, RED)
			sn_camera_2d_tick(&camera)
			gx_clip_scope({ rect=dest_rect })
			camera.rect_normalized.position = ui_pan_control(dest_rect, { 0, 0 }, reset=input_query(.R, .PRESSED))
			// log.info(camera.rect.position)
			dr_plot_graph(&plot_graph, &camera, dest_rect)

			// rect := make_rect(0, 0, 400 + 300/* * math.sin(0.05 * time)*/, 320)
			// rect.size.y = ui_measure_text_box(text, rect.size.x)

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
			// { ui_text_style_scope(engine.ui_manager.icons_text_style); dr_text_symbol_rect(char, arrow_rect, angle = 0 * time) }
			// dr_rect(rect_margins(rect, Interval(-8)), fill_color = bg_color, radius = 4, stroke_color = stroke_color/*BLACK*/, stroke = 1)
			// dr_text_box(text, rect, h_align = .JUSTIFY, v_align = .CENTER, integer = false)
		}
		free_all(context.temp_allocator) }
	return }
