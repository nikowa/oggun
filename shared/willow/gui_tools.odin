#+feature using-stmt
package willow
import "base:runtime"
import "core:fmt"
import "core:time"
import "core:math"

TGUI_Manager :: struct {
	font_group: Font_Group,
	icons_font_group: Font_Group,
	text_style: Text_Style,
	icons_text_style: Text_Style,
	anim_transitions: map[runtime.Source_Code_Location]TGUI_Anim_Transition,
	// caption2_font_group: Font_Group,  // 10px
	// caption1_font_group: Font_Group,  // 12px
	// body1_font_group: Font_Group,     // 14px
	// body2_font_group: Font_Group,     // 16px
	// subtitle1_font_group: Font_Group, // 20px
	theme: ^TGUI_Theme }

TGUI_Variant :: enum {
	NORMAL = 0,
	HOVER,
	PRESSED,
	SELECTED,
	VARIANT_1 = 0,
	VARIANT_2,
	VARIANT_3,
	VARIANT_4 }

TGUI_Button_Shape :: enum {
	ROUNDED,
	CIRCULAR,
	SQUARE }

TGUI_Theme_Key :: enum {
	NEUTRAL_FOREGROUND_1 = 0,
	NEUTRAL_FOREGROUND_2,
	NEUTRAL_FOREGROUND_2_BRAND,
	NEUTRAL_FOREGROUND_3,
	NEUTRAL_FOREGROUND_3_BRAND,
	NEUTRAL_FOREGROUND_4,
	NEUTRAL_FOREGROUND_5,
	NEUTRAL_FOREGROUND_DISABLED,
	BRAND_FOREGROUND_LINK,
	NEUTRAL_FOREGROUND_2_LINK,
	BRAND_FOREGROUND_1,
	BRAND_FOREGROUND_2,
	BRAND_FOREGROUND_INVERTED,
	NEUTRAL_BACKGROUND_1,
	NEUTRAL_BACKGROUND_2,
	NEUTRAL_BACKGROUND_3,
	NEUTRAL_BACKGROUND_4,
	NEUTRAL_BACKGROUND_5,
	NEUTRAL_BACKGROUND_INVERTED,
	SUBTLE_BACKGROUND,
	BRAND_BACKGROUND,
	BRAND_BACKGROUND_2,
	BRAND_BACKGROUND_INVERTED,
	NEUTRAL_CARD_BACKGROUND,
	NEUTRAL_STROKE_ACCESSIBLE,
	NEUTRAL_STROKE_1,
	NEUTRAL_STROKE_2,
	NEUTRAL_STROKE_3,
	NEUTRAL_STROKE_4,
	NEUTRAL_STROKE_SUBTLE,
	BRAND_STROKE_1,
	BRAND_STROKE_2,
	COMPOUND_BRAND_STROKE,
	NEUTRAL_STROKE_DISABLED,
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

TGUI_Color :: [4]Color

TGUI_Theme :: [len(TGUI_Theme_Key)]TGUI_Color

TGUI_Icon :: enum u8 {
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
COLOR_NEUTRAL_BACKGROUND_5_NORMAL_LIGHT :: 0xebebebff
COLOR_NEUTRAL_BACKGROUND_5_HOVER_LIGHT :: 0xf5f5f5ff
COLOR_NEUTRAL_BACKGROUND_5_PRESSED_LIGHT :: 0xf0f0f0ff
COLOR_NEUTRAL_BACKGROUND_5_SELECTED_LIGHT :: 0xfafafaff
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
COLOR_NEUTRAL_BACKGROUND_1_NORMAL_DARK :: 0x292929ff

TGUI_FONT_SIZE_CAPTION_2 ::   10
TGUI_FONT_SIZE_CAPTION_1 ::   12
TGUI_FONT_SIZE_BODY_1 ::      14
TGUI_FONT_SIZE_BODY_2 ::      16
TGUI_FONT_SIZE_SUBTITLE_2 ::  16
TGUI_FONT_SIZE_SUBTITLE_1 ::  20
TGUI_FONT_SIZE_TITLE_3 ::     24
TGUI_FONT_SIZE_TITLE_2 ::     28
TGUI_FONT_SIZE_TITLE_1 ::     32
TGUI_FONT_SIZE_LARGE_TITLE :: 40
TGUI_FONT_SIZE_DISPLAY ::     68

TGUI_RADIUS_NONE    :: 0
TGUI_RADIUS_SMALL   :: 2
TGUI_RADIUS_MEDIUM  :: 4
TGUI_RADIUS_LARGE   :: 6
TGUI_RADIUS_XLARGE  :: 8
TGUI_RADIUS_XLARGE2 :: 12
TGUI_RADIUS_XLARGE3 :: 16
TGUI_RADIUS_XLARGE4 :: 24
TGUI_RADIUS_XLARGE5 :: 32
TGUI_RADIUS_XLARGE6 :: 40

TGUI_STROKE_THIN     :: 1
TGUI_STROKE_THICK    :: 2
TGUI_STROKE_THICKER  :: 3
TGUI_STROKE_THICKEST :: 4

TGUI_SPACING_NONE :: 0
TGUI_SPACING_XXS  :: 2
TGUI_SPACING_XS   :: 4
TGUI_SPACING_S    :: 8
TGUI_SPACING_M    :: 12
TGUI_SPACING_L    :: 16
TGUI_SPACING_XL   :: 20
TGUI_SPACING_XXL  :: 24
TGUI_SPACING_XXXL :: 32

TGUI_Appearance :: enum {
	DEFAULT,
	PRIMARY,
	OUTLINE,
	SUBTLE,
	TRANSPARENT }

TGUI_BUTTON_SIZE_SMALL:  [2]f32 : { 64, 24 }
TGUI_BUTTON_SIZE_MEDIUM: [2]f32 : { 96, 32 }
TGUI_BUTTON_SIZE_LARGE:  [2]f32 : { 96, 40 }
TGUI_ICON_SIZE:          [2]f32 : { 24, 24 }

tgui_manager_init :: proc() {
	using TGUI_Theme_Key
	using TGUI_Variant

	tgui_theme_ms_light = new(TGUI_Theme)
	tgui_theme_ms_dark = new(TGUI_Theme)
	tgui_theme_ms_light^ = {
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
		NEUTRAL_FOREGROUND_5 = {
			NORMAL   = 0x616161ff,
			HOVER    = 0x242424ff,
			PRESSED  = 0x242424ff,
			SELECTED = 0x242424ff },
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
		NEUTRAL_FOREGROUND_2_LINK = {
			NORMAL   = 0x424242ff,
			HOVER    = 0x242424ff,
			PRESSED  = 0x242424ff,
			SELECTED = 0x242424ff },
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
		NEUTRAL_BACKGROUND_5 = {
			NORMAL   = COLOR_NEUTRAL_BACKGROUND_5_NORMAL_LIGHT,
			HOVER    = COLOR_NEUTRAL_BACKGROUND_5_HOVER_LIGHT,
			PRESSED  = COLOR_NEUTRAL_BACKGROUND_5_PRESSED_LIGHT,
			SELECTED = COLOR_NEUTRAL_BACKGROUND_5_SELECTED_LIGHT },
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
		BRAND_BACKGROUND = {
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
			VARIANT_1 = 0xf1faf1ff,
			VARIANT_2 = 0x9fd89fff,
			VARIANT_3 = 0x107c10ff,
			VARIANT_4 = 0x107c10ff },
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

	tgui_theme_ms_dark^ = {
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
		NEUTRAL_FOREGROUND_5 = {
			NORMAL   = 0xadadadff,
			HOVER    = 0xffffffff,
			PRESSED  = 0xffffffff,
			SELECTED = 0xffffffff },
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
		NEUTRAL_FOREGROUND_2_LINK = {
			NORMAL   = 0xd6d6d6ff,
			HOVER    = 0xffffffff,
			PRESSED  = 0xffffffff,
			SELECTED = 0xffffffff },
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
		NEUTRAL_BACKGROUND_5 = {
			NORMAL   = 0x000000ff,
			HOVER    = 0x141414ff,
			PRESSED  = 0x050505ff,
			SELECTED = 0x0f0f0fff },
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
		BRAND_BACKGROUND = {
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
			HOVER    = 0x757575ff,
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

	font_group_init(&engine.tgui_manager.font_group,
		normal = default_font_config(name = "terminus"),
		bold = default_font_config(name = "terminus-bold"),
		italic = default_font_config(name = "terminus-italic"))
	font_group_init(&engine.tgui_manager.icons_font_group,
		normal = default_font_config(name = "icons"))
	tgui_set_theme(tgui_theme_ms_dark)

	engine.tgui_manager.anim_transitions = make(map[runtime.Source_Code_Location]TGUI_Anim_Transition) }

tgui_set_theme :: proc(theme: ^TGUI_Theme) {
	engine.tgui_manager.theme = theme
	engine.tgui_manager.text_style.color = theme[TGUI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	fg_color := engine.tgui_manager.theme[TGUI_Theme_Key.NEUTRAL_FOREGROUND_1][0]
	engine.tgui_manager.text_style = default_text_style(font_group = engine.tgui_manager.font_group, color = fg_color, font_size = 8)
	engine.tgui_manager.icons_text_style = default_text_style(font_group = engine.tgui_manager.icons_font_group, color = fg_color, font_size = 24)
	set_clear_color(theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_2][0]) }

tgui_theme_ms_light: ^TGUI_Theme
tgui_theme_ms_dark: ^TGUI_Theme

// (TODO): The installer CLI procedure also runs a generator procedure, which creates a "generated.odin" file.
// (TODO): Arrange these in a 4xN table, where the empty trailing rows are filled with the value of the last filled row.
// Then GUI functions take a slice, so you can just give it a slice off this table.

tgui_button :: proc(rect: Rect, args: ..any, shape: TGUI_Button_Shape = .ROUNDED, appearance: TGUI_Appearance = .DEFAULT, disabled: bool = false, icon: TGUI_Icon = .None, sep: string = "") -> (actions: bit_set[GUI_Action]) {
	actions = gui_button(rect, disabled)
	tgui_draw_button(rect, ..args, shape=shape, appearance=appearance, disabled=disabled, sep=sep, icon=icon)
	return actions }

// (TODO): Pack most of these params in a "Neon_Button_Config" struct. //
tgui_draw_button :: proc(rect: Rect, args: ..any, shape: TGUI_Button_Shape = .ROUNDED, appearance: TGUI_Appearance = .DEFAULT, disabled: bool = false, icon: TGUI_Icon = .None, sep: string = "") {
	rect := rect
	text := fmt.aprint(..args, sep = sep)
	rounding: f32 = 0.0
	switch shape {
	case .ROUNDED: rounding = TGUI_RADIUS_MEDIUM
	case .CIRCULAR: rounding = rect.size.y / 2
	case .SQUARE: rounding = 0.0 }
	hover: bool = rect_hovered(rect)
	press: bool = hover && input_query(.Mouse_Left, .DOWN)

	theme := engine.tgui_manager.theme
	tgui_fill_color: TGUI_Color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_2]
	stroke_neon_color: TGUI_Color = theme[TGUI_Theme_Key.NEUTRAL_STROKE_1]
	text_style: Text_Style = engine.tgui_manager.text_style
	#partial switch appearance {
	case .PRIMARY:
		tgui_fill_color = theme[TGUI_Theme_Key.BRAND_BACKGROUND]
		stroke_neon_color = tgui_fill_color
		text_style.color = WHITE
	case .OUTLINE:
		tgui_fill_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_1]
		// stroke_neon_color = theme[TGUI_Theme_Key.BRAND_STROKE_2]
	case .SUBTLE:
		tgui_fill_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_1]
	case .TRANSPARENT:
		tgui_fill_color = theme[TGUI_Theme_Key.NEUTRAL_FOREGROUND_2_BRAND]
	}

	state := disabled ? TGUI_Variant.NORMAL : press ? TGUI_Variant.PRESSED : hover ? TGUI_Variant.HOVER : TGUI_Variant.NORMAL
	fill_color: Color = tgui_fill_color[state]
	stroke_color: Color = stroke_neon_color[state]
	stroke: f32 = 1
	#partial switch appearance {
	case .OUTLINE:
		fill_color = tgui_fill_color[0]
	case .SUBTLE:
		stroke = 0
	case .TRANSPARENT:
		stroke = 0
		text_style.color = fill_color
		fill_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_1][0] }

	if disabled {
		stroke_color = theme[TGUI_Theme_Key.NEUTRAL_STROKE_1][0]
		text_style.color = theme[TGUI_Theme_Key.NEUTRAL_FOREGROUND_DISABLED][0]
		#partial switch appearance {
		case .DEFAULT, .OUTLINE:
			fill_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
		case .PRIMARY:
			fill_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_4][0]
			stroke_color = theme[TGUI_Theme_Key.NEUTRAL_BACKGROUND_4][0] }
		// if hover do set_cursor(.Disabled)
		hover = false
		press = false }

