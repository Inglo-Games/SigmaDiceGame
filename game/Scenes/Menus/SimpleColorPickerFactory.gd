extends Node
class_name ColorPickerFactory


const PICKER_CLASS = preload("res://Scenes/Menus/SimpleColorPicker.tscn")


# Create a SimpleColorPicker linked to the given color setting
static func create_picker(setting:String) -> SimpleColorPicker :
	var picker = PICKER_CLASS.instantiate()
	picker.color_setting = setting
	return picker
