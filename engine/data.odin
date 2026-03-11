#+feature using-stmt
package base
import "base:runtime"
import "core:fmt"
import "core:image"
import "core:time"
import "core:strings"
import "core:container/queue"
import "core:os"
import "core:mem"
import "vendor:glfw"
import "vendor:miniaudio"
import gl "vendor:OpenGL"


TRACY_ENABLE:           bool   : #config(TRACY_ENABLE,false)
RELEASE_BUILD:          bool   : #config(RELEASE,false)
PRINT_LOGS:             bool   : #config(PRINT_LOGS,true)
PRINT_BADS:             bool   : #config(PRINT_BADS,true)
PRINT_WARNS:            bool   : #config(PRINT_WARNS,true)
PRINT_DATES:            bool   : #config(PRINT_DATES,true)
AUX_BUF_FMT:            i32    : gl.RGB12
RB_RAW:                 u8     : 0
RB_QOI:                 u8     : 1
SHADERS_PATH_RELATIVE:  string : "data/shaders"
AUDIO_PATH_RELATIVE:    string : "data/sounds"
IMAGES_PATH_RELATIVE:   string : "data/images"
MODELS_PATH_RELATIVE:   string : "data/models"
SAVES_PATH_RELATIVE:    string : "data/saves"
DATA_PATH_RELATIVE:     string : "data"
TEMP_PATH_RELATIVE:     string : "temp"
COLOR_CHANNEL:          int    : 0
POSITION_CHANNEL:       int    : 1
NORMAL_CHANNEL:         int    : 2
DEPTH_CHANNEL:          int    : 3
SCENE_MAX_TEXTURES:     int    : 4
SCENE_MAX_TEXTURE_SDFS: int    : 4
X:                      int    : 0
Y:                      int    : 1
Z:                      int    : 2
CAMERA_POS_RADIUS:      f32    : 1
CAMERA_ZOOM_RADIUS:     f32    : 4


Bump :: struct {
	offset:    f32,
	period:    f32,
	amplitude: f32 }


Font :: struct {
	name:        string,
	symbol_size: [2]f32 }


Compass :: enum {
	EAST,
	WEST,
	NORTH,
	SOUTH }


Surfer_State :: enum {
	// Camera on surfer. //
	WALKING              = 0b0000_0011,
	// Camera on surfer, surf in hand. //
	WALKING_WITH_SURF    = 0b0000_0001,
	// Camera on surfer, surf floating somewhere. //
	WALKING_WITHOUT_SURF = 0b0000_0010,
	// Camera on surfer, surf floating somewhere. //
	SWIMMING             = 0b0000_0100,
	// Camera on surf, surfer lying on surf. //
	PADDLING             = 0b0000_1000,
	// Camera on surf, surfer crouched on surf. //
	CROUCHING            = 0b0001_0000,
	// Camera on surf, surfer standing on surf. //
	STANDING             = 0b0010_0000 }


Control :: enum { SURF, SURFER }


Material :: struct {
	name:               string,
	metallic_factor:    f32,
	roughness_factor:   f32,
	base_color_texture: Texture }


Draw_Flag :: enum {
	EFFECTS,
	MODELS }


Draw_Mask :: bit_set[Draw_Flag]

