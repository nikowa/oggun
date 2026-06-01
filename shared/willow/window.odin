package willow
import "base:runtime"
import "vendor:glfw"
import gl "vendor:OpenGL"
import "core:strings"
import win32 "core:sys/windows"
import "core:os"
import "core:fmt"
import "core:log"

// (TODO): Prefix all procedures in this with "wnd_"

WINDOW_VARIANT: Window_Variant : .Win32
// WINDOW_VARIANT: Window_Variant : .GLFW

Window_Config :: struct #all_or_none {
	position: [2]f32,
	size: [2]f32,
	fullscreen: bool,
	cursor: Cursor }

DEV_WINDOW_CONFIG: Window_Config : {
	position = [2]f32{ -480, -270 },
	size = { 960, 540 },
	fullscreen = false,
	cursor = .Arrow }

DEFAULT_WINDOW_CONFIG: Window_Config : {
	position = [2]f32{ 0, 0 },
	// size = { 640, 360 },
	size = { 1664, 936 },
	fullscreen = false,
	cursor = .Arrow }

Cursor :: enum {
	Arrow,
	Hand,
	Disabled }

when WINDOW_VARIANT == .GLFW do Window_Manager :: struct {
	handle: rawptr,
	using window_config: Window_Config,
	cursors: [len(Cursor)]glfw.CursorHandle }
else do Window_Manager :: struct {
	handle: rawptr,
	using window_config: Window_Config,
	cursors: [len(Cursor)]win32.HCURSOR,
	device_context: win32.HDC }

Window_Variant :: enum {
	Win32,
	GLFW }

window_create :: proc(config: Window_Config) -> (window_manager: Window_Manager) {
	window_init(config)
	return window_manager }

