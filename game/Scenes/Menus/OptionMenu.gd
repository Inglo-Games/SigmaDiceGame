extends Control

# Signal to switch back to main menu
signal menu_dismissed

# Filename for custom settings file
const SETTINGS_FILE = "user://settings.godot"
# Names of settings that store colors for player to choose dice with
const COLOR_A_SETTING = "user_settings/colors/dice_color_a"
const COLOR_B_SETTING = "user_settings/colors/dice_color_b"
# Name of setting for left handed mode
const LEFT_HAND_MODE_SETTING = "user_settings/ui/left_handed_mode"


func _ready():
	# Set widgets to reflect current values
	$PanelContainer/GridContainer/SfxSlider.value = ProjectSettings.get_setting(AudioManager.SFX_SETTING)
	$PanelContainer/GridContainer/BgmSlider.value = ProjectSettings.get_setting(AudioManager.BGM_SETTING)
	$PanelContainer/GridContainer/LeftySwitch.button_pressed = ProjectSettings.get_setting(LEFT_HAND_MODE_SETTING)
	# Set textures for color picker buttons
	_on_new_color_selected()


# Handle "Back" action in Android OS
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_button_pressed()


# Triggered by "Back" button; display main menu
func _on_back_button_pressed():
	$ButtonClickAudio.play()
	menu_dismissed.emit()
	self.visible = false
	self.queue_free()


# Triggered by SfxSlider value being changed; updates SFX level setting
func _on_sfx_slider_value_changed(value:float):
	ProjectSettings.set_setting(AudioManager.SFX_SETTING, value)
	AudioManager.set_audio_busses()
	ProjectSettings.save_custom(SETTINGS_FILE)


# Triggered by BgmSlider value being changed; updates BGM level setting
func _on_bgm_slider_value_changed(value:float):
	ProjectSettings.set_setting(AudioManager.BGM_SETTING, value)
	AudioManager.set_audio_busses()
	ProjectSettings.save_custom(SETTINGS_FILE)


# Trigger by left-handed switch toggle; sets left-handed mode setting
func _on_lefty_switch_toggled(toggled_on:bool):
	ProjectSettings.set_setting(LEFT_HAND_MODE_SETTING, toggled_on)
	ProjectSettings.save_custom(SETTINGS_FILE)


# Triggered by clicking the TextureButton for color A; creates a 
# SimpleColorPicker popup and connects it to the color update function
func _on_texture_button_a_pressed():
	var picker = ColorPickerFactory.create_picker(COLOR_A_SETTING)
	picker.color_selected.connect(_on_new_color_selected)
	add_child(picker)


# Triggered by clicking the TextureButton for color B; creates a 
# SimpleColorPicker popup and connects it to the color update function
func _on_texture_button_b_pressed():
	var picker = ColorPickerFactory.create_picker(COLOR_B_SETTING)
	picker.color_selected.connect(_on_new_color_selected)
	add_child(picker)


# Triggered by player selecting a new color via SimpleColorPicker popup, update
# the colors displayed on both color TextureButtons
func _on_new_color_selected():
	_set_texture_color(
		$PanelContainer/GridContainer/TextureButtonA, 
		ProjectSettings.get_setting(COLOR_A_SETTING)
	)
	_set_texture_color(
		$PanelContainer/GridContainer/TextureButtonB, 
		ProjectSettings.get_setting(COLOR_B_SETTING)
	)
	ProjectSettings.save_custom(SETTINGS_FILE)


# Helper function to set a GradientTexture2D to a single given color
func _set_texture_color(button:TextureButton, color:Color):
	# Create a new Gradient with just the given color
	var new_gradient = Gradient.new()
	new_gradient.set_color(0, color)
	new_gradient.set_color(1, color)
	# Set the texture's gradient to the new one
	button.texture_normal.gradient = new_gradient
	button.texture_pressed.gradient = new_gradient
	button.texture_hover.gradient = new_gradient