// case .PRIMARY
	draw_rect(rect, fill_color = fill_color, stroke_color = stroke_color, stroke = stroke, rounding = rounding, depth = 0.9)
	// if hover do set_cursor(.Hand)
	// tgui_draw_icon :: proc(icon: TGUI_Icon, position: [2]f32, depth: f32 = 0.0, angle: f32 = 0.0) {
	if icon != .None {
		icon_position := rect.position + { - rect.size.x / 2 + rect.size.y / 2, 0 }
		tgui_draw_icon(icon, icon_position)
		// draw_rect_outline(rect, RED)
		// DICK
		rect = rect_margins_variate(rect, west=Interval(TGUI_ICON_SIZE.y))
	}
	draw_text_box(text_style, rect, text, h_align = .CENTER, v_align = .CENTER, depth = 0.1)
}

tgui_draw_icon :: proc(icon: TGUI_Icon, position: [2]f32, depth: f32 = 0.0, angle: f32 = 0.0) {
	draw_text_symbol_rect(cast(u8)icon, { position, TGUI_ICON_SIZE }, depth, style = engine.tgui_manager.icons_text_style, angle = angle) }

TGUI_Anim_Transition :: struct {
	value: f32,
	action_time: time.Duration,
	action_value: f32,
	direction: bool }