window_init :: proc(window_config: Window_Config) {
	engine.window_manager.window_config = window_config
	when WINDOW_VARIANT == .GLFW {
		assert(cast(bool)glfw.Init())
		glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
		glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
		glfw.WindowHint(glfw.OPENGL_DEBUG_CONTEXT, 1)
		glfw.WindowHint(glfw.SAMPLES, 8)
		glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		engine.window_manager.handle = cast(rawptr)glfw.CreateWindow(
			width   = cast(i32)window_config.size.x,
			height  = cast(i32)window_config.size.y,
			title   = strings.clone_to_cstring(engine.game_name),
			monitor = nil,
			share   = nil)
		assert(cast(glfw.WindowHandle)engine.window_manager.handle != nil)
		glfw.MakeContextCurrent(cast(glfw.WindowHandle)engine.window_manager.handle)
		glfw.SwapInterval(0)
		gl.load_up_to(4, 6, glfw.gl_set_proc_address)
		glfw.FocusWindow(cast(glfw.WindowHandle)engine.window_manager.handle)
		width, height := glfw.GetFramebufferSize(cast(glfw.WindowHandle)engine.window_manager.handle)
		wnd_update_size()
		engine.window_manager.cursors[int(Cursor.Arrow)] = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
		engine.window_manager.cursors[int(Cursor.Hand)] = glfw.CreateStandardCursor(glfw.POINTING_HAND_CURSOR)
		engine.window_manager.cursors[int(Cursor.Disabled)] = glfw.CreateStandardCursor(glfw.NOT_ALLOWED_CURSOR)
		glfw.SetInputMode(cast(glfw.WindowHandle)engine.window_manager.handle, glfw.CURSOR, glfw.CURSOR_NORMAL)
		// glfw.SetWindowFocusCallback(draw.window, focus_callback)
		glfw.SetKeyCallback(cast(glfw.WindowHandle)engine.window_manager.handle, glfw_key_callback)
		// glfw.SetScrollCallback(draw.window, scroll_callback)
		glfw.SetCursorPosCallback(cast(glfw.WindowHandle)engine.window_manager.handle, glfw_mouse_position_callback)
		glfw.SetMouseButtonCallback(cast(glfw.WindowHandle)engine.window_manager.handle, glfw_mouse_key_callback)
		// glfw.SetWindowRefreshCallback(draw.window, window_refresh_callback)
		glfw.SetWindowSizeCallback(cast(glfw.WindowHandle)engine.window_manager.handle, glfw_window_size_callback)
		// glfw.SetDropCallback(draw.window, drop_callback)
		// glfw.SetInputMode(draw.window, glfw.CURSOR, glfw.CURSOR_DISABLED)
		// glfw.SetInputMode(draw.window, glfw.RAW_MOUSE_MOTION, 0)
		// if glfw.JoystickPresent(glfw.JOYSTICK_1) && glfw.JoystickIsGamepad(glfw.JOYSTICK_1) {}
		}
	else {
		// Prelude //
		instance := win32.GetModuleHandleW(nil)
		assert(cast(win32.HANDLE)instance != win32.INVALID_HANDLE)
		icon_path := path_from_url(cast(URL)"image:icon.ico", context.temp_allocator)
		icon: win32.HICON = cast(win32.HICON)win32.LoadImageW(
			hInst=nil, name=string_to_cstring16(icon_path), type=win32.IMAGE_ICON, cx=0, cy=0, fuLoad=win32.LR_LOADFROMFILE)
		assert(cast(win32.HANDLE)icon != win32.INVALID_HANDLE)
		// fmt.println(win32_get_last_error())
		engine.window_manager.cursors[int(Cursor.Arrow)] = win32.LoadCursorA(nil, win32.IDC_ARROW)
		engine.window_manager.cursors[int(Cursor.Hand)] = win32.LoadCursorA(nil, win32.IDC_HAND)
		engine.window_manager.cursors[int(Cursor.Disabled)] = win32.LoadCursorA(nil, win32.IDC_NO)
		// win32.SetProcessDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
		// win32.SetProcessDpiAwareness(win32.PROCESS_DPI_AWARENESS.PROCESS_PER_MONITOR_DPI_AWARE)

		// Create Proper Window //
		CLASS_NAME: cstring16 : "Willow Window"
		window_class: win32.WNDCLASSEXW = {
			cbSize=size_of(win32.WNDCLASSEXW), style=win32.CS_OWNDC|win32.CS_DROPSHADOW|win32.CS_HREDRAW|win32.CS_VREDRAW, lpfnWndProc=win32_window_proc,
			hInstance=cast(win32.HANDLE)instance, hIcon=icon, hCursor=engine.window_manager.cursors[int(Cursor.Arrow)],
			lpszClassName=CLASS_NAME }
		win32.RegisterClassExW(&window_class)
		engine.window_manager.handle = cast(win32.HWND)win32.CreateWindowExW(
			dwExStyle=win32.WS_EX_ACCEPTFILES|win32.WS_EX_OVERLAPPEDWINDOW,
			lpClassName=CLASS_NAME,
			lpWindowName=string_to_cstring16(engine.game_name),
			dwStyle=win32.WS_VISIBLE|win32.WS_OVERLAPPEDWINDOW,
			X=win32.CW_USEDEFAULT, Y=win32.CW_USEDEFAULT,
			nWidth=cast(i32)window_config.size.x,
			nHeight=cast(i32)window_config.size.y,
			hWndParent=nil,
			hMenu=nil,
			hInstance=cast(win32.HANDLE)instance,
			lpParam=nil)
		assert(cast(win32.HANDLE)engine.window_manager.handle != win32.INVALID_HANDLE)
		engine.window_manager.device_context = win32.GetDC(cast(win32.HWND)engine.window_manager.handle)
		assert(cast(win32.HANDLE)engine.window_manager.device_context != win32.INVALID_HANDLE)
		corner_preference: win32.DWM_WINDOW_CORNER_PREFERENCE = .DONOTROUND
		win32.DwmSetWindowAttribute(
			hWnd=cast(win32.HWND)engine.window_manager.handle,
			dwAttribute=cast(u32)win32.DWMWINDOWATTRIBUTE.DWMWA_WINDOW_CORNER_PREFERENCE,
			pvAttribute=&corner_preference, cbAttribute=size_of(win32.DWM_WINDOW_CORNER_PREFERENCE))

		// Create Dummy Window & Context //
		DUMMY_CLASS_NAME: cstring16 : "Dummy-Class"
		dummy_window_class: win32.WNDCLASSW = {
			lpfnWndProc=win32_dummy_window_proc, hInstance=cast(win32.HANDLE)instance, lpszClassName=DUMMY_CLASS_NAME }
		assert(win32.RegisterClassW(&dummy_window_class) != 0)
		DUMMY_WINDOW_NAME: cstring16 : "Dummy-Window"
		dummy_window_handle := cast(win32.HWND)win32.CreateWindowW(
			lpClassName=DUMMY_CLASS_NAME, lpWindowName=DUMMY_WINDOW_NAME, dwStyle=win32.WS_OVERLAPPED,
			X=win32.CW_USEDEFAULT, Y=win32.CW_USEDEFAULT,
			nWidth=1, nHeight=1, hWndParent=nil, hMenu=nil,
			hInstance=cast(win32.HANDLE)instance, lpParam=nil)
		assert(cast(win32.HANDLE)dummy_window_handle != win32.INVALID_HANDLE)
		dummy_device_context := win32.GetDC(cast(win32.HWND)dummy_window_handle)
		assert(cast(win32.HANDLE)dummy_device_context != win32.INVALID_HANDLE)
		pixel_format_desc: win32.PIXELFORMATDESCRIPTOR = {
			nSize=size_of(win32.PIXELFORMATDESCRIPTOR),
			nVersion=1,
			dwFlags=win32.PFD_DRAW_TO_WINDOW|win32.PFD_SUPPORT_OPENGL|win32.PFD_DOUBLEBUFFER,
			iPixelType=win32.PFD_TYPE_RGBA,
			cColorBits=32,
			cAlphaBits=8,
			cDepthBits=24,
			cStencilBits=8,
			cAuxBuffers=0,
			iLayerType=win32.PFD_MAIN_PLANE }
		pixel_format: i32 = win32.ChoosePixelFormat(dummy_device_context, &pixel_format_desc)
		assert(pixel_format != 0)
		assert(cast(bool)win32.SetPixelFormat(dummy_device_context, pixel_format, &pixel_format_desc))
		dummy_opengl_context := win32.wglCreateContext(dummy_device_context)
		assert(cast(win32.HANDLE)dummy_opengl_context != win32.INVALID_HANDLE)
		win32.wglMakeCurrent(dummy_device_context, dummy_opengl_context)
		win32.wglChoosePixelFormatARB = auto_cast win32.wglGetProcAddress("wglChoosePixelFormatARB")
		assert(win32.wglChoosePixelFormatARB != nil)
		win32.wglCreateContextAttribsARB = auto_cast win32.wglGetProcAddress("wglCreateContextAttribsARB")
		assert(win32.wglCreateContextAttribsARB != nil)

		// Create Proper Context //
		pixel_attribs: []i32 = {
			win32.WGL_DRAW_TO_WINDOW_ARB, 1,
			win32.WGL_SUPPORT_OPENGL_ARB, 1,
			win32.WGL_DOUBLE_BUFFER_ARB,  1,
			win32.WGL_PIXEL_TYPE_ARB,     win32.WGL_TYPE_RGBA_ARB,
			win32.WGL_COLOR_BITS_ARB,     32,
			win32.WGL_ALPHA_BITS_ARB,     8,
			win32.WGL_DEPTH_BITS_ARB,     24,
			win32.WGL_STENCIL_BITS_ARB,   8,
			win32.WGL_ACCELERATION_ARB,   win32.WGL_FULL_ACCELERATION_ARB,
			win32.WGL_SAMPLE_BUFFERS_ARB, 0,
			win32.WGL_SAMPLES_ARB,        0,
			0 }
		n_formats: u32
		assert(cast(bool)win32.wglChoosePixelFormatARB(engine.window_manager.device_context, &pixel_attribs[0], nil, 1, &pixel_format, &n_formats))
		assert(n_formats == 1)
		pixel_format_descriptor: win32.PIXELFORMATDESCRIPTOR
		assert(win32.DescribePixelFormat(engine.window_manager.device_context, pixel_format, size_of(pixel_format_descriptor), &pixel_format_descriptor) != 0)
		assert(cast(bool)win32.SetPixelFormat(engine.window_manager.device_context, pixel_format, &pixel_format_descriptor))
		context_attribs: []i32 = {
			win32.WGL_CONTEXT_MAJOR_VERSION_ARB, 4, // use constant
			win32.WGL_CONTEXT_MINOR_VERSION_ARB, 6, // use constant
			win32.WGL_CONTEXT_PROFILE_MASK_ARB,  win32.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
			win32.WGL_CONTEXT_FLAGS_ARB,         win32.WGL_CONTEXT_FORWARD_COMPATIBLE_BIT_ARB,
			0 }
		opengl_context := win32.wglCreateContextAttribsARB(engine.window_manager.device_context, nil, &context_attribs[0])
		// opengl_context := win32.wglCreateContext(engine.window_manager.device_context)
		assert(cast(win32.HANDLE)opengl_context != win32.INVALID_HANDLE)

		win32.wglMakeCurrent(nil, nil)
		win32.wglDeleteContext(dummy_opengl_context)
		win32.ReleaseDC(dummy_window_handle, dummy_device_context)
		win32.DestroyWindow(dummy_window_handle)

		win32.wglMakeCurrent(engine.window_manager.device_context, opengl_context)
		assert(win32.wglGetCurrentContext() != nil)
		gl.load_up_to(4, 6, win32.gl_set_proc_address)
		// os.exit(0)
	}
	// log.info(string(gl.GetString(gl.VERSION)))
	wnd_set_pos(window_config.position)
}

