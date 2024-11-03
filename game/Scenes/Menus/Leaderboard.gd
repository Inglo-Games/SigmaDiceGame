extends Control

# Signal to switch back to main menu
signal menu_dismissed

# Name for high score file
const SCORES_FILE := "user://scores.csv"


func _ready():
	# Load in contents of score file and sort by highest scores
	var score_file = FileAccess.open(SCORES_FILE, FileAccess.READ)
	var scores := []
	while(not score_file.eof_reached()):
		var line = score_file.get_csv_line()
		if line.size() == 2:
			# Score is zeroth item in line, date/time string is oneth
			scores.append([int(line[0]), line[1]])
	# Sort scores in descending order
	scores.sort_custom(func(a, b): return a[0] > b[0])
	
	# Display the scores in the container
	for score in scores:
		var line_display := HBoxContainer.new()
		var label_left := Label.new()
		label_left.text = "%d" % score[0]
		var label_right := Label.new()
		label_right.text = score[1]
		line_display.add_child(label_left)
		line_display.add_child(label_right)
		$PanelContainer/VBoxContainer.add_child(line_display)


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
