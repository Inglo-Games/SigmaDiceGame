extends Control
class_name TutorialPrompt


signal prompt_dismissed

# Set default anchor point values
var anc_left := 0.2
var anc_right := 0.8
var anc_top := 0.8
var anc_bottom := 0.9
# Save prompt text to set during _ready()
var prompt_text := ""


func _ready():
	# Set anchor points and prompt text
	var container = $PromptContainer
	container.anchor_left = anc_left
	container.anchor_right = anc_right
	container.anchor_top = anc_top
	container.anchor_bottom = anc_bottom
	$PromptContainer/PromptLabel.text = prompt_text


func _input(event):
	# Dismiss prompt if touched...
	if event is InputEventScreenTouch or event is InputEventKey:
		if event.pressed:
			prompt_dismissed.emit()
			self.queue_free()

