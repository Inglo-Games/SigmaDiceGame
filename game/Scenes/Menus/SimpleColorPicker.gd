extends Control
class_name SimpleColorPicker


signal color_selected

# Set the setting name that this popup would change the color of
var color_setting : String = ""

@onready var rSlider = $PanelContainer/VBoxContainer/RSlider/HSlider
@onready var gSlider = $PanelContainer/VBoxContainer/GSlider/HSlider
@onready var bSlider = $PanelContainer/VBoxContainer/BSlider/HSlider
@onready var display = $PanelContainer/VBoxContainer/ColorDisplay


func _ready():
	# Get the color of the current setting
	var current_color : Color = ProjectSettings.get_setting(color_setting)
	# Set the color display and sliders to the current color setting
	display.color = current_color
	rSlider.value = current_color.r
	gSlider.value = current_color.g
	bSlider.value = current_color.b


# Get the color from the values of the sliders
func _get_color_from_sliders() -> Color :
	var r = rSlider.value
	var g = gSlider.value
	var b = bSlider.value
	return Color(r, g, b)


# Triggered by any slider changing, update the color display
func _on_slider_value_changed(_value):
	display.color = _get_color_from_sliders()


# Triggered by "Accept" button, record the color to the ProjectSettings
func _on_ok_button_pressed():
	ProjectSettings.set_setting(color_setting, _get_color_from_sliders())
	color_selected.emit()
	self.queue_free()


# Triggered by "Back" button, clears this popup without changing anything
func _on_back_button_pressed():
	self.queue_free()
