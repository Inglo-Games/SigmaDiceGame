extends Control


const COLOR_A_SETTING = "user_settings/colors/dice_color_a"
const COLOR_B_SETTING = "user_settings/colors/dice_color_b"


func _ready():
	# Set widgets to reflect current values
	$GridContainer/SfxSlider.value = ProjectSettings.get_setting(AudioManager.SFX_SETTING)
	$GridContainer/BgmSlider.value = ProjectSettings.get_setting(AudioManager.BGM_SETTING)
	$GridContainer/ColorPickerA.color = ProjectSettings.get_setting(COLOR_A_SETTING)
	$GridContainer/ColorPickerB.color = ProjectSettings.get_setting(COLOR_B_SETTING)


# Handle "Back" action in Android OS
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")


# Triggered by "Back" button; change scene to main menu
func _on_back_button_pressed():
	$ButtonClickAudio.play()
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")


# Triggered by SfxSlider value being changed; updates SFX level setting
func _on_sfx_slider_value_changed(value:float):
	ProjectSettings.set_setting(AudioManager.SFX_SETTING, value)
	AudioManager.set_audio_busses()


# Triggered by BgmSlider value being changed; updates BGM level setting
func _on_bgm_slider_value_changed(value:float):
	ProjectSettings.set_setting(AudioManager.BGM_SETTING, value)
	AudioManager.set_audio_busses()


# Triggered by ColorPicker1 value being changed; updates first color setting
func _on_color_picker_1_color_changed(color:Color):
	$ButtonClickAudio.play()
	ProjectSettings.set_setting(COLOR_A_SETTING, color)


# Triggered by ColorPicker2 value being changed; updates second color setting
func _on_color_picker_2_color_changed(color:Color):
	$ButtonClickAudio.play()
	ProjectSettings.set_setting(COLOR_B_SETTING, color)
