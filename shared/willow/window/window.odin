package window
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:strings"

Window_Config :: struct #all_or_none {
	backend: Backend,
	position: Maybe([2]f32),
	size: [2]f32,
	title: string,
	fullscreen: bool }

WINDOW_CONFIG_DEFAULT: Window_Config : {
	backend = .GLFW,
	position = [2]f32{ -480, -270 },
	size = { 960, 540 },
	title = "Willow",
	fullscreen = false }

Window_Manager :: struct {
	handle: rawptr,
	using window_config: Window_Config }

Backend :: enum {
	Win32,
	GLFW }

create :: proc(config: Window_Config) -> (window_manager: Window_Manager) {
	init(&window_manager, config)
	return window_manager }

init :: proc(window_manager: ^Window_Manager, window_config: Window_Config) {
	window_manager.window_config = window_config
	switch window_config.backend {
	case .GLFW:
		assert(cast(bool)glfw.Init())
		glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
		glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, 1)
		glfw.WindowHint(glfw.SAMPLES, 8)
		glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		window_manager.handle = cast(rawptr)glfw.CreateWindow(
			width   = cast(i32)window_config.size.x,
			height  = cast(i32)window_config.size.y,
			title   = strings.clone_to_cstring(window_config.title),
			monitor = nil,
			share   = nil)
		display: glfw.MonitorHandle = glfw.GetPrimaryMonitor()
		video_mode: ^glfw.VidMode = glfw.GetVideoMode(display)
		display_res: [2]i32 = { video_mode.width, video_mode.height }
		if window_config.position != nil do glfw.SetWindowPos(
			window = cast(glfw.WindowHandle)window_manager.handle,
			xpos   = cast(i32)window_config.position.([2]f32).x + display_res.x / 2 - cast(i32)window_config.size.x / 2,
			ypos   = -cast(i32)window_config.position.([2]f32).y + display_res.y / 2 - cast(i32)window_config.size.y / 2)
		assert(cast(glfw.WindowHandle)window_manager.handle != nil)
		glfw.MakeContextCurrent(cast(glfw.WindowHandle)window_manager.handle)
		glfw.SwapInterval(0)
		gl.load_up_to(4, 6, glfw.gl_set_proc_address)
		glfw.FocusWindow(cast(glfw.WindowHandle)window_manager.handle)
		width, height := glfw.GetFramebufferSize(cast(glfw.WindowHandle)window_manager.handle)
		window_manager.size = { cast(f32)width, cast(f32)height }
	case .Win32: } }
