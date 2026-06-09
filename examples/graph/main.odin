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

	context = engine_begin_init(
		engine_config=default_engine_config(game_name="Graph Example", temp_allocator_cap=1000 * mem.Megabyte),
		graphics_config={ clear_color = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT })
	gi_set_theme(gi_theme_ms_dark)

	font_group: Font_Group
	font_group_init(&font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	bg_color := engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_BACKGROUND_3][0]
	fg_color := engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	stroke_color := engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_STROKE_1][0]
	text_style: Text_Style = default_text_style(font_group = font_group, color = fg_color, font_size = 8)
	gi_text_style_push(text_style)
	text: string = "*Consistent* color usage creates *visual* _continuity_ throughout experiences and even across products. The *easiest* way to guarantee _uniform_ color usage is to use Fluent's design token system. Each value in the Fluent _palettes_ is stored as a *context-agnostic* global token. Alias tokens then provide the _context_ that makes it *easy* to choose the right color without having to hunt down *hex* codes."
	zero_stopwatch(&stopwatch)

	backing_allocator := context.allocator
	context.allocator = context.temp_allocator

	plot_graph: Plot_Graph
	pt_graph_init(&plot_graph, { background_color = gi_get_background_color()[0], text_style = gi_text_style_get(), margins = 4, padding = 4, radius = 0 })

	plot_node: Plot_Node = DEFAULT_PLOT_NODE
	plot_node.background_color = BLUE
	plot_node.stroke_color = DARK_BLUE
	plot_node.label = "A very very long label inside the node"
	plot_node.xlabel = "External Label"
	plot_node.size = [2]f32{ 80, 0 }

	for engine_running() {
		time := read_stopwatch(&stopwatch)
		if engine_tick() {
			dr_plot_node(&plot_node, &plot_graph)



			// rect := make_rect(0, 0, 400 + 300/* * math.sin(0.05 * time)*/, 320)
			// rect.size.y = gi_measure_text_box(text, rect.size.x)

			// tail: [2]f32 = { -400, 100 }
			// head: [2]f32 = { 0, 200 }
			// head = engine.input_manager.mouse_position
			// vector := head - tail
			// angle: f32 = linalg.angle_between([2]f32{ 0, -1 }, vector) * (vector.x >= 0 ? 1 : -1)
			// dr_line({ tail, head }, text_style.color, integer = false)
			// arrow := head
			// // char: u8 = cast(u8)GI_Icon.Save
			// char: u8 = cast(u8)time
			// arrow_rect: Rect = { { 0, 200 }, { 24, 24 } }
			// { gi_text_style_scope(engine.gi_manager.icons_text_style); dr_text_symbol_rect(char, arrow_rect, angle = 0 * time) }
			// dr_rect(gi_rect_margins(rect, Interval(-8)), fill_color = bg_color, radius = 4, stroke_color = stroke_color/*BLACK*/, stroke = 1)
			// dr_text_box(text, rect, h_align = .JUSTIFY, v_align = .CENTER, integer = false)
		}
		free_all(context.temp_allocator) }
	return }
