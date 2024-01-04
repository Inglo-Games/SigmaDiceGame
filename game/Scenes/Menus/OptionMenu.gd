extends Control


const COLOR_A_SETTING = "user_settings/colors/dice_color_a"
const COLOR_B_SETTING = "user_settings/colors/dice_color_b"
const BGM_SETTING = "user_settings/audio/bgm_level"
const SFX_SETTING = "user_settings/audio/sfx_level"


func _ready():
	# Set widgets to reflect current values
	$GridContainer/SfxSlider.value = ProjectSettings.get_setting(SFX_SETTING)
	$GridContainer/BgmSlider.value = ProjectSettings.get_setting(BGM_SETTING)
	$GridContainer/ColorPickerA.color = ProjectSettings.get_setting(COLOR_A_SETTING)
	$GridContainer/ColorPickerB.color = ProjectSettings.get_setting(COLOR_B_SETTING)


# Triggered by "Back" button; change scene to main menu
func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")


# Triggered by SfxSlider value being changed; updates SFX level setting
func _on_sfx_slider_value_changed(value:float):
	ProjectSettings.set_setting(SFX_SETTING, value)


# Triggered by BgmSlider value being changed; updates BGM level setting
func _on_bgm_slider_value_changed(value:float):
	ProjectSettings.set_setting(BGM_SETTING, value)


# Triggered by ColorPicker1 value being changed; updates first color setting
func _on_color_picker_1_color_changed(color:Color):
	ProjectSettings.set_setting(COLOR_A_SETTING, color)


# Triggered by ColorPicker2 value being changed; updates second color setting
func _on_color_picker_2_color_changed(color:Color):
	ProjectSettings.set_setting(COLOR_B_SETTING, color)
