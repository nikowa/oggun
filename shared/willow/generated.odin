package willow
import "core:time"
// Generated at 22:15:58 //

default_asset_manager_config :: proc(
		relpath: string = DEFAULT_ASSET_MANAGER_CONFIG.relpath,
		source_directory_relpath: string = DEFAULT_ASSET_MANAGER_CONFIG.source_directory_relpath,
		autosave_interval: time.Duration = DEFAULT_ASSET_MANAGER_CONFIG.autosave_interval,
		autosave_cap: u32 = DEFAULT_ASSET_MANAGER_CONFIG.autosave_cap,
		watch: bool = DEFAULT_ASSET_MANAGER_CONFIG.watch,
) -> Asset_Manager_Config {
	return {
		relpath = relpath,
		source_directory_relpath = source_directory_relpath,
		autosave_interval = autosave_interval,
		autosave_cap = autosave_cap,
		watch = watch } }

default_asset_config :: proc(
		derived_type: typeid,
		url: URL = DEFAULT_ASSET_CONFIG.url,
) -> Asset_Config {
	return {
		url = url,
		derived_type = derived_type } }

default_entry_config :: proc(
		url: URL = DEFAULT_ENTRY_CONFIG.url,
		modification_time: time.Time = DEFAULT_ENTRY_CONFIG.modification_time,
		data: []u8 = DEFAULT_ENTRY_CONFIG.data,
) -> Entry_Config {
	return {
		url = url,
		modification_time = modification_time,
		data = data } }

default_tick_manager_config :: proc(
		tickrate_setting: Tickrate_Setting = DEFAULT_TICK_MANAGER_CONFIG.tickrate_setting,
) -> Tick_Manager_Config {
	return {
		tickrate_setting = tickrate_setting } }

default_settings_manager_config :: proc(
		settings_name: string = DEFAULT_SETTINGS_MANAGER_CONFIG.settings_name,
) -> Settings_Manager_Config {
	return {
		settings_name = settings_name } }

default_graphics_config :: proc(
		clear_color: Color = DEFAULT_GRAPHICS_CONFIG.clear_color,
) -> Graphics_Config {
	return {
		clear_color = clear_color } }

default_effect_config :: proc(
		url: URL = DEFAULT_EFFECT_CONFIG.url,
		surface_res: [][2]u32 = DEFAULT_EFFECT_CONFIG.surface_res,
) -> Effect_Config {
	return {
		url = url,
		surface_res = surface_res } }

default_font_config :: proc(
		name: string = DEFAULT_FONT_CONFIG.name,
		default_bearing: u8 = DEFAULT_FONT_CONFIG.default_bearing,
		default_advance: u8 = DEFAULT_FONT_CONFIG.default_advance,
) -> Font_Config {
	return {
		name = name,
		default_bearing = default_bearing,
		default_advance = default_advance } }

default_text_style :: proc(
		color: Color = DEFAULT_TEXT_STYLE.color,
		italic: bool = DEFAULT_TEXT_STYLE.italic,
		bold: bool = DEFAULT_TEXT_STYLE.bold,
		font_group: Font_Group = DEFAULT_TEXT_STYLE.font_group,
		font_size: Font_Size = DEFAULT_TEXT_STYLE.font_size,
		tracking: f32 = DEFAULT_TEXT_STYLE.tracking,
		spacing: f32 = DEFAULT_TEXT_STYLE.spacing,
		leading: f32 = DEFAULT_TEXT_STYLE.leading,
) -> Text_Style {
	return {
		color = color,
		italic = italic,
		bold = bold,
		font_group = font_group,
		font_size = font_size,
		tracking = tracking,
		spacing = spacing,
		leading = leading } }

default_shader_config :: proc(
		vert_url: URL = DEFAULT_SHADER_CONFIG.vert_url,
		frag_url: URL = DEFAULT_SHADER_CONFIG.frag_url,
) -> Shader_Config {
	return {
		vert_url = vert_url,
		frag_url = frag_url } }

default_input_config :: proc(
		raw_input: bool = DEFAULT_INPUT_CONFIG.raw_input,
) -> Input_Config {
	return {
		raw_input = raw_input } }

default_scene_config :: proc(
		url: URL = DEFAULT_SCENE_CONFIG.url,
		haze_color: Color = DEFAULT_SCENE_CONFIG.haze_color,
) -> Scene_Config {
	return {
		url = url,
		haze_color = haze_color } }

default_node_config :: proc(
		name: string = DEFAULT_NODE_CONFIG.name,
		id: u32 = DEFAULT_NODE_CONFIG.id,
		render_proc: Node_Render_Proc = DEFAULT_NODE_CONFIG.render_proc,
		tick_proc: Node_Tick_Proc = DEFAULT_NODE_CONFIG.tick_proc,
		translate: [3]f32 = DEFAULT_NODE_CONFIG.translate,
		rotate: quaternion128 = DEFAULT_NODE_CONFIG.rotate,
		scale: [3]f32 = DEFAULT_NODE_CONFIG.scale,
		visible: bool = DEFAULT_NODE_CONFIG.visible,
) -> Node_Config {
	return {
		name = name,
		id = id,
		render_proc = render_proc,
		tick_proc = tick_proc,
		translate = translate,
		rotate = rotate,
		scale = scale,
		visible = visible } }

default_camera_config :: proc(
		focal_length: f32 = DEFAULT_CAMERA_CONFIG.focal_length,
		sensor_size: [2]f32 = DEFAULT_CAMERA_CONFIG.sensor_size,
		near_clip: f32 = DEFAULT_CAMERA_CONFIG.near_clip,
		far_clip: f32 = DEFAULT_CAMERA_CONFIG.far_clip,
) -> Camera_Config {
	return {
		focal_length = focal_length,
		sensor_size = sensor_size,
		near_clip = near_clip,
		far_clip = far_clip } }

default_window_config :: proc(
		position: [2]f32 = DEFAULT_WINDOW_CONFIG.position,
		size: [2]f32 = DEFAULT_WINDOW_CONFIG.size,
		fullscreen: bool = DEFAULT_WINDOW_CONFIG.fullscreen,
		cursor: Cursor = DEFAULT_WINDOW_CONFIG.cursor,
) -> Window_Config {
	return {
		position = position,
		size = size,
		fullscreen = fullscreen,
		cursor = cursor } }

