package dll
import tm "core:time"



DLL :: struct {
	lib: dynlib.Library,
	modification_time: tm.Time }


	example_dll, ok = dll.make_dll(Example_DLL, "example-dll/example-dll.dll")


	example_dll, ok = dll.make_dll(Example_DLL, "example-dll/example-dll.dll")
