extends Control


# Make background move each frame
func _process(delta):
	var bg = $ParallaxBackground/ParallaxLayer
	# Move left and down, scaled by framerate
	bg.motion_offset += Vector2(-83, 127) * delta


# Handle "Back" action in Android OS
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


# Triggered by "Play Game" button; goes to game scene
func _on_play_button_pressed():
	$ButtonClickAudio.play()
	# If there's a save game file, ask player to continue...
	if FileAccess.file_exists("user://game_data.res"):
		add_child(load("res://Scenes/UI/ContinuePrompt.tscn").instantiate())
	# Otherwise just start the game
	else:
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")


# Triggered by "Play Tutorial" button
func _on_tutorial_button_pressed():
	$ButtonClickAudio.play()
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")


# Triggered by "Options" button; goes to options menu scene
func _on_options_button_pressed():
	$ButtonClickAudio.play()
	get_tree().change_scene_to_file("res://Scenes/Menus/OptionMenu.tscn")


# Triggered by "Exit" button; quits program
func _on_quit_button_pressed():
	get_tree().quit()
