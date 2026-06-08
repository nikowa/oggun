#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"
import "core:log"
import "core:strings"

GI_Manager :: struct {
	font_group: Font_Group,
	icons_font_group: Font_Group,
	text_style: Text_Style,
	icons_text_style: Text_Style,
	anim_transitions: map[runtime.Source_Code_Location]GI_Anim_Transition,
	// caption2_font_group: Font_Group,  // 10px
	// caption1_font_group: Font_Group,  // 12px
	// body1_font_group: Font_Group,     // 14px
	// body2_font_group: Font_Group,     // 16px
	// subtitle1_font_group: Font_Group, // 20px
	theme: ^GI_Theme,
	button_shape_stack, button_shape_stack_store: [dynamic]GI_Button_Shape,
	appearance_stack, appearance_stack_store: [dynamic]GI_Appearance,
	disabled_stack, disabled_stack_store: [dynamic]bool,
	text_style_stack, text_style_stack_store: [dynamic]Text_Style }

GI_Variant :: enum {
	NORMAL = 0,
	HOVER,
	PRESSED,
	SELECTED,
	VARIANT_1 = 0,
	VARIANT_2,
	VARIANT_3,
	VARIANT_4 }

GI_Button_Shape :: enum {
	ROUNDED,
	CIRCULAR,
	SQUARE }

GI_Theme_Key :: enum {
	NEUTRAL_BACKGROUND_1,
	NEUTRAL_FOREGROUND_1,
	NEUTRAL_STROKE_1,

	NEUTRAL_BACKGROUND_2,
	NEUTRAL_FOREGROUND_2,
	NEUTRAL_STROKE_2,

	NEUTRAL_BACKGROUND_3,
	NEUTRAL_FOREGROUND_3,
	NEUTRAL_STROKE_3,

	NEUTRAL_BACKGROUND_4,
	NEUTRAL_FOREGROUND_4,
	NEUTRAL_STROKE_4,

	BRAND_BACKGROUND_1,
	BRAND_FOREGROUND_1,
	BRAND_STROKE_1,

	BRAND_BACKGROUND_2,
	BRAND_FOREGROUND_2,
	BRAND_STROKE_2,

	NEUTRAL_FOREGROUND_2_BRAND, // How does this differ from "BRAND_FOREGROUND_2"? //

	NEUTRAL_FOREGROUND_3_BRAND,
	NEUTRAL_FOREGROUND_DISABLED,
	BRAND_FOREGROUND_LINK,
	BRAND_FOREGROUND_INVERTED,
	NEUTRAL_BACKGROUND_INVERTED,
	SUBTLE_BACKGROUND,
	BRAND_BACKGROUND_INVERTED,
	NEUTRAL_CARD_BACKGROUND,
	NEUTRAL_STROKE_ACCESSIBLE,
	NEUTRAL_STROKE_SUBTLE,
	COMPOUND_BRAND_STROKE,
	NEUTRAL_STROKE_DISABLED,
	BLUE_BACKGROUND,
	BLUE_FOREGROUND,
	BLUE_BORDER,
	RED_BACKGROUND,
	RED_FOREGROUND,
	RED_BORDER,
	GREEN_BACKGROUND,
	GREEN_FOREGROUND,
	GREEN_BORDER,
	DARK_ORANGE_BACKGROUND,
	DARK_ORANGE_FOREGROUND,
	DARK_ORANGE_BORDER,
	YELLOW_BACKGROUND,
	YELLOW_FOREGROUND,
	YELLOW_BORDER,
	BERRY_BACKGROUND,
	BERRY_FOREGROUND,
	BERRY_BORDER,
	LIGHT_GREEN_BACKGROUND,
	LIGHT_GREEN_FOREGROUND,
	LIGHT_GREEN_BORDER,
	MARIGOLD_BACKGROUND,
	MARIGOLD_FOREGROUND,
	MARIGOLD_BORDER,
	SUCCESS_BACKGROUND,
	SUCCESS_FOREGROUND,
	SUCCESS_BORDER,
	WARNING_BACKGROUND,
	WARNING_FOREGROUND,
	WARNING_BORDER,
	DANGER_BACKGROUND,
	DANGER_FOREGROUND,
	DANGER_BORDER }

GI_Color :: [4]Color

GI_Theme :: [len(GI_Theme_Key)]GI_Color

GI_Icon :: enum u8 {
	None = 0,
	Fit,
	Eye,
	Ban,
	Add,
	Save,
	Tag,
	Sort,
	Apps,
	Wand,
	Redo,
	Undo,
	Text,
	Tabs,
	Star,
	Send,
	Help,
	Play,
	More,
	Menu,
	Lock,
	Link,
	Like,
	Info,
	Flag,
	Edit,
	Chat,
	Sync,
	Globe,
	Pin_0,
	Pin_1,
	Share,
	Retry,
	Pause,
	Notes,
	Image,
	Error,
	Close,
	Arrow,
	Images,
	Person,
	Delete,
	Remove,
	Search,
	Filter,
	Upload,
	Expand,
	Camera,
	Accept,
	Zoom_In,
	Video_1,
	Video_0,
	Toolbox,
	Sticker,
	Restore,
	Options,
	New_Tab,
	Mention,
	Gallery,
	Friends,
	Content,
	Compose,
	Chevron,
	Audio_3,
	Audio_2,
	Audio_1,
	Audio_0,
	Archive,
	Zoom_Out,
	Settings,
	Minimize,
	Maximize,
	Location,
	Download,
	Contacts,
	Calendar,
	Bookmark,
	Add_Page,
	Lightning,
	Font_Size,
	Emoji_Sad,
	Clipboard,
	Whiteboard,
	New_Window,
	Font_Color,
	Attachment,
	File_Error,
	Emoji_Happy,
	Notifications_1,
	Notifications_0 }

