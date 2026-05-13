#+feature using-stmt
package willow
import gl "vendor:OpenGL"

init_opengl :: proc(graphics_man: ^Graphics_Manager) {
	gl.DebugMessageCallback(error_callback, nil)
	gl.Viewport(0, 0, cast(i32)graphics_man.window_manager.size.x, cast(i32)graphics_man.window_manager.size.y)
	gl.GenVertexArrays(1, &graphics_man.vertex_array)
	gl.BindVertexArray(graphics_man.vertex_array)
	gl.GenBuffers(1, &graphics_man.vertex_buffer)
	gl.BindBuffer(gl.ARRAY_BUFFER, graphics_man.vertex_buffer)
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
	gl.ClearColor(graphics_man.clear_color.r, graphics_man.clear_color.g, graphics_man.clear_color.b, 1)
	polygon_mode(.Fill)
	gl.Enable(gl.DEPTH_TEST)
	gl.DepthFunc(gl.LESS)
	gl.FrontFace(gl.CCW)
	// gl.Enable(gl.CULL_FACE) // (TODO): Some shaders are rendered the wrong way around, so this is disabled termporarily.
	gl.CullFace(gl.FRONT)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	gl.Enable(gl.MULTISAMPLE)
	gl.Enable(gl.DEBUG_OUTPUT) }
