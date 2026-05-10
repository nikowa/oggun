#+feature using-stmt
package graphics
import "../asset_manager"
import "../window"
import "base:runtime"
import glfw "vendor:glfw"
import gl "vendor:OpenGL"
import str "core:strings"
import os "core:os"
import "../input"
import la "core:math/linalg"
import fmt "core:fmt"
import tm "core:time"
import log "core:log"
import bs "../base"
import r "../container/rect"

init_opengl :: proc(graphics_man: ^Graphics_Manager) {
	// glfw.SetErrorCallback(glfw_error_callback)
	gl.DebugMessageCallback(error_callback, nil)
	gl.Viewport(0, 0, cast(i32)graphics_man.window_manager.size.x, cast(i32)graphics_man.window_manager.size.y)
	gl.GenVertexArrays(1, &graphics_man.vertex_array)
	gl.BindVertexArray(graphics_man.vertex_array)
	gl.GenBuffers(1, &graphics_man.vertex_buffer)
	gl.BindBuffer(gl.ARRAY_BUFFER, graphics_man.vertex_buffer)
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
	gl.ClearColor(14.0 / 255, 7.0 / 255, 7.0 / 255, 1)
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