COLOR_NEUTRAL_FOREGROUND_1_LIGHT :: 0x242424ff
COLOR_NEUTRAL_FOREGROUND_2_NORMAL_LIGHT :: 0x424242ff
COLOR_NEUTRAL_FOREGROUND_2_HOVER_LIGHT :: 0x242424ff
COLOR_NEUTRAL_FOREGROUND_2_PRESSED_LIGHT :: 0x242424ff
COLOR_NEUTRAL_FOREGROUND_2_SELECTED_LIGHT :: 0x242424ff
COLOR_NEUTRAL_FOREGROUND_2_BRAND_NORMAL_LIGHT :: 0x424242ff
COLOR_NEUTRAL_FOREGROUND_2_BRAND_HOVER_LIGHT :: 0x0f6cbdff
COLOR_NEUTRAL_FOREGROUND_2_BRAND_PRESSED_LIGHT :: 0x115ea3ff
COLOR_NEUTRAL_FOREGROUND_2_BRAND_SELECTED_LIGHT :: 0x0f6cbdff
COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT :: 0xffffffff
COLOR_NEUTRAL_BACKGROUND_1_HOVER_LIGHT :: 0xf5f5f5ff
COLOR_NEUTRAL_BACKGROUND_1_PRESSED_LIGHT :: 0xe0e0e0ff
COLOR_NEUTRAL_BACKGROUND_1_SELECTED_LIGHT :: 0xebebebff
COLOR_NEUTRAL_BACKGROUND_2_NORMAL_LIGHT :: 0xfafafaff
COLOR_NEUTRAL_BACKGROUND_2_HOVER_LIGHT :: 0xf0f0f0ff
COLOR_NEUTRAL_BACKGROUND_2_PRESSED_LIGHT :: 0xdbdbdbff
COLOR_NEUTRAL_BACKGROUND_2_SELECTED_LIGHT :: 0xe6e6e6ff
COLOR_NEUTRAL_BACKGROUND_3_NORMAL_LIGHT :: 0xf5f5f5ff
COLOR_NEUTRAL_BACKGROUND_3_HOVER_LIGHT :: 0xebebebff
COLOR_NEUTRAL_BACKGROUND_3_PRESSED_LIGHT :: 0xd6d6d6ff
COLOR_NEUTRAL_BACKGROUND_3_SELECTED_LIGHT :: 0xe0e0e0ff
COLOR_NEUTRAL_FOREGROUND_DISABLED_LIGHT :: 0xbdbdbdff
COLOR_NEUTRAL_BACKGROUND_4_NORMAL_LIGHT :: 0xf0f0f0ff
COLOR_NEUTRAL_BACKGROUND_4_HOVER_LIGHT :: 0xfafafaff
COLOR_NEUTRAL_BACKGROUND_4_PRESSED_LIGHT :: 0xf5f5f5ff
COLOR_NEUTRAL_BACKGROUND_4_SELECTED_LIGHT :: 0xffffffff
COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT :: 0xd1d1d1ff
COLOR_NEUTRAL_STROKE_1_HOVER_LIGHT :: 0xc7c7c7ff
COLOR_NEUTRAL_STROKE_1_PRESSED_LIGHT :: 0xb3b3b3ff
COLOR_NEUTRAL_STROKE_1_SELECTED_LIGHT :: 0xbdbdbdff
COLOR_NEUTRAL_STROKE_2_LIGHT :: 0xe0e0e0ff
COLOR_NEUTRAL_STROKE_3_LIGHT :: 0xf0f0f0ff
COLOR_NEUTRAL_STROKE_4_NORMAL_LIGHT :: 0xebebebff
COLOR_NEUTRAL_STROKE_4_HOVER_LIGHT :: 0xe0e0e0ff
COLOR_NEUTRAL_STROKE_4_PRESSED_LIGHT :: 0xd6d6d6ff
COLOR_NEUTRAL_STROKE_4_SELECTED_LIGHT :: 0xebebebff
COLOR_BRAND_STROKE_1_NORMAL_LIGHT :: 0x0f6cbdff
COLOR_BRAND_STROKE_1_HOVER_LIGHT :: 0x0f6cbdff
COLOR_BRAND_STROKE_1_PRESSED_LIGHT :: 0x0f6cbdff
COLOR_BRAND_STROKE_1_SELECTED_LIGHT :: 0x0f6cbdff
COLOR_GREEN_BACKGROUND_VARIANT_1_LIGHT :: 0xf1faf1ff
COLOR_GREEN_BACKGROUND_VARIANT_2_LIGHT :: 0x9fd89fff
COLOR_GREEN_BACKGROUND_VARIANT_3_LIGHT :: 0x107c10ff
COLOR_GREEN_BACKGROUND_VARIANT_4_LIGHT :: 0x107c10ff
COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK :: 0x292929ff
COLOR_NEUTRAL_STROKE_1_HOVER_DARK :: 0x757575ff

GI_FONT_SIZE_CAPTION_2 ::   10
GI_FONT_SIZE_CAPTION_1 ::   12
GI_FONT_SIZE_BODY_1 ::      14
GI_FONT_SIZE_BODY_2 ::      16
GI_FONT_SIZE_SUBTITLE_2 ::  16
GI_FONT_SIZE_SUBTITLE_1 ::  20
GI_FONT_SIZE_TITLE_3 ::     24
GI_FONT_SIZE_TITLE_2 ::     28
GI_FONT_SIZE_TITLE_1 ::     32
GI_FONT_SIZE_LARGE_TITLE :: 40
GI_FONT_SIZE_DISPLAY ::     68

GI_RADIUS_NONE    :: 0
GI_RADIUS_SMALL   :: 2
GI_RADIUS_MEDIUM  :: 4
GI_RADIUS_LARGE   :: 6
GI_RADIUS_XLARGE  :: 8
GI_RADIUS_XLARGE2 :: 12
GI_RADIUS_XLARGE3 :: 16
GI_RADIUS_XLARGE4 :: 24
GI_RADIUS_XLARGE5 :: 32
GI_RADIUS_XLARGE6 :: 40

GI_STROKE_THIN     :: 1
GI_STROKE_THICK    :: 2
GI_STROKE_THICKER  :: 3
GI_STROKE_THICKEST :: 4

GI_SPACING_NONE :: 0
GI_SPACING_XXS  :: 2
GI_SPACING_XS   :: 4
GI_SPACING_S    :: 8
GI_SPACING_M    :: 12
GI_SPACING_L    :: 16
GI_SPACING_XL   :: 20
GI_SPACING_XXL  :: 24
GI_SPACING_XXXL :: 32

GI_Appearance :: enum {
	DEFAULT,
	PRIMARY,
	OUTLINE,
	SUBTLE,
	TRANSPARENT }

GI_BUTTON_SIZE_SMALL:  [2]f32 : { 64, 24 }
GI_BUTTON_SIZE_MEDIUM: [2]f32 : { 96, 32 }
GI_BUTTON_SIZE_LARGE:  [2]f32 : { 96, 40 }
GI_ICON_SIZE:          [2]f32 : { 24, 24 }
GI_AVATAR_SIZE:        [2]f32 : { 32, 32 }
GI_BADGE_SIZE_S:       [2]f32 : { 10, 10 }
GI_BADGE_SIZE_M:       [2]f32 : { 16, 16 }
GI_BADGE_SIZE_L:       [2]f32 : { 20, 20 }

GI_Size :: enum {
	XXS,
	XS,
	S,
	M,
	L,
	XL,
	XXL,
	XXXL }