color_to_win32_color :: proc(color: Color) -> (win32_color: win32.COLORREF) {
	vec := color_to_4u8(color)
	return auto_cast color_from_4u8({ 0, vec.b, vec.g, vec.r }) }

wnd_customize :: proc(header_color, border_color: Color) {
	header_colorref := color_to_win32_color(header_color)
	win32.DwmSetWindowAttribute(
		hWnd=cast(win32.HWND)engine.window_manager.handle,
		dwAttribute=cast(u32)win32.DWMWINDOWATTRIBUTE.DWMWA_CAPTION_COLOR,
		pvAttribute=&header_colorref,
		cbAttribute=size_of(win32.COLORREF))
	border_colorref := color_to_win32_color(border_color)
	win32.DwmSetWindowAttribute(
		hWnd=cast(win32.HWND)engine.window_manager.handle,
		dwAttribute=cast(u32)win32.DWMWINDOWATTRIBUTE.DWMWA_BORDER_COLOR,
		pvAttribute=&border_colorref,
		cbAttribute=size_of(win32.COLORREF)) }

wnd_update_size :: proc() {
	if engine.window_manager.handle == nil do return
	when WINDOW_VARIANT == .GLFW {
		width, height := glfw.GetFramebufferSize(cast(glfw.WindowHandle)engine.window_manager.handle)
		engine.window_manager.size = { cast(f32)width, cast(f32)height } }
	else {
		client_rect: win32.RECT
		win32.GetClientRect(cast(win32.HWND)engine.window_manager.handle, &client_rect)
		// point_0: win32.POINT = { client_rect.right, client_rect.bottom }
		// point_1: win32.POINT = { client_rect.left, client_rect.top }
		// win32.ClientToScreen(cast(win32.HWND)engine.window_manager.handle, &point_1)
		// log.warn(point_0)
		// win32.ClientToScreen(cast(win32.HWND)engine.window_manager.handle, &point_0)
		// log.warn(point_0)
		// size: [2]f32 = { f32(point_0.x - point_1.x), f32(point_0.y - point_1.y) }
		engine.window_manager.size = {
			f32(client_rect.right - client_rect.left),
			f32(client_rect.bottom - client_rect.top) + 1 } // (NOTE): Rects do not render properly unless 1 is added here. //
		// monitor := win32.MonitorFromWindow(cast(win32.HWND)engine.window_manager.handle, {})
		// monitor_dpi: [2]u32
		// win32.GetDpiForMonitor(monitor, .MDT_EFFECTIVE_DPI, &monitor_dpi.x, &monitor_dpi.y)
		// dpi: f32 = cast(f32)win32.GetDpiForWindow(cast(win32.HWND)engine.window_manager.handle)
		// dpi_aware: f32 = cast(f32)win32.GetDpiFromDpiAwarenessContext(win32.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2)
		// log.error(win32.GetWindowDpiAwarenessContext(cast(win32.HWND)engine.window_manager.handle))
		// // DICK
		// caps: f32 = cast(f32)win32.GetDeviceCaps(engine.window_manager.device_context, 10)
		// log.error(dpi, dpi_aware, monitor_dpi, caps, size)
		window_info: win32.WINDOWINFO
		win32.GetWindowInfo(cast(win32.HWND)engine.window_manager.handle, &window_info)
		log.warn(window_info)
		// engine.window_manager.size *= dpi
		// engine.window_manager.size = { 1676, 954 }
		// engine.window_manager.size = size
		}
	if gl.Viewport != nil do gl.Viewport(0, 0, cast(i32)engine.window_manager.size.x, cast(i32)engine.window_manager.size.y)
	log.info("Window size:", engine.window_manager.size) }

