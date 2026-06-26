#+feature using-stmt
package test_asset
import "shared:oggun"
import "base:runtime"
import "core:testing"
import "core:log"

@(test)
settings_test :: proc(t_context: ^testing.T) {
	using oggun

	APPLICATION_NAME :: "Oggun Test"
	SETTINGS_NAME :: "Settings"

	settings_manager: Settings_Manager
	settings_manager_init(&settings_manager, APPLICATION_NAME, SETTINGS_NAME)

	Settings :: struct {
		fullscreen: bool,
		raw_input: bool,
		invert_x: bool,
		invert_y: bool,
		vsync: bool,
		msaa: u32,
		crosshair_pos_x: i32,
		crosshair_pos_y: i32,
		mouse_sensitivity: f32,
		player_name: string,
		backpack_size: [2]i32,
		friends: [4]string }

	settings_compare :: proc(t_context: ^testing.T, settings, settings_2: ^Settings) {
		testing.expect(t_context, settings.fullscreen == settings_2.fullscreen)
		testing.expect(t_context, settings.raw_input == settings_2.raw_input)
		testing.expect(t_context, settings.invert_x == settings_2.invert_x)
		testing.expect(t_context, settings.invert_y == settings_2.invert_y)
		testing.expect(t_context, settings.vsync == settings_2.vsync)
		testing.expect(t_context, settings.msaa == settings_2.msaa)
		testing.expect(t_context, settings.crosshair_pos_x == settings_2.crosshair_pos_x)
		testing.expect(t_context, settings.crosshair_pos_y == settings_2.crosshair_pos_y)
		testing.expect(t_context, settings.mouse_sensitivity == settings_2.mouse_sensitivity)
		testing.expect(t_context, settings.player_name == settings_2.player_name)
		testing.expect(t_context, settings.backpack_size == settings_2.backpack_size) }

	settings: Settings = {
		fullscreen = true,
		raw_input = false,
		invert_x = true,
		invert_y = true,
		vsync = false,
		msaa = 16,
		crosshair_pos_x = -80,
		crosshair_pos_y = 40,
		mouse_sensitivity = 1.4447,
		player_name = "d3stroy3r67",
		backpack_size = { 4, 8 },
		friends = { "Iva", "Mari", "Tynka", "Tomas" } }
	testing.expect(t_context, settings_verify(&settings))

	settings_manager_write(&settings_manager, &settings)
	settings_2: Settings
	settings_manager_read(&settings_manager, &settings_2)
	settings_compare(t_context, &settings, &settings_2)
	for _, i in settings.friends do testing.expect(t_context, settings.friends[i] == settings_2.friends[i])

	settings_manager_export(&settings_manager)
	settings_manager_2: Settings_Manager
	settings_manager_init(&settings_manager_2, APPLICATION_NAME, SETTINGS_NAME)
	settings_manager_import(&settings_manager_2)

	settings_2 = {}
	settings_manager_read(&settings_manager_2, &settings_2)
	settings_compare(t_context, &settings, &settings_2)

	free_all(context.temp_allocator) }
