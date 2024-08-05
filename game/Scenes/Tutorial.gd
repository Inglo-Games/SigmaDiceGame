extends GameEnvironment
class_name GameTutorial


# Lines to display on tutorial prompts
const tutorial_lines := [
	"Swipe up to roll the dice.",
	"Tap on each die to assign it a color.  You need to have two dice of each color and one uncolored die at the end of each round.",
	"Tap the “End round” button to end the round.",
	"Tap the “^” button to see the scoreboard.",
	"Each round, you get points for the sum of each color pair.  Less common pairs like 2 and 12 are worth more.",
	"The first three points for each sum count against you.  The fourth and later points add to your score.",
	"The uncolored die is added to the discard pile.  Once the discard pile has three values, you must discard one of those values if possible each round.",
	"Once any of the discard values has been discarded 10 times, the game ends."
]
# Locations to put tutorial prompts
const tutorial_anchors := [
	Vector4(0.05, 0.95, 0.2, 0.3),
	Vector4(0.05, 0.95, 0.5, 0.6),
	Vector4(0.05, 0.95, 0.7, 0.8),
	Vector4(0.05, 0.95, 0.7, 0.8),
	Vector4(0.05, 0.95, 0.2, 0.3),
	Vector4(0.05, 0.95, 0.3, 0.4),
	Vector4(0.05, 0.95, 0.8, 0.9),
	Vector4(0.05, 0.95, 0.45, 0.55)
]


# Record step of the tutorial that player is on
var tut_step := 0


func _ready():
	# Remove any existing save file so tutorial starts from new game
	if FileAccess.file_exists(SAVE_GAME_FILE):
		DirAccess.remove_absolute(SAVE_GAME_FILE)
	
	# Perform all connections in the parent class _ready() function
	super._ready()
	
	# Connect signals to relevant tutorial prompt functions
	dice_stopped.connect(_on_dice_stopped_moving)
	round_ended.connect(_on_round_ended)
	$ScoreboardPanel.scoreboard_toggled.connect(_on_scoreboard_toggled)
	for node in get_children():
		if node is Die:
			node.color_selection_changed.connect(_on_die_assigned)
	
	# Add initial tutorial prompt to screen
	_add_tut_prompt()


# Create a new prompt using the TutorialPromptFactory class and add it to the scene
func _add_tut_prompt():
	var prompt = TutorialPromptFactory.create_prompt_with_anchors(tutorial_lines[tut_step], tutorial_anchors[tut_step])
	prompt.prompt_dismissed.connect(_on_prompt_dismissed)
	add_child(prompt)
	tut_step += 1


# Triggered by a tutorial prompt being dismissed, may show another prompt
# depending on current tutorial step
func _on_prompt_dismissed():
	if tut_step == 5 or tut_step == 6:
		_add_tut_prompt()


# Triggered when dice stop moving, will show line[1] if appropriate
func _on_dice_stopped_moving():
	if tut_step == 1:
		_add_tut_prompt()


# Triggered when the color of a die is changed, will show line[2] if appropriate
func _on_die_assigned():
	if tut_step == 2 or tut_step == 4:
		_add_tut_prompt()


# Triggered when scoreboard is shown or hidden, may show line[4] if appropriate
func _on_scoreboard_toggled():
	if tut_step == 4:
		_add_tut_prompt()


# Triggered when the round ends, may show another prmopt depending on current
# tutorial step
func _on_round_ended():
	if tut_step == 3 or tut_step == 7:
		_add_tut_prompt()