wnd_get_display_size :: proc() -> [2]f32 {
	if cast(rawptr)engine.window_manager.handle == nil do return DEFAULT_WINDOW_CONFIG.size
	when WINDOW_VARIANT == .GLFW {
		display: glfw.MonitorHandle = glfw.GetPrimaryMonitor()
		video_mode: ^glfw.VidMode = glfw.GetVideoMode(display)
		return { cast(f32)video_mode.width, cast(f32)video_mode.height } }
	else {
		monitor: win32.HMONITOR = win32.MonitorFromWindow(
			hwnd=cast(win32.HWND)engine.window_manager.handle, dwFlags=win32.Monitor_From_Flags.MONITOR_DEFAULTTONEAREST)
		monitor_info: win32.MONITORINFO = { cbSize = size_of(win32.MONITORINFO) }
		win32.GetMonitorInfoW(monitor, &monitor_info)
		return {
			f32(monitor_info.rcMonitor.right - monitor_info.rcMonitor.left),
		    f32(monitor_info.rcMonitor.bottom - monitor_info.rcMonitor.top) } }
	return {} }

wnd_set_pos :: proc(position: [2]f32) {
	engine.window_manager.position = position
	display_size: [2]f32 = wnd_get_display_size()
	position_normalized: [2]i32 = {
		i32(engine.window_manager.position.x + display_size.x / 2 - engine.window_manager.size.x / 2),
		i32(-engine.window_manager.position.y + display_size.y / 2 - engine.window_manager.size.y / 2) }
	when WINDOW_VARIANT == .GLFW {
		glfw.SetWindowPos(
			window=cast(glfw.WindowHandle)engine.window_manager.handle,
			xpos=position_normalized.x, ypos=position_normalized.y) }
	else {
		win32.SetWindowPos(
			hWnd=cast(win32.HWND)engine.window_manager.handle, hWndInsertAfter=win32.HWND_TOP,
			X=position_normalized.x, Y=position_normalized.y,
			cx=0, cy=0, uFlags=win32.SWP_NOSIZE|win32.SWP_NOZORDER) } }