tgui_anim_transition :: proc(range: [2]f32, initial_value: f32, speed: f32, initial_direction: bool, action: bool, location := #caller_location) -> (value: f32) {
	assert(range[1] > range[0])
	action := action
	state, ok := engine.tgui_manager.anim_transitions[location]
	time_now := time.stopwatch_duration(engine.stopwatch)
	if ! ok {
		action = true
		state = { value = initial_value, action_time = time_now, action_value = initial_value, direction = initial_direction } }
	if action {
		state.action_time = time_now
		state.action_value = state.value
		state.direction = ! state.direction }
	time_passed := time.duration_seconds(time_now - state.action_time)
	if state.direction {
		period: f32 = (1 / speed) * (range[1] - state.action_value) / (range[1] - range[0])
		state.value = math.lerp(state.action_value, range[1], f32(time_passed) / period) }
	else {
		period: f32 = (1 / speed) * (state.action_value - range[0]) / (range[1] - range[0])
		state.value = math.lerp(state.action_value, range[0], f32(time_passed) / period) }
	state.value = clamp(state.value, range[0], range[1])
	engine.tgui_manager.anim_transitions[location] = state
	// fmt.println(state.value)
	return state.value }

tgui_chevron :: proc(position: [2]f32, location := #caller_location) -> f32 {
	rect: Rect = { position, TGUI_ICON_SIZE }
	t := tgui_anim_transition([2]f32{ 0, 1 }, 0, 4, true, .PRESS in gui_button(rect), location=location)
	tgui_draw_icon(.Chevron, position, angle = t * math.PI / 2)
	return t }
