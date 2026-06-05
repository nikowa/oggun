#+feature using-stmt
package willow
import gl "vendor:OpenGL"

init_opengl :: proc() {
	assert(gl.DebugMessageCallback != nil)
	gl.DebugMessageCallback(error_callback, nil)
	gl.GenVertexArrays(1, &engine.graphics_manager.vertex_array)
	gl.BindVertexArray(engine.graphics_manager.vertex_array)
	gl.GenBuffers(1, &engine.graphics_manager.vertex_buffer)
	gl.BindBuffer(gl.ARRAY_BUFFER, engine.graphics_manager.vertex_buffer)
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
	clear_color := gx_color_to_4f32(engine.graphics_manager.clear_color)
	gl.ClearColor(clear_color.r, clear_color.g, clear_color.b, clear_color.a)
	polygon_mode(.Fill)
	gl.Enable(gl.DEPTH_TEST)
	gl.DepthFunc(gl.LESS)
	gl.FrontFace(gl.CCW)
	// gl.Enable(gl.CULL_FACE) // (TODO): Some shaders are rendered the wrong way around, so this is disabled termporarily.
	gl.CullFace(gl.FRONT)
	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	gl.Disable(gl.MULTISAMPLE)
	gl.Enable(gl.DEBUG_OUTPUT) }