// public Bool draw_window_WGL() {
// 	if (wcx.closed) { return false; }
// 	// TODO Return false if the window was closed. //
// 	MSG message = { };
// 	Bool has_message = PeekMessageA(&message, NULL, 0, 0, PM_REMOVE) > 0;
// 	if (! has_message) { return true; }
// 	TranslateMessage(&message);
// 	DispatchMessage(&message);
// 	return true; }

WIN32_KEY_MAP: [512]Input = {
	0 = Input.None,
	win32.VK_SPACE = Input.Space,
	win32.VK_OEM_7 = Input.Apostrophe,
	win32.VK_OEM_COMMA = Input.Comma,
	win32.VK_OEM_MINUS = Input.Minus,
	win32.VK_OEM_PERIOD = Input.Period,
	win32.VK_OEM_2 = Input.Slash,
	'0' = Input.Num_0,
	'1' = Input.Num_1,
	'2' = Input.Num_2,
	'3' = Input.Num_3,
	'4' = Input.Num_4,
	'5' = Input.Num_5,
	'6' = Input.Num_6,
	'7' = Input.Num_7,
	'8' = Input.Num_8,
	'9' = Input.Num_9,
	win32.VK_OEM_1 = Input.Semicolon,
	win32.VK_OEM_PLUS = Input.Equal,
	'A' = Input.A,
	'B' = Input.B,
	'C' = Input.C,
	'D' = Input.D,
	'E' = Input.E,
	'F' = Input.F,
	'G' = Input.G,
	'H' = Input.H,
	'I' = Input.I,
	'J' = Input.J,
	'K' = Input.K,
	'L' = Input.L,
	'M' = Input.M,
	'N' = Input.N,
	'O' = Input.O,
	'P' = Input.P,
	'Q' = Input.Q,
	'R' = Input.R,
	'S' = Input.S,
	'T' = Input.T,
	'U' = Input.U,
	'V' = Input.V,
	'W' = Input.W,
	'X' = Input.X,
	'Y' = Input.Y,
	'Z' = Input.Z,
	win32.VK_OEM_4 = Input.Left_Bracket,
	win32.VK_OEM_5 = Input.Backslash,
	win32.VK_OEM_6 = Input.Right_Bracket,
	win32.VK_OEM_3 = Input.Backtick,
	win32.VK_ESCAPE = Input.Escape,
	win32.VK_RETURN = Input.Enter,
	win32.VK_TAB = Input.Tab,
	win32.VK_BACK = Input.Backspace,
	win32.VK_INSERT = Input.Insert,
	win32.VK_DELETE = Input.Delete,
	win32.VK_RIGHT = Input.Right,
	win32.VK_LEFT = Input.Left,
	win32.VK_DOWN = Input.Down,
	win32.VK_UP = Input.Up,
	win32.VK_PRIOR = Input.Page_Up,
	win32.VK_NEXT = Input.Page_Down,
	win32.VK_HOME = Input.Home,
	win32.VK_END = Input.End,
	win32.VK_CAPITAL = Input.Caps_Lock,
	win32.VK_SCROLL = Input.Scroll_Lock,
	win32.VK_NUMLOCK = Input.Num_Lock,
	win32.VK_PRINT = Input.Print_Screen,
	win32.VK_PAUSE = Input.Pause,
	win32.VK_F1 = Input.F1,
	win32.VK_F2 = Input.F2,
	win32.VK_F3 = Input.F3,
	win32.VK_F4 = Input.F4,
	win32.VK_F5 = Input.F5,
	win32.VK_F6 = Input.F6,
	win32.VK_F7 = Input.F7,
	win32.VK_F8 = Input.F8,
	win32.VK_F9 = Input.F9,
	win32.VK_F10 = Input.F10,
	win32.VK_F11 = Input.F11,
	win32.VK_F12 = Input.F12,
	win32.VK_F13 = Input.F13,
	win32.VK_F14 = Input.F14,
	win32.VK_F15 = Input.F15,
	win32.VK_F16 = Input.F16,
	win32.VK_F17 = Input.F17,
	win32.VK_F18 = Input.F18,
	win32.VK_F19 = Input.F19,
	win32.VK_F20 = Input.F20,
	win32.VK_F21 = Input.F21,
	win32.VK_F22 = Input.F22,
	win32.VK_F23 = Input.F23,
	win32.VK_F24 = Input.F24,
	win32.VK_NUMPAD0 = Input.Numpad_0,
	win32.VK_NUMPAD1 = Input.Numpad_1,
	win32.VK_NUMPAD2 = Input.Numpad_2,
	win32.VK_NUMPAD3 = Input.Numpad_3,
	win32.VK_NUMPAD4 = Input.Numpad_4,
	win32.VK_NUMPAD5 = Input.Numpad_5,
	win32.VK_NUMPAD6 = Input.Numpad_6,
	win32.VK_NUMPAD7 = Input.Numpad_7,
	win32.VK_NUMPAD8 = Input.Numpad_8,
	win32.VK_NUMPAD9 = Input.Numpad_9,
	win32.VK_DECIMAL = Input.Numpad_Decimal,
	win32.VK_DIVIDE = Input.Numpad_Divide,
	win32.VK_MULTIPLY = Input.Numpad_Multiply,
	win32.VK_SUBTRACT = Input.Numpad_Subtract,
	win32.VK_ADD = Input.Numpad_Add,
	// = Input.Numpad_Enter,
	// = Input.Numpad_Equal,
	win32.VK_SHIFT = Input.Left_Shift,
	win32.VK_CONTROL = Input.Left_Control,
	win32.VK_MENU = Input.Left_Alt,
	win32.VK_LWIN = Input.Left_Super }

