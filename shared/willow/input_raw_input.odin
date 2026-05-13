package willow
import "core:fmt"
import "core:sys/windows"
import "vendor:glfw"

Raw_Input_Manager :: struct {
}

// Raw_Mouse :: struct {
// }

// Raw_Keyboard :: struct {
// }

raw_input_init :: proc(raw_input_manager: ^Raw_Input_Manager, input_manager: ^Input_Manager, window_manager: ^Window_Manager) {
	switch window_manager.backend {
	case .GLFW:
		glfw.SetInputMode(auto_cast window_manager.handle, glfw.CURSOR, glfw.CURSOR_DISABLED)
		assert(auto_cast glfw.RawMouseMotionSupported())
		glfw.SetInputMode(auto_cast window_manager.handle, glfw.RAW_MOUSE_MOTION, auto_cast true)
	case .Win32:
	// Get handles //
	devices: []windows.RAWINPUTDEVICELIST
	n_devices: u32
	windows.GetRawInputDeviceList(nil, &n_devices, size_of(windows.RAWINPUTDEVICELIST))
	assert(n_devices > 0)
	devices = make([]windows.RAWINPUTDEVICELIST, cast(int)n_devices)
	windows.GetRawInputDeviceList(&devices[0], &n_devices, size_of(windows.RAWINPUTDEVICELIST))
	keyboard_devices: []windows.HANDLE
	mouse_devices: []windows.HANDLE
	handles: [dynamic]windows.HANDLE = make_dynamic_array([dynamic]windows.HANDLE)
	for device in devices do if device.dwType == windows.RIM_TYPEKEYBOARD do append(&handles, device.hDevice)
	shrink(&handles)
	keyboard_devices = handles[:]
	handles = make_dynamic_array([dynamic]windows.HANDLE)
	for device in devices do if device.dwType == windows.RIM_TYPEMOUSE do append(&handles, device.hDevice)
	shrink(&handles)
	mouse_devices = handles[:]
	// fmt.println("mouse devices:", mouse_devices)
	// fmt.println("keyboard devices:", keyboard_devices)

	for mouse_device in mouse_devices {
		device_info: windows.RID_DEVICE_INFO = { cbSize = size_of(windows.RID_DEVICE_INFO) }
		device_info_size: u32 = size_of(device_info)
		n := windows.GetRawInputDeviceInfoW(mouse_device, windows.RIDI_DEVICEINFO, &device_info, &device_info_size)
		fmt.println(n)
		assert(device_info_size == size_of(windows.RID_DEVICE_INFO))
		fmt.println(device_info)
	}

	raw_input_devices := make_dynamic_array([dynamic]windows.RAWINPUTDEVICE)
	// Keyboard //
	append(&raw_input_devices, windows.RAWINPUTDEVICE{
		usUsagePage = windows.HID_USAGE_PAGE_GENERIC,
		usUsage = windows.HID_USAGE_GENERIC_KEYBOARD })
	// Mouse //
	append(&raw_input_devices, windows.RAWINPUTDEVICE{
		usUsagePage = windows.HID_USAGE_PAGE_GENERIC,
		usUsage = windows.HID_USAGE_GENERIC_MOUSE })

	// "Note that an application can register a device that is not currently attached to the system. When this device is attached, the Windows Manager will automatically send the raw input to the application." //

	assert(cast(bool)windows.RegisterRawInputDevices(&raw_input_devices[0], cast(u32)len(raw_input_devices), size_of(raw_input_devices[0]))) } }
