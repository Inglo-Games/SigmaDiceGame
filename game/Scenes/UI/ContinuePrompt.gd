extends Control


func _on_continue_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_new_button_pressed():
	# Remove save file before starting the game
	DirAccess.remove_absolute("user://game_data.res")
	add_child(load("res://Scenes/UI/LevelSelectPrompt.tscn").instantiate())
