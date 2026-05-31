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
		engine.window_manager.size = { cast(f32)width, cast(f32)height }
		engine.window_manager.cursors[int(Cursor.Arrow)] = glfw.CreateStandardCursor(glfw.ARROW_CURSOR)
		engine.window_manager.cursors[int(Cursor.Hand)] = glfw.CreateStandardCursor(glfw.POINTING_HAND_CURSOR)
		engine.window_manager.cursors[int(Cursor.Disabled)] = glfw.CreateStandardCursor(glfw.NOT_ALLOWED_CURSOR) }
	else {
		instance := win32.GetModuleHandleW(nil)
		assert(cast(win32.HANDLE)instance != win32.INVALID_HANDLE)
		icon_path := path_from_url(cast(URL)"image:icon.ico", context.temp_allocator)
		icon: win32.HICON = cast(win32.HICON)win32.LoadImageW(
			hInst=nil, name=string_to_cstring16(icon_path), type=win32.IMAGE_ICON, cx=0, cy=0, fuLoad=win32.LR_LOADFROMFILE)
		assert(cast(win32.HANDLE)icon != win32.INVALID_HANDLE)
		CLASS_NAME: cstring16 : "Willow Window"
		// fmt.println(win32_get_last_error())
		engine.window_manager.cursors[int(Cursor.Arrow)] = win32.LoadCursorA(nil, win32.IDC_ARROW)
		engine.window_manager.cursors[int(Cursor.Hand)] = win32.LoadCursorA(nil, win32.IDC_HAND)
		engine.window_manager.cursors[int(Cursor.Disabled)] = win32.LoadCursorA(nil, win32.IDC_NO)
		window_class: win32.WNDCLASSEXW = {
			cbSize=size_of(win32.WNDCLASSEXW), style=win32.CS_OWNDC|win32.CS_DROPSHADOW|win32.CS_HREDRAW|win32.CS_VREDRAW, lpfnWndProc=win32_window_proc,
			hInstance=cast(win32.HANDLE)instance, hIcon=icon, hCursor=engine.window_manager.cursors[int(Cursor.Arrow)],
			lpszClassName=CLASS_NAME }
		win32.RegisterClassExW(&window_class)
		engine.window_manager.handle = cast(win32.HWND)win32.CreateWindowExW(
			dwExStyle=win32.WS_EX_TOPMOST|win32.WS_EX_ACCEPTFILES|win32.WS_EX_DLGMODALFRAME,
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
		corner_preference: win32.DWM_WINDOW_CORNER_PREFERENCE = .DONOTROUND
		win32.DwmSetWindowAttribute(
			hWnd=cast(win32.HWND)engine.window_manager.handle,
			dwAttribute=cast(u32)win32.DWMWINDOWATTRIBUTE.DWMWA_WINDOW_CORNER_PREFERENCE,
			pvAttribute=&corner_preference, cbAttribute=size_of(win32.DWM_WINDOW_CORNER_PREFERENCE))
		engine.window_manager.device_context = win32.GetDC(cast(win32.HWND)engine.window_manager.handle)
		assert(cast(win32.HANDLE)engine.window_manager.device_context != win32.INVALID_HANDLE)
		pixel_format_desc: win32.PIXELFORMATDESCRIPTOR = {
			nSize=size_of(win32.PIXELFORMATDESCRIPTOR),
			nVersion=1,
			dwFlags=win32.PFD_DRAW_TO_WINDOW|win32.PFD_SUPPORT_OPENGL|win32.PFD_DOUBLEBUFFER,
			iPixelType=win32.PFD_TYPE_RGBA,
			cColorBits=24,
			cDepthBits=32,
			cStencilBits=0,
			cAuxBuffers=0,
			iLayerType=win32.PFD_MAIN_PLANE }
		pixel_format: i32 = win32.ChoosePixelFormat(engine.window_manager.device_context, &pixel_format_desc)
		assert(pixel_format != 0)
		assert(cast(bool)win32.SetPixelFormat(engine.window_manager.device_context, pixel_format, &pixel_format_desc))
		opengl_context := win32.wglCreateContext(engine.window_manager.device_context)
		win32.wglMakeCurrent(engine.window_manager.device_context, opengl_context)
		gl.load_up_to(4, 6, win32.gl_set_proc_address)
		// os.exit(0)
	}
	wnd_set_pos(window_config.position)
}

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

when WINDOW_VARIANT == .Win32 {

	win32_window_proc :: proc "stdcall" (handle: win32.HWND, message: u32, w_param: uintptr, l_param: int) -> int {
		context = runtime.default_context()
		switch message {
		case win32.WM_CREATE:
			fmt.println("WM_CREATE")
		case win32.WM_SIZE:
			fmt.println("WM_SIZE")
		case win32.WM_CONTEXTMENU:
			fmt.println("WM_CONTEXTMENU")
		case win32.WM_RBUTTONDOWN:
			fmt.println("WM_RBUTTONDOWN")
			return 0
		case win32.WM_RBUTTONUP:
			fmt.println("WM_RBUTTONUP")
			return 0
		case win32.WM_LBUTTONDOWN:
			fmt.println("WM_LBUTTONDOWN")
			return 0
		case win32.WM_LBUTTONUP:
			fmt.println("WM_LBUTTONUP")
			return 0
		case win32.WM_MOUSEMOVE:
			fmt.println("WM_MOUSEMOVE")
			return 0
		case win32.WM_KEYDOWN:
			fmt.println("WM_KEYDOWN")
			return 0
		case win32.WM_KEYUP:
			fmt.println("WM_KEYUP")
			return 0
		case win32.WM_CLOSE:
		case win32.WM_DESTROY:
			// win32.ReleaseDC(window, wcx.device_context);
			// win32.wglDeleteContext(wcx.opengl_context);
			// win32.PostQuitMessage(0);
			engine.graphics_manager.window_closed = true
			return 0
			// DICK
		// case WM_PAINT:
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
		win32.SwapBuffers(engine.window_manager.device_context)
		// DICK
	}
	set_cursor_immediate(engine.window_manager.cursor)
	set_cursor(.Arrow) }

set_cursor :: proc(cursor: Cursor) {
	engine.window_manager.cursor = cursor }

set_cursor_immediate :: proc(cursor: Cursor) {
	when WINDOW_VARIANT == .GLFW do glfw.SetCursor(cast(glfw.WindowHandle)engine.window_manager.handle, engine.window_manager.cursors[int(cursor)])
	else do win32.SetCursor(engine.window_manager.cursors[int(cursor)]) }
