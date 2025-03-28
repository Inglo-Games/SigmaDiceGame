extends Control


# Name for high score file
const SCORES_FILE := "user://scores.csv"

# Speed to scroll bg image
@onready var bg_move_x := randi_range(-100, 100)
@onready var bg_move_y := randi_range(-250, 250)


func _ready() -> void:
	# Only show leaderboard button if there is stuff to show
	if(FileAccess.file_exists(SCORES_FILE)):
		$VBoxContainer/RecordButton.visible = true


# Make background move each frame
func _process(delta):
	var bg = $ParallaxBackground/ParallaxLayer
	# Move in a random direction, scaled by framerate
	bg.motion_offset += Vector2(bg_move_x, bg_move_y) * delta


# Handle "Back" action in Android OS
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


# Triggered by signal "menu_dismissed"
func _on_menu_reappear():
	$VBoxContainer.visible = true


# Triggered by "Play Game" button; goes to game scene
func _on_play_button_pressed():
	$ButtonClickAudio.play()
	# If there's a save game file, ask player to continue...
	if FileAccess.file_exists("user://game_data.res"):
		add_child(load("res://Scenes/UI/ContinuePrompt.tscn").instantiate())
	# Otherwise let player select level
	else:
		add_child(load("res://Scenes/UI/LevelSelectPrompt.tscn").instantiate())


# Triggered by "Play Tutorial" button
func _on_tutorial_button_pressed():
	$ButtonClickAudio.play()
	get_tree().change_scene_to_file("res://Scenes/Tutorial.tscn")


# Triggered by "Options" button; replaced main menu with options menu
func _on_options_button_pressed():
	$ButtonClickAudio.play()
	$VBoxContainer.visible = false
	var options_menu = load("res://Scenes/Menus/OptionMenu.tscn").instantiate()
	options_menu.menu_dismissed.connect(_on_menu_reappear)
	add_child(options_menu)


func _on_record_button_pressed():
	$ButtonClickAudio.play()
	$VBoxContainer.visible = false
	var leaderboard = load("res://Scenes/Menus/Leaderboard.tscn").instantiate()
	leaderboard.menu_dismissed.connect(_on_menu_reappear)
	add_child(leaderboard)


# Triggered by "Exit" button; quits program
func _on_quit_button_pressed():
	get_tree().quit()
