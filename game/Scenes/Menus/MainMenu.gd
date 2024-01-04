extends Control


# Triggered by "Play Game" button; goes to game scene
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


# Triggered by "Options" button; goes to options menu scene
func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/OptionMenu.tscn")


# Triggered by "Exit" button; quits program
func _on_quit_button_pressed():
	get_tree().quit()
