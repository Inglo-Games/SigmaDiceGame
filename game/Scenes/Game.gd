extends Node3D


enum DICE_STATE {START, ROLLING, FINISHED} 

# Transform for Camera's starting position
const CAM_START_POS = Transform3D(
		Vector3(1, 0, 0),
		Vector3(0, 0.866025, -0.5),
		Vector3(0, 0.5, 0.866025),
		Vector3(0, 4, 2)
)
# Transform for camera during dice selection phase
const CAM_END_POS = Transform3D(
		Vector3(1, 0, 0),
		Vector3(0, -0, -1),
		Vector3(0, 1, -0),
		Vector3(0, 2, -7)
)

# Game state and logic object
@onready var game_state = SigmaGame.new()

# Get the colors for the dice selection glow from user settings
@onready var glow_color_a = ProjectSettings.get_setting("user_settings/colors/dice_color_a")
@onready var glow_color_b = ProjectSettings.get_setting("user_settings/colors/dice_color_b")

# Track state of the dice (start of round, rolling, or finished moving)
var dice_state := DICE_STATE.START
# Track number of dice moving at any time
var dice_moving := 0


func _ready():
	# Connect signals from each die to relevant functions
	for node in get_children():
		if node is Die:
			node.connect("finished_moving", _decrement_moving_dice_count)


func _input(_event):
	
	if Input.is_action_just_pressed("launch_dice") and dice_state == DICE_STATE.START:
		dice_state = DICE_STATE.ROLLING
		dice_moving = 5
		get_tree().call_group("dice", "_launch_die")
		_tween_cam_transform()
		# Set a short timer to enable the "End Round" button, just in case the 
		# movement check fails
		await get_tree().create_timer(5.0).timeout
		$ButtonContainer/EndRoundButton.disabled = false
	
	if Input.is_action_just_pressed("reset_dice"):
		_reset_game_state()


# Moves camera from starting position to directly above dice target
func _tween_cam_transform():
	var tween = create_tween()
	tween.tween_property($Camera3D, "transform", CAM_END_POS, 4.5).set_trans(Tween.TRANS_CUBIC)
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
			Color(0, 0, 0, 0):
				new_dict["discard"].append(die.get_value())
	
	return new_dict


# Decrement the number of currently moving dice, and update dice_state if no
# dice are moving
func _decrement_moving_dice_count():
	dice_moving -= 1
	if dice_moving <= 0:
		dice_state = DICE_STATE.FINISHED
		$ButtonContainer/EndRoundButton.disabled = false


# Callback for "End Round" button
func _on_pressed_end_round_button(): 
	if game_state.end_round(_create_dice_dict()):
		print("Current scores:\n%s\n%s\n" % [game_state.score_pair_count, game_state.discard_pile])
		$ScoreboardPanel/PanelContainer/Scoreboard.update_scoreboard(game_state)
		_reset_game_state()
	else:
		print("Can't end round!\n")
	
	$ButtonContainer/EndRoundButton.release_focus()


# Reset the game dice, camera, and UI to start-of-round state
func _reset_game_state():
	dice_state = DICE_STATE.START
	get_tree().call_group("dice", "_reset_die")
	$Camera3D.transform = CAM_START_POS
	$ButtonContainer/EndRoundButton.disabled = true
