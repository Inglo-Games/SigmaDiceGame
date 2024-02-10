extends Node3D
class_name GameEnvironment

enum DICE_STATE {START, ROLLING, FINISHED} 

signal dice_stopped
signal round_ended

# Transform for Camera's starting position
const CAM_START_POS = Transform3D(
		Vector3(1, 0, 0),
		Vector3(0, 0.866025, -0.5),
		Vector3(0, 0.5, 0.866025),
		Vector3(0, 6.5, 7)
)
# Transform for camera during dice selection phase
const CAM_END_POS = Transform3D(
		Vector3(1, 0, 0),
		Vector3(0, 0, -1),
		Vector3(0, 1, 0),
		Vector3(0, 6.5, -7)
)

# Name for saved game file
const SAVE_GAME_FILE := "user://game_data.res"

# Length threshold for a touchscreen swipe
const SWIPE_THRESHOLD := 192.0

# Get the colors for the dice selection glow from user settings
@onready var glow_color_a = ProjectSettings.get_setting("user_settings/colors/dice_color_a")
@onready var glow_color_b = ProjectSettings.get_setting("user_settings/colors/dice_color_b")

# Game state and logic object
var game_state

# Track state of the dice (start of round, rolling, or finished moving)
var dice_state := DICE_STATE.START
# Track number of dice moving at any time
var dice_moving := 0
# Track touchscreen touch positions
var touch_start := Vector2.ZERO


func _ready():
	# Check if a saved game exists and load it if so
	if(ResourceLoader.exists(SAVE_GAME_FILE)):
		game_state = ResourceLoader.load(SAVE_GAME_FILE)
		$ScoreboardPanel/PanelContainer/Scoreboard.update_scoreboard(game_state)
		RngManager.restore_rng_state(game_state.rng_state)
	else:
		game_state = SigmaGame.new()
	
	# Connect signals from each die to relevant functions
	for node in get_children():
		if node is Die:
			node.connect("finished_moving", _decrement_moving_dice_count)
	game_state.connect("selection_error_two_pairs", _on_error_two_pairs)
	game_state.connect("selection_error_bad_discard", _on_error_bad_discard)
	game_state.connect("game_ended", _on_game_over)
	

func _input(_event):
	
	if Input.is_action_just_pressed("launch_dice") and dice_state == DICE_STATE.START:
		_launch_dice()
	
	if Input.is_action_just_pressed("reset_dice"):
		_reset_game_state()


func _unhandled_input(event):
	# Handle touchscreen touches to detect upward swipes
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start = event.get_position()
		else:
			# If swipe is upward and greater than threshold length...
			if touch_start.y > event.get_position().y and \
					touch_start.y - event.get_position().y >= SWIPE_THRESHOLD:
				print("Upward swipe detected...")
				if dice_state == DICE_STATE.START: _launch_dice()


# Handle "Back" action in Android OS
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		add_child(load("res://Scenes/UI/BackPrompt.tscn").instantiate())


# Record the game state as a resource file
func _save_game_data():
	if ResourceSaver.save(game_state, SAVE_GAME_FILE) != OK:
		print("Error saving game state!")


# Moves camera from starting position to directly above dice target
func _tween_cam_transform():
	var tween = create_tween()
	tween.tween_property($Camera3D, "transform", CAM_END_POS, 2.5).set_trans(Tween.TRANS_CUBIC)
	tween.play()


# Create a dictionary with the current dice values and player selections
func _create_dice_dict() -> Dictionary :
	var new_dict := {"color_a": [], "color_b": [], "discard": []}
	for die in [$Die, $Die2, $Die3, $Die4, $Die5]:
		match die.get_color():
			glow_color_a:
				new_dict["color_a"].append(die.get_value())
			glow_color_b:
				new_dict["color_b"].append(die.get_value())
			Die.GLOW_NONE:
				new_dict["discard"].append(die.get_value())
	
	return new_dict


# Decrement the number of currently moving dice, and update dice_state if no
# dice are moving
func _decrement_moving_dice_count():
	dice_moving -= 1
	print("Dice left moving: %d" % dice_moving)
	if dice_moving <= 0:
		print("All the dice stopped!")
		dice_state = DICE_STATE.FINISHED
		$ButtonContainer/EndRoundButton.disabled = false
		dice_stopped.emit()


# Callback for "End Round" button
func _on_pressed_end_round_button(): 
	if game_state.end_round(_create_dice_dict()):
		print("Current scores:\n%s\n%s\n" % [game_state.score_pair_count, game_state.discard_pile])
		$ScoreboardPanel/PanelContainer/Scoreboard.update_scoreboard(game_state)
		_reset_game_state()
		_save_game_data()
		round_ended.emit()
	else:
		print("Can't end round!\n")
	
	$ButtonContainer/EndRoundButton.release_focus()


# Launch all dice forward, move camera, and enable "End Round" button
func _launch_dice():
	dice_state = DICE_STATE.ROLLING
	dice_moving = 5
	get_tree().call_group("dice", "_launch_die")
	_tween_cam_transform()
	# Set a short timer to enable the "End Round" button, just in case the 
	# movement check fails
	await get_tree().create_timer(5.0).timeout
	$ButtonContainer/EndRoundButton.disabled = false


# Reset the game dice, camera, and UI to start-of-round state
func _reset_game_state():
	dice_state = DICE_STATE.START
	get_tree().call_group("dice", "_reset_die")
	$Camera3D.transform = CAM_START_POS
	$ButtonContainer/EndRoundButton.disabled = true


# Display a temp notification alerting player of selection error
func _on_error_two_pairs():
	var notif = TempNotifFactory.create_notif("You must have 2 dice of each color")
	add_child(notif)


# Display a temp notification alerting player of discard error
func _on_error_bad_discard(discard_vals:Array):
	var msg = "Discard die must be one of %d, %d, or %d" % \
			[discard_vals[0], discard_vals[1], discard_vals[2]]
	var notif = TempNotifFactory.create_notif(msg)
	add_child(notif)


# Display the game over popup
func _on_game_over():
	var popup = preload("res://Scenes/UI/GameOverPanel.tscn").instantiate()
	popup.set_score_label(game_state.calculate_total_score())
	add_child(popup)
	# Remove save game file since game is finished
	DirAccess.remove_absolute(SAVE_GAME_FILE)
