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
	clear_color := color_to_4f32(graphics_man.clear_color)
	gl.ClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a)
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