gi_init :: proc() {
	using GI_Theme_Key
	using GI_Variant

	gi_theme_ms_light = new(GI_Theme)
	gi_theme_ms_dark = new(GI_Theme)
	gi_theme_ms_light^ = {
		NEUTRAL_FOREGROUND_1 = {
			NORMAL   = COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
			HOVER    = COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
			PRESSED  = COLOR_NEUTRAL_FOREGROUND_1_LIGHT,
			SELECTED = COLOR_NEUTRAL_FOREGROUND_1_LIGHT },
		NEUTRAL_FOREGROUND_2 = {
			NORMAL   = COLOR_NEUTRAL_FOREGROUND_2_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_FOREGROUND_2_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_FOREGROUND_2_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_FOREGROUND_2_SELECTED_LIGHT },
		NEUTRAL_FOREGROUND_2_BRAND = {
			NORMAL   = COLOR_NEUTRAL_FOREGROUND_2_BRAND_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_FOREGROUND_2_BRAND_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_FOREGROUND_2_BRAND_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_FOREGROUND_2_BRAND_SELECTED_LIGHT },
		NEUTRAL_FOREGROUND_3 = {
			NORMAL   = 0x616161ff,
			HOVER    = 0x424242ff,
			PRESSED  = 0x424242ff,
			SELECTED = 0x424242ff },
		NEUTRAL_FOREGROUND_3_BRAND = {
			NORMAL   = 0x616161ff,
			HOVER    = 0x0f6cbdff,
			PRESSED  = 0x115ea3ff,
			SELECTED = 0x0f6cbdff },
		NEUTRAL_FOREGROUND_4 = {
			NORMAL   = 0x707070ff,
			HOVER    = 0x707070ff,
			PRESSED  = 0x707070ff,
			SELECTED = 0x707070ff },
		NEUTRAL_FOREGROUND_DISABLED = {
			COLOR_NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			COLOR_NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			COLOR_NEUTRAL_FOREGROUND_DISABLED_LIGHT,
			COLOR_NEUTRAL_FOREGROUND_DISABLED_LIGHT },
		BRAND_FOREGROUND_LINK = {
			NORMAL   = 0x115ea3ff,
			HOVER    = 0x0f548cff,
			PRESSED  = 0x0c3b5eff,
			SELECTED = 0x115ea3ff },
		BRAND_FOREGROUND_1 = {
			NORMAL   = 0x0f6cbdff,
			HOVER    = 0x0f6cbdff,
			PRESSED  = 0x0f6cbdff,
			SELECTED = 0x0f6cbdff },
		BRAND_FOREGROUND_2 = {
			NORMAL   = 0x115ea3ff,
			HOVER    = 0x0f548cff,
			PRESSED  = 0x0a2e4aff,
			SELECTED = 0x0a2e4aff },
		BRAND_FOREGROUND_INVERTED = {
			NORMAL   = 0x479ef5ff,
			HOVER    = 0x62abf5ff,
			PRESSED  = 0x479ef5ff,
			SELECTED = 0x479ef5ff },
		NEUTRAL_BACKGROUND_1 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_BACKGROUND_1_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_BACKGROUND_1_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_BACKGROUND_1_SELECTED_LIGHT },
		NEUTRAL_BACKGROUND_2 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_2_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_BACKGROUND_2_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_BACKGROUND_2_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_BACKGROUND_2_SELECTED_LIGHT },
		NEUTRAL_BACKGROUND_3 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_3_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_BACKGROUND_3_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_BACKGROUND_3_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_BACKGROUND_3_SELECTED_LIGHT },
		NEUTRAL_BACKGROUND_4 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_4_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_BACKGROUND_4_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_BACKGROUND_4_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_BACKGROUND_4_SELECTED_LIGHT },
		NEUTRAL_BACKGROUND_INVERTED = {
			NORMAL   = 0x292929ff,
			HOVER    = 0x3d3d3dff,
			PRESSED  = 0x1f1f1fff,
			SELECTED = 0x383838ff },
		SUBTLE_BACKGROUND = {
			NORMAL   = 0x00000000,
			HOVER    = 0xf5f5f5ff,
			PRESSED  = 0xe0e0e0ff,
			SELECTED = 0xebebebff },
		BRAND_BACKGROUND_1 = {
			NORMAL   = 0x0f6cbdff,
			HOVER    = 0x115ea3ff,
			PRESSED  = 0x0c3b5eff,
			SELECTED = 0x0f548cff },
		BRAND_BACKGROUND_2 = {
			NORMAL   = 0xebf3fcff,
			HOVER    = 0xcfe4faff,
			PRESSED  = 0x96c6faff,
			SELECTED = 0x96c6faff },
		BRAND_BACKGROUND_INVERTED = {
			NORMAL   = 0xffffffff,
			HOVER    = 0xebf3fcff,
			PRESSED  = 0xb4d6faff,
			SELECTED = 0xcfe4faff },
		NEUTRAL_CARD_BACKGROUND = {
			NORMAL   = 0xfafafaff,
			HOVER    = 0xffffffff,
			PRESSED  = 0xf5f5f5ff,
			SELECTED = 0xebebebff },
		NEUTRAL_STROKE_ACCESSIBLE = {
			NORMAL   = 0x616161ff,
			HOVER    = 0x575757ff,
			PRESSED  = 0x4d4d4dff,
			SELECTED = 0x0f6cbdff },
		NEUTRAL_STROKE_1 = {
			NORMAL   = COLOR_NEUTRAL_STROKE_1_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_STROKE_1_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_STROKE_1_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_STROKE_1_SELECTED_LIGHT },
		NEUTRAL_STROKE_2 = {
			NORMAL   = COLOR_NEUTRAL_STROKE_2_LIGHT,
			HOVER    = COLOR_NEUTRAL_STROKE_2_LIGHT,
			PRESSED  = COLOR_NEUTRAL_STROKE_2_LIGHT,
			SELECTED = COLOR_NEUTRAL_STROKE_2_LIGHT },
		NEUTRAL_STROKE_3 = {
			NORMAL   = COLOR_NEUTRAL_STROKE_3_LIGHT,
			HOVER    = COLOR_NEUTRAL_STROKE_3_LIGHT,
			PRESSED  = COLOR_NEUTRAL_STROKE_3_LIGHT,
			SELECTED = COLOR_NEUTRAL_STROKE_3_LIGHT },
		NEUTRAL_STROKE_4 = {
			NORMAL   = COLOR_NEUTRAL_STROKE_4_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_STROKE_4_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_STROKE_4_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_STROKE_4_SELECTED_LIGHT },
		NEUTRAL_STROKE_SUBTLE = {
			NORMAL   = 0xe0e0e0ff,
			HOVER    = 0xe0e0e0ff,
			PRESSED  = 0xe0e0e0ff,
			SELECTED = 0xe0e0e0ff },
		BRAND_STROKE_1 = {
			NORMAL   = COLOR_BRAND_STROKE_1_NORMAL_LIGHT,
			HOVER    = COLOR_BRAND_STROKE_1_HOVER_LIGHT,
			PRESSED  = COLOR_BRAND_STROKE_1_PRESSED_LIGHT,
			SELECTED = COLOR_BRAND_STROKE_1_SELECTED_LIGHT },
		BRAND_STROKE_2 = {
			NORMAL   = 0xb4d6faff,
			HOVER    = 0x77b7f7ff,
			PRESSED  = 0x0f6cbdff,
			SELECTED = 0x0f6cbdff },
		COMPOUND_BRAND_STROKE = {
			NORMAL   = 0x0f6cbdff,
			HOVER    = 0x115ea3ff,
			PRESSED  = 0x0f548cff,
			SELECTED = 0x115ea3ff },
		NEUTRAL_STROKE_DISABLED = {
			NORMAL   = 0xe0e0e0ff,
			HOVER    = 0xe0e0e0ff,
			PRESSED  = 0xe0e0e0ff,
			SELECTED = 0xe0e0e0ff },
		BLUE_BACKGROUND = {
			NORMAL   = 0xebf3fcff,
			HOVER    = 0xcfe4faff,
			PRESSED  = 0x0f6cbdff,
			SELECTED = 0x0f6cbdff },
		BLUE_FOREGROUND = {
			NORMAL   = 0x115ea3ff,
			HOVER    = 0x0f548cff,
			PRESSED  = 0x0f6cbdff,
			SELECTED = 0x0f6cbdff },
		BLUE_BORDER = {
			NORMAL   = 0xb4d6faff,
			HOVER    = 0x0f6cbdff,
			PRESSED  = 0x0f6cbdff,
			SELECTED = 0x0f6cbdff },
		RED_BACKGROUND = {
			VARIANT_1 = 0xfdf6f6ff,
			VARIANT_2 = 0xf1bbbcff,
			VARIANT_3 = 0xd13438ff,
			VARIANT_4 = 0xd13438ff },
		RED_FOREGROUND = {
			VARIANT_1 = 0xbc2f32ff,
			VARIANT_2 = 0x751d1fff,
			VARIANT_3 = 0xd13438ff,
			VARIANT_4 = 0xd13438ff },
		RED_BORDER = {
			VARIANT_1 = 0xf1bbbcff,
			VARIANT_2 = 0xd13438ff,
			VARIANT_3 = 0xd13438ff,
			VARIANT_4 = 0xd13438ff },
		GREEN_BACKGROUND = {
			VARIANT_1 = COLOR_GREEN_BACKGROUND_VARIANT_1_LIGHT,
			VARIANT_2 = COLOR_GREEN_BACKGROUND_VARIANT_2_LIGHT,
			VARIANT_3 = COLOR_GREEN_BACKGROUND_VARIANT_3_LIGHT,
			VARIANT_4 = COLOR_GREEN_BACKGROUND_VARIANT_4_LIGHT },
		GREEN_FOREGROUND = {
			VARIANT_1 = 0x0e700eff,
			VARIANT_2 = 0x094509ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		GREEN_BORDER = {
			VARIANT_1 = 0x9fd89fff,
			VARIANT_2 = 0x107c10ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		DARK_ORANGE_BACKGROUND = {
			VARIANT_1 = 0xfdf6f3ff,
			VARIANT_2 = 0xf4bfabff,
			VARIANT_3 = 0xda3b01ff,
			VARIANT_4 = 0xda3b01ff },
		DARK_ORANGE_FOREGROUND = {
			VARIANT_1 = 0xc43501ff,
			VARIANT_2 = 0x7a2101ff,
			VARIANT_3 = 0xda3b01ff,
			VARIANT_4 = 0xda3b01ff },
		DARK_ORANGE_BORDER = {
			VARIANT_1 = 0xf4bfabff,
			VARIANT_2 = 0xda3b01ff,
			VARIANT_3 = 0xda3b01ff,
			VARIANT_4 = 0xda3b01ff },
		YELLOW_BACKGROUND = {
			VARIANT_1 = 0xfffef5ff,
			VARIANT_2 = 0xfef7b2ff,
			VARIANT_3 = 0xfde300ff,
			VARIANT_4 = 0xfde300ff },
		YELLOW_FOREGROUND = {
			VARIANT_1 = 0x817400ff,
			VARIANT_2 = 0x817400ff,
			VARIANT_3 = 0xfde300ff,
			VARIANT_4 = 0xfde300ff },
		YELLOW_BORDER = {
			VARIANT_1 = 0xfef7b2ff,
			VARIANT_2 = 0xfde300ff,
			VARIANT_3 = 0xfde300ff,
			VARIANT_4 = 0xfde300ff },
		BERRY_BACKGROUND = {
			VARIANT_1 = 0xfdf5fcff,
			VARIANT_2 = 0xedbbe7ff,
			VARIANT_3 = 0xc239b3ff,
			VARIANT_4 = 0xc239b3ff },
		BERRY_FOREGROUND = {
			VARIANT_1 = 0xaf33a1ff,
			VARIANT_2 = 0x6d2064ff,
			VARIANT_3 = 0xc239b3ff,
			VARIANT_4 = 0xc239b3ff },
		BERRY_BORDER = {
			VARIANT_1 = 0xedbbe7ff,
			VARIANT_2 = 0xc239b3ff,
			VARIANT_3 = 0xc239b3ff,
			VARIANT_4 = 0xc239b3ff },
		LIGHT_GREEN_BACKGROUND = {
			VARIANT_1 = 0xf2fbf2ff,
			VARIANT_2 = 0xa7e3a5ff,
			VARIANT_3 = 0x13a10eff,
			VARIANT_4 = 0x13a10eff },
		LIGHT_GREEN_FOREGROUND = {
			VARIANT_1 = 0x11910dff,
			VARIANT_2 = 0x0b5a08ff,
			VARIANT_3 = 0x13a10eff,
			VARIANT_4 = 0x13a10eff },
		LIGHT_GREEN_BORDER = {
			VARIANT_1 = 0xa7e3a5ff,
			VARIANT_2 = 0x13a10eff,
			VARIANT_3 = 0x13a10eff,
			VARIANT_4 = 0x13a10eff },
		MARIGOLD_BACKGROUND = {
			VARIANT_1 = 0xfefbf4ff,
			VARIANT_2 = 0xf9e2aeff,
			VARIANT_3 = 0xeaa300ff,
			VARIANT_4 = 0xeaa300ff },
		MARIGOLD_FOREGROUND = {
			VARIANT_1 = 0xd39300ff,
			VARIANT_2 = 0x835b00ff,
			VARIANT_3 = 0xeaa300ff,
			VARIANT_4 = 0xeaa300ff },
		MARIGOLD_BORDER = {
			VARIANT_1 = 0xf9e2aeff,
			VARIANT_2 = 0xeaa300ff,
			VARIANT_3 = 0xeaa300ff,
			VARIANT_4 = 0xeaa300ff },
		SUCCESS_BACKGROUND = {
			VARIANT_1 = 0xf1faf1ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		SUCCESS_FOREGROUND = {
			VARIANT_1 = 0x0e700eff,
			VARIANT_2 = 0x094509ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		SUCCESS_BORDER = {
			VARIANT_1 = 0x9fd89fff,
			VARIANT_2 = 0x107c10ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		WARNING_BACKGROUND = {
			VARIANT_1 = 0xfff9f5ff,
			VARIANT_2 = 0xfdcfb4ff,
			VARIANT_3 = 0xf7630cff,
			VARIANT_4 = 0xf7630cff },
		WARNING_FOREGROUND = {
			VARIANT_1 = 0xbc4b09ff,
			VARIANT_2 = 0x8a3707ff,
			VARIANT_3 = 0xbc4b09ff,
			VARIANT_4 = 0xbc4b09ff },
		WARNING_BORDER = {
			VARIANT_1 = 0xfdcfb4ff,
			VARIANT_2 = 0xbc4b09ff,
			VARIANT_3 = 0xbc4b09ff,
			VARIANT_4 = 0xbc4b09ff },
		DANGER_BACKGROUND = {
			VARIANT_1 = 0xfdf3f4ff,
			VARIANT_2 = 0xeeacb2ff,
			VARIANT_3 = 0xc50f1fff,
			VARIANT_4 = 0xc50f1fff },
		DANGER_FOREGROUND = {
			VARIANT_1 = 0xb10e1cff,
			VARIANT_2 = 0x6e0811ff,
			VARIANT_3 = 0xc50f1fff,
			VARIANT_4 = 0xc50f1fff },
		DANGER_BORDER = {
			VARIANT_1 = 0xeeacb2ff,
			VARIANT_2 = 0xc50f1fff,
			VARIANT_3 = 0xc50f1fff,
			VARIANT_4 = 0xc50f1fff } }

	gi_theme_ms_dark^ = {
		NEUTRAL_FOREGROUND_1 = {
			NORMAL   = 0xffffffff,
			HOVER    = 0xffffffff,
			PRESSED  = 0xffffffff,
			SELECTED = 0xffffffff },
		NEUTRAL_FOREGROUND_2 = {
			NORMAL   = 0xd6d6d6ff,
			HOVER    = 0xffffffff,
			PRESSED  = 0xffffffff,
			SELECTED = 0xffffffff },
		NEUTRAL_FOREGROUND_2_BRAND = {
			NORMAL   = 0xd6d6d6ff,
			HOVER    = 0x479ef5ff,
			PRESSED  = 0x2886deff,
			SELECTED = 0x479ef5ff },
		NEUTRAL_FOREGROUND_3 = {
			NORMAL   = 0xadadadff,
			HOVER    = 0xd6d6d6ff,
			PRESSED  = 0xd6d6d6ff,
			SELECTED = 0xd6d6d6ff },
		NEUTRAL_FOREGROUND_3_BRAND = {
			NORMAL   = 0xadadadff,
			HOVER    = 0x479ef5ff,
			PRESSED  = 0x2886deff,
			SELECTED = 0x479ef5ff },
		NEUTRAL_FOREGROUND_4 = {
			NORMAL   = 0x999999ff,
			HOVER    = 0x999999ff,
			PRESSED  = 0x999999ff,
			SELECTED = 0x999999ff },
		NEUTRAL_FOREGROUND_DISABLED = {
			0x5c5c5cff,
			0x5c5c5cff,
			0x5c5c5cff,
			0x5c5c5cff },
		BRAND_FOREGROUND_LINK = {
			NORMAL   = 0x479ef5ff,
			HOVER    = 0x62abf5ff,
			PRESSED  = 0x2886deff,
			SELECTED = 0x479ef5ff },
		BRAND_FOREGROUND_1 = {
			NORMAL   = 0x479ef5ff,
			HOVER    = 0x479ef5ff,
			PRESSED  = 0x479ef5ff,
			SELECTED = 0x479ef5ff },
		BRAND_FOREGROUND_2 = {
			NORMAL   = 0x62abf5ff,
			HOVER    = 0x96c6faff,
			PRESSED  = 0xebf3fcff,
			SELECTED = 0xebf3fcff },
		BRAND_FOREGROUND_INVERTED = {
			NORMAL   = 0x0f6cbdff,
			HOVER    = 0x115ea3ff,
			PRESSED  = 0x0f548cff,
			SELECTED = 0x0f548cff },
		NEUTRAL_BACKGROUND_1 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK,
			HOVER    = 0x3d3d3dff,
			PRESSED  = 0x1f1f1fff,
			SELECTED = 0x383838ff },
		NEUTRAL_BACKGROUND_2 = {
			NORMAL   = 0x1f1f1fff,
			HOVER    = 0x333333ff,
			PRESSED  = 0x141414ff,
			SELECTED = 0x2e2e2eff },
		NEUTRAL_BACKGROUND_3 = {
			NORMAL   = 0x141414ff,
			HOVER    = 0x292929ff,
			PRESSED  = 0x0a0a0aff,
			SELECTED = 0x242424ff },
		NEUTRAL_BACKGROUND_4 = {
			NORMAL   = 0x0a0a0aff,
			HOVER    = 0x1f1f1fff,
			PRESSED  = 0x000000ff,
			SELECTED = 0x1a1a1aff },
		NEUTRAL_BACKGROUND_INVERTED = {
			NORMAL   = 0xffffffff,
			HOVER    = 0xf5f5f5ff,
			PRESSED  = 0xe0e0e0ff,
			SELECTED = 0xebebebff },
		SUBTLE_BACKGROUND = {
			NORMAL   = 0x00000000,
			HOVER    = 0x383838ff,
			PRESSED  = 0x2e2e2eff,
			SELECTED = 0x333333ff },
		BRAND_BACKGROUND_1 = {
			NORMAL   = 0x115ea3ff,
			HOVER    = 0x0f6cbdff,
			PRESSED  = 0x0c3b5eff,
			SELECTED = 0x0f548cff },
		BRAND_BACKGROUND_2 = {
			NORMAL   = 0x082338ff,
			HOVER    = 0x0c3b5eff,
			PRESSED  = 0x061724ff,
			SELECTED = 0x061724ff },
		BRAND_BACKGROUND_INVERTED = {
			NORMAL   = 0xffffffff,
			HOVER    = 0xebf3fcff,
			PRESSED  = 0xb4d6faff,
			SELECTED = 0xcfe4faff },
		NEUTRAL_CARD_BACKGROUND = {
			NORMAL   = 0x333333ff,
			HOVER    = 0x3d3d3dff,
			PRESSED  = 0x2e2e2eff,
			SELECTED = 0x383838ff },
		NEUTRAL_STROKE_ACCESSIBLE = {
			NORMAL   = 0xadadadff,
			HOVER    = 0xbdbdbdff,
			PRESSED  = 0xb3b3b3ff,
			SELECTED = 0x479ef5ff },
		NEUTRAL_STROKE_1 = {
			NORMAL   = 0x666666ff,
			HOVER    = COLOR_NEUTRAL_STROKE_1_HOVER_DARK,
			PRESSED  = 0x6b6b6bff,
			SELECTED = 0x707070ff },
		NEUTRAL_STROKE_2 = {
			NORMAL   = 0x525252ff,
			HOVER    = 0x525252ff,
			PRESSED  = 0x525252ff,
			SELECTED = 0x525252ff },
		NEUTRAL_STROKE_3 = {
			NORMAL   = 0x3d3d3dff,
			HOVER    = 0x3d3d3dff,
			PRESSED  = 0x3d3d3dff,
			SELECTED = 0x3d3d3dff },
		NEUTRAL_STROKE_4 = {
			NORMAL   = 0x3d3d3dff,
			HOVER    = 0x2e2e2eff,
			PRESSED  = 0x242424ff,
			SELECTED = 0x3d3d3dff },
		NEUTRAL_STROKE_SUBTLE = {
			NORMAL   = 0x0a0a0aff,
			HOVER    = 0x0a0a0aff,
			PRESSED  = 0x0a0a0aff,
			SELECTED = 0x0a0a0aff },
		BRAND_STROKE_1 = {
			NORMAL   = 0x479ef5ff,
			HOVER    = 0x479ef5ff,
			PRESSED  = 0x479ef5ff,
			SELECTED = 0x479ef5ff },
		BRAND_STROKE_2 = {
			NORMAL   = 0x0e4775ff,
			HOVER    = 0x0e4775ff,
			PRESSED  = 0x0a2e4aff,
			SELECTED = 0x0a2e4aff },
		COMPOUND_BRAND_STROKE = {
			NORMAL   = 0x479ef5ff,
			HOVER    = 0x62abf5ff,
			PRESSED  = 0x2886deff,
			SELECTED = 0x2886deff },
		NEUTRAL_STROKE_DISABLED = {
			NORMAL   = 0x424242ff,
			HOVER    = 0x424242ff,
			PRESSED  = 0x424242ff,
			SELECTED = 0x424242ff },
		BLUE_BACKGROUND = {
			NORMAL   = 0x061724ff,
			HOVER    = 0x082338ff,
			PRESSED  = 0x0c3b5eff,
			SELECTED = 0x0c3b5eff },
		BLUE_FOREGROUND = {
			NORMAL   = 0x62abf5ff,
			HOVER    = 0x96c6faff,
			PRESSED  = 0x62abf5ff,
			SELECTED = 0x62abf5ff },
		BLUE_BORDER = {
			NORMAL   = 0x0e4775ff,
			HOVER    = 0x62abf5ff,
			PRESSED  = 0x62abf5ff,
			SELECTED = 0x62abf5ff },
		RED_BACKGROUND = {
			VARIANT_1 = 0x3f1011ff,
			VARIANT_2 = 0x751d1fff,
			VARIANT_3 = 0xd13438ff,
			VARIANT_4 = 0xd13438ff },
		RED_FOREGROUND = {
			VARIANT_1 = 0xe37d80ff,
			VARIANT_2 = 0xf1bbbcff,
			VARIANT_3 = 0xe37d80ff,
			VARIANT_4 = 0xe37d80ff },
		RED_BORDER = {
			VARIANT_1 = 0xd13438ff,
			VARIANT_2 = 0xe37d80ff,
			VARIANT_3 = 0xe37d80ff,
			VARIANT_4 = 0xe37d80ff },
		GREEN_BACKGROUND = {
			VARIANT_1 = 0x052505ff,
			VARIANT_2 = 0x094509ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		GREEN_FOREGROUND = {
			VARIANT_1 = 0x54b054ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x9fd89fff,
			VARIANT_4 = 0x9fd89fff },
		GREEN_BORDER = {
			VARIANT_1 = 0x107c10ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x9fd89fff,
			VARIANT_4 = 0x9fd89fff },
		DARK_ORANGE_BACKGROUND = {
			VARIANT_1 = 0x411200ff,
			VARIANT_2 = 0x7a2101ff,
			VARIANT_3 = 0xda3b01ff,
			VARIANT_4 = 0xda3b01ff },
		DARK_ORANGE_FOREGROUND = {
			VARIANT_1 = 0xe9835eff,
			VARIANT_2 = 0xf4bfabff,
			VARIANT_3 = 0xe9835eff,
			VARIANT_4 = 0xe9835eff },
		DARK_ORANGE_BORDER = {
			VARIANT_1 = 0xda3b01ff,
			VARIANT_2 = 0xe9835eff,
			VARIANT_3 = 0xe9835eff,
			VARIANT_4 = 0xe9835eff },
		YELLOW_BACKGROUND = {
			VARIANT_1 = 0x4c4400ff,
			VARIANT_2 = 0x817400ff,
			VARIANT_3 = 0xfde300ff,
			VARIANT_4 = 0xfde300ff },
		YELLOW_FOREGROUND = {
			VARIANT_1 = 0xfeee66ff,
			VARIANT_2 = 0xfef7b2ff,
			VARIANT_3 = 0xfdea3dff,
			VARIANT_4 = 0xfdea3dff },
		YELLOW_BORDER = {
			VARIANT_1 = 0xfde300ff,
			VARIANT_2 = 0xfdea3dff,
			VARIANT_3 = 0xfdea3dff,
			VARIANT_4 = 0xfdea3dff },
		BERRY_BACKGROUND = {
			VARIANT_1 = 0x3a1136ff,
			VARIANT_2 = 0x6d2064ff,
			VARIANT_3 = 0xc239b3ff,
			VARIANT_4 = 0xc239b3ff },
		BERRY_FOREGROUND = {
			VARIANT_1 = 0xda7ed0ff,
			VARIANT_2 = 0xedbbe7ff,
			VARIANT_3 = 0xd161c4ff,
			VARIANT_4 = 0xd161c4ff },
		BERRY_BORDER = {
			VARIANT_1 = 0xc239b3ff,
			VARIANT_2 = 0xd161c4ff,
			VARIANT_3 = 0xd161c4ff,
			VARIANT_4 = 0xd161c4ff },
		LIGHT_GREEN_BACKGROUND = {
			VARIANT_1 = 0x063004ff,
			VARIANT_2 = 0x0b5a08ff,
			VARIANT_3 = 0x13a10eff,
			VARIANT_4 = 0x13a10eff },
		LIGHT_GREEN_FOREGROUND = {
			VARIANT_1 = 0x5ec75aff,
			VARIANT_2 = 0xa7e3a5ff,
			VARIANT_3 = 0x3db838ff,
			VARIANT_4 = 0x3db838ff },
		LIGHT_GREEN_BORDER = {
			VARIANT_1 = 0x13a10eff,
			VARIANT_2 = 0x3db838ff,
			VARIANT_3 = 0x3db838ff,
			VARIANT_4 = 0x3db838ff },
		MARIGOLD_BACKGROUND = {
			VARIANT_1 = 0x463100ff,
			VARIANT_2 = 0x835b00ff,
			VARIANT_3 = 0xeaa300ff,
			VARIANT_4 = 0xeaa300ff },
		MARIGOLD_FOREGROUND = {
			VARIANT_1 = 0xf2c661ff,
			VARIANT_2 = 0xf9e2aeff,
			VARIANT_3 = 0xefb839ff,
			VARIANT_4 = 0xefb839ff },
		MARIGOLD_BORDER = {
			VARIANT_1 = 0xeaa300ff,
			VARIANT_2 = 0xefb839ff,
			VARIANT_3 = 0xefb839ff,
			VARIANT_4 = 0xefb839ff },
		SUCCESS_BACKGROUND = {
			VARIANT_1 = 0x052505ff,
			VARIANT_2 = 0x094509ff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
		SUCCESS_FOREGROUND = {
			VARIANT_1 = 0x54b054ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x9fd89fff,
			VARIANT_4 = 0x9fd89fff },
		SUCCESS_BORDER = {
			VARIANT_1 = 0x107c10ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x9fd89fff,
			VARIANT_4 = 0x9fd89fff },
		WARNING_BACKGROUND = {
			VARIANT_1 = 0x4a1e04ff,
			VARIANT_2 = 0x8a3707ff,
			VARIANT_3 = 0xf7630cff,
			VARIANT_4 = 0xf7630cff },
		WARNING_FOREGROUND = {
			VARIANT_1 = 0xfaa06bff,
			VARIANT_2 = 0xfdcfb4ff,
			VARIANT_3 = 0xf98845ff,
			VARIANT_4 = 0xf98845ff },
		WARNING_BORDER = {
			VARIANT_1 = 0xf7630cff,
			VARIANT_2 = 0xf98845ff,
			VARIANT_3 = 0xf98845ff,
			VARIANT_4 = 0xf98845ff },
		DANGER_BACKGROUND = {
			VARIANT_1 = 0x3b0509ff,
			VARIANT_2 = 0x6e0811ff,
			VARIANT_3 = 0xc50f1fff,
			VARIANT_4 = 0xc50f1fff },
		DANGER_FOREGROUND = {
			VARIANT_1 = 0xdc626dff,
			VARIANT_2 = 0xeeacb2ff,
			VARIANT_3 = 0xeeacb2ff,
			VARIANT_4 = 0xeeacb2ff },
		DANGER_BORDER = {
			VARIANT_1 = 0xc50f1fff,
			VARIANT_2 = 0xdc626dff,
			VARIANT_3 = 0xdc626dff,
			VARIANT_4 = 0xdc626dff } }

	font_group_init(&engine.gi_manager.font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	font_group_init(&engine.gi_manager.icons_font_group,
		normal = default_font_config(name = "icons"),
		bold = default_font_config(name = "icons-bold"))
	gi_set_theme(gi_theme_ms_dark)

	engine.gi_manager.anim_transitions = make(map[runtime.Source_Code_Location]GI_Anim_Transition) }

gi_set_theme :: proc(theme: ^GI_Theme) {
	engine.gi_manager.theme = theme
	engine.gi_manager.text_style.color = gi_get_text_color()[0]
	fg_color := engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	engine.gi_manager.text_style = default_text_style(font_group = engine.gi_manager.font_group, color = fg_color, font_size = 8)
	engine.gi_manager.icons_text_style = default_text_style(font_group = engine.gi_manager.icons_font_group, color = fg_color, font_size = 24)
	background_color := gi_get_background_color()[0]
	set_clear_color(background_color)
	wnd_customize(background_color, COLOR_NEUTRAL_STROKE_1_HOVER_DARK)
	// wnd_customize(RED, RED)
}

gi_get_background_color :: proc() -> GI_Color {
	return engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_BACKGROUND_1] }

gi_get_text_color :: proc() -> GI_Color {
	return engine.gi_manager.theme[GI_Theme_Key.NEUTRAL_FOREGROUND_1] }

gi_theme_ms_light: ^GI_Theme
gi_theme_ms_dark: ^GI_Theme

// (TODO): The installer CLI procedure also runs a generator procedure, which creates a "generated.odin" file.
// (TODO): Arrange these in a 4xN table, where the empty trailing rows are filled with the value of the last filled row.
// Then GUI functions take a slice, so you can just give it a slice off this table.

// (TODO): Add "depth" stack in "GX_Manager". Depth should never be set manually.
gi_button :: proc(rect: Rect, text: string, icon: GI_Icon = .None) -> (actions: bit_set[GUI_Action]) {
	actions = gi_logic_button(rect)
	dr_button(rect, text, icon=icon)
	return actions }

@(deferred_none=gx_clip_pop)
gi_chevron :: proc(position: [2]f32, header: string, panel_size: [2]f32, location := #caller_location) -> (panel: Rect) {
	return gi_chevron_begin(position, header, panel_size, location) }

CHEVRON_ANIM_SPEED :: 6

gi_chevron_begin :: proc(position: [2]f32, header: string, panel_size: [2]f32, location := #caller_location) -> (panel: Rect) {
	rect: Rect = { position, GI_ICON_SIZE }
	gi_text_style_scope(engine.gi_manager.text_style)
	width := dr_text_line(header, position + { GI_ICON_SIZE.x / 2 + GI_SPACING_XS, 0 }, pivot={ .West })
	icon_rect: Rect = { position, GI_ICON_SIZE }
	button_rect := gi_rect_extend_variate(icon_rect, east=Interval(width + GI_SPACING_XS))
	t := gi_anim_transition([2]f32{ 0, 1 }, 1, CHEVRON_ANIM_SPEED, false, .PRESS in gi_logic_button(button_rect), location=location)
	dr_icon(.Chevron, position, angle = t * math.PI / 2)
	// dr_rect_outline(rect, RED)
	// dr_rect_outline(button_rect, RED)
	panel = { position + { - GI_ICON_SIZE.x / 2, - GI_ICON_SIZE.y / 2 } + { panel_size.x / 2, -panel_size.y / 2 }, panel_size }
	panel = gi_rect_margins_variate_r(panel, south=Ratio(t))
	// dr_rect_outline(panel, RED)
	clip: Clip = { rect = rect_sect(panel, gx_clip_get().rect) }
	gx_clip_push(clip)
	return panel }

Accordion :: struct {
	multiple: bool,
	collapsible: bool,
	position: [2]f32,
	locations: [dynamic]runtime.Source_Code_Location }

@(deferred_out=gi_accordion_end)
gi_accordion :: proc(position: [2]f32, multiple: bool=true, collapsible: bool=true) -> (accordion: ^Accordion) {
	return gi_accordion_begin(position, multiple=multiple, collapsible=collapsible) }

gi_accordion_begin :: proc(position: [2]f32, multiple: bool=true, collapsible: bool=true) -> (accordion: ^Accordion) {
	accordion = new(Accordion, context.temp_allocator)
	accordion^ = {
		multiple=multiple,
		collapsible=collapsible,
		position=position,
		locations=make([dynamic]runtime.Source_Code_Location, context.temp_allocator) }
	return accordion }

gi_accordion_end :: proc(accordion: ^Accordion) {
	if ! accordion.multiple {
		last_open_location: runtime.Source_Code_Location
		last_open_location_state: GI_Anim_Transition
		for location in accordion.locations {
			state := engine.gi_manager.anim_transitions[location] or_continue
			if state.direction == false {
				if last_open_location_state.action_time < state.action_time {
					last_open_location = location
					last_open_location_state = engine.gi_manager.anim_transitions[location] } } }
		if last_open_location != {} do for location in accordion.locations {
			state := engine.gi_manager.anim_transitions[location] or_continue
			if state.direction == false {
				if location != last_open_location do gi_anim_transition([2]f32{ 0, 1 }, 0, CHEVRON_ANIM_SPEED, true, true, location=location) } } }
	if ! accordion.collapsible {
		// Count how many are closed. If there are 0 closed, open the one with the most recent action. //
	}
}

@(deferred_none=gx_clip_pop)
gi_accordion_add :: proc(accordion: ^Accordion, header: string, panel_size: [2]f32, location := #caller_location) -> (panel_rect: Rect) {
	panel_rect = gi_chevron_begin(accordion.position, header, panel_size, location)
	accordion.position.y = rect_bottom(panel_rect) - GI_SPACING_L
	append(&accordion.locations, location)
	return panel_rect }

gi_measure_text :: proc(text: string, scale_factor: f32) -> (width: f32, space_count: int) {
	using style := gi_text_style_get()
	for symbol, i in text {
		font := font_group_select(font_group, style)
		if symbol == '_' {
			style.italic = ! style.italic; continue }
		if symbol == '*' {
			style.bold = ! style.bold; continue }
		symbol_delta: f32 = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
		if symbol == ' ' do symbol_delta *= spacing
		width += symbol_delta
		if symbol == ' ' do space_count += 1 }
	return width, space_count }

gi_measure_text_iterate :: proc(text: string, i: ^int, width: ^f32, space_count: ^int, scale_factor: f32) -> bool {
	using style := gi_text_style_get()
	if i^ >= len(text) do return false
	font := font_group_select(font_group, style)
	symbol: u8 = text[i^]
	if symbol == '_' || symbol == '*' {
		style.italic = ! style.italic
		style.bold = ! style.bold
		i^ += 1
		return true }
	symbol_delta: f32 = f32(font.advances[symbol] - font.bearings[symbol]) * scale_factor + tracking
	if symbol == ' ' do symbol_delta *= spacing
	width^ += symbol_delta
	if symbol == ' ' do space_count^ += 1
	i^ += 1
	return true }

gi_text_box_lines :: proc(rect: Rect, text: string, scale_factor: f32) -> []string {
	using style := gi_text_style_get()
	lines := make([dynamic]string, context.temp_allocator)
	line_start_i, prev_i, curr_i, prev_word_end_i, space_count: int
	width, width_acc: f32
	for {
		ok := gi_measure_text_iterate(text, &curr_i, &width, &space_count, scale_factor)
		if (width <= rect.size.x) && ok {
			if text[prev_i] == ' ' && (prev_i == 0 ? true : (text[prev_i - 1] != ' ')) {
				prev_word_end_i = prev_i
				width_acc = width - cast(f32)font_group.normal.advances[' '] * scale_factor + tracking }
			prev_i = curr_i
		} else {
			if (line_start_i == prev_word_end_i + 1) || !ok do prev_word_end_i = prev_i
			append(&lines, text[line_start_i:prev_word_end_i])
			if !ok do break
			i: int = 0
			for strings.is_space(cast(rune)text[prev_word_end_i + i]) do i += 1
			line_start_i = prev_word_end_i + i
			curr_i += i
			width -= width_acc } }
	shrink(&lines)
	return lines[:] }

gi_measure_text_box :: proc(text: string, width: f32) -> (total_height: f32) {
	using style := gi_text_style_get()
	scale_factor := font_size_to_font_scale(font_size, font_group.normal)
	height: f32 = cast(f32)font_group.normal.height * scale_factor
	line_distance: f32 = height * style.leading
	rect := make_rect(0, 0, width, 0)
	lines := gi_text_box_lines(rect, text, scale_factor)
	n: int = len(lines)
	total_height = height * f32(n) + cast(f32)max(0, n - 1) * line_distance
	return total_height }

// (TODO): Add these to the generator. //
gi_text_style_store :: proc() {
	// (TODO): Enabling these causes weird things to happen. //
	delete(engine.gi_manager.text_style_stack_store)
	engine.gi_manager.text_style_stack_store = clone_dynamic_array(engine.gi_manager.text_style_stack, engine.backing_allocator)
	}

gi_text_style_restore :: proc() {
	delete(engine.gi_manager.text_style_stack)
	engine.gi_manager.text_style_stack = clone_dynamic_array(engine.gi_manager.text_style_stack_store, engine.backing_allocator)
	}

@(deferred_none=gi_text_style_restore)
gi_text_style_checkpoint :: proc() {
	gi_text_style_store() }
