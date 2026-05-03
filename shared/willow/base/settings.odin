#+feature using-stmt
package base

/*
Settings :: struct {
	graphics: Graphics_Settings }


Graphics_Settings :: struct {
	environment_quality: Quality_Setting,
	lighting_quality:    Quality_Setting,
	effects_quality:     Quality_Setting,
	fullscreen:          bool,
	resolution:          [2]int,
	resolution_scale:    Resolution_Scale_Setting,
	fps_limit:           Tickrate_Config }


Quality_Setting :: enum { LOW, MEDIUM, HIGH }
Resolution_Scale_Setting :: enum { PERCENT_25, PERCENT_50, PERCENT_100, PERCENT_200, PERCENT_400 }


settings_default :: proc(settings: ^Settings) {
	settings.graphics = {
		environment_quality = .HIGH,
		lighting_quality    = .HIGH,
		effects_quality     = .HIGH,
		fullscreen          = false,
		resolution          = { 1920, 960 },
		resolution_scale    = .PERCENT_100,
		fps_limit           = .LIMITED_120_FPS } }

*/