when WINDOW_VARIANT == .Win32 {

	win32_dummy_window_proc :: proc "stdcall" (handle: win32.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
		return win32.DefWindowProcW(handle, message, w_param, l_param) }

	win32_window_proc :: proc "stdcall" (handle: win32.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
		context = runtime.default_context()
		switch message {
		case win32.WM_CREATE:
			fmt.println("WM_CREATE")
		case win32.WM_SIZE:
			size: [2]f32 = {
				cast(f32)win32.GET_X_LPARAM(l_param),
				cast(f32)win32.GET_Y_LPARAM(l_param) }
			wnd_update_size()
			fmt.println("WM_SIZE", size)
		case win32.WM_CONTEXTMENU:
			fmt.println("WM_CONTEXTMENU")
		case win32.WM_RBUTTONDOWN:
			input_record_key(.Mouse_Right, .Press)
			return 0
		case win32.WM_RBUTTONUP:
			input_record_key(.Mouse_Right, .Release)
			return 0
		case win32.WM_LBUTTONDOWN:
			input_record_key(.Mouse_Left, .Press)
			return 0
		case win32.WM_LBUTTONUP:
			input_record_key(.Mouse_Left, .Release)
			return 0
		case win32.WM_MOUSEMOVE:
			position: [2]f32 = {
				cast(f32)win32.GET_X_LPARAM(l_param),
				cast(f32)win32.GET_Y_LPARAM(l_param) }
		// i32(position.x + display_size.x / 2 - engine.window_manager.size.x / 2),
		// i32(-position.y + display_size.y / 2 - engine.window_manager.size.y / 2) }
			engine.input_manager.mouse_position = {
				- engine.window_manager.size.x / 2 + position.x,
				engine.window_manager.size.y / 2 - position.y }
			return 0
		case win32.WM_KEYDOWN:
			input_record_key(WIN32_KEY_MAP[w_param], .Press)
			return 0
		case win32.WM_KEYUP:
			input_record_key(WIN32_KEY_MAP[w_param], .Release)
			return 0
		case win32.WM_CLOSE:
			fmt.println("WM_CLOSE")
		case win32.WM_DESTROY:
			fmt.println("WM_DESTROY")
			// win32.ReleaseDC(window, wcx.device_context);
			// win32.wglDeleteContext(wcx.opengl_context);
			// win32.PostQuitMessage(0);
			engine.graphics_manager.window_closed = true
			return 0
			// DICK
		}
		return win32.DefWindowProcW(handle, message, w_param, l_param) }

	win32_get_last_error :: proc() -> string {
		message: cstring16
		win32.FormatMessageW(
			flags=win32.FORMAT_MESSAGE_ALLOCATE_BUFFER | win32.FORMAT_MESSAGE_FROM_SYSTEM | win32.FORMAT_MESSAGE_IGNORE_INSERTS,
			lpSrc=nil,
			msgId=win32.GetLastError(),
			langId=win32.MAKELANGID(win32.LANG_NEUTRAL, win32.SUBLANG_DEFAULT),
			buf=auto_cast message,
			nsize=0,
			args=nil)
		return cstring16_to_string(message) }

}

window_tick :: proc() {
	when WINDOW_VARIANT == .GLFW {
		glfw.PollEvents()
		glfw.SwapBuffers(cast(glfw.WindowHandle)engine.window_manager.handle) }
	else {
		message: win32.MSG
		for cast(bool)win32.PeekMessageW(&message, nil, 0, 0, win32.PM_REMOVE) {
			win32.TranslateMessage(&message)
			win32.DispatchMessageW(&message) }
		win32.SwapBuffers(engine.window_manager.device_context) }
	set_cursor_immediate(engine.window_manager.cursor)
	set_cursor(.Arrow) }

set_cursor :: proc(cursor: Cursor) {
	engine.window_manager.cursor = cursor }

set_cursor_immediate :: proc(cursor: Cursor) {
	// (TEMP):
	when WINDOW_VARIANT == .GLFW do glfw.SetCursor(cast(glfw.WindowHandle)engine.window_manager.handle, engine.window_manager.cursors[int(cursor)])
	else do win32.SetCursor(engine.window_manager.cursors[int(cursor)])
}

@(private="file")
glfw_key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	context = runtime.default_context()
	context.logger = log.create_console_logger()
	input_record_key(cast(Input)key, action == glfw.RELEASE ? .Release : .Press) }

@(private="file")
glfw_mouse_position_callback :: proc "c" (window: glfw.WindowHandle, x, y: f64) {
	context = runtime.default_context()
	context.logger = log.create_console_logger()
	@(static) called: bool = false
	width, height: i32 = glfw.GetWindowSize(window)
	mouse_position := [2]f32{ - f32(width) / 2 + f32(x), - f32(height) / 2 + f32(height) - f32(y) }
	if called do engine.input_manager.mouse_delta += mouse_position - engine.input_manager.mouse_position
	// if (abs(input_manager.mouse_delta.x) > 100) && (abs(input_manager.mouse_delta.y) > 100) { input_manager.mouse_delta = { 0, 0 } }
	input_record_mouse_position(mouse_position)
	called = true }

@(private="file")
glfw_mouse_key_callback :: proc "c" (window: glfw.WindowHandle, glfw_key, glfw_action, mods: i32) {
	context = runtime.default_context()
	context.logger = log.create_console_logger()
	key: Input
	switch glfw_key {
	case glfw.MOUSE_BUTTON_LEFT:  key = .Mouse_Left
	case glfw.MOUSE_BUTTON_RIGHT: key = .Mouse_Right }
	action: Action
	switch glfw_action {
	case glfw.PRESS: action = .Press
	case glfw.RELEASE: action = .Release }
	if action != .None do input_record_key(cast(Input)key, action) }

glfw_window_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	context = runtime.default_context()
	context.logger = log.create_console_logger()
	wnd_update_size() }
