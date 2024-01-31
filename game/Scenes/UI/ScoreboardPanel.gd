extends VBoxContainer


signal scoreboard_toggled

# X coordinate for where panel should sit when "in view", relative to start pos
const SLIDE_TARGET_X := 256.0
const SLIDE_TARGET_Y := 1024.0

# Track whether panel is currently in the player's viewport
var is_in_view := false


# Triggered by ExpanderButton; slide panel into or out of view depending on
# current position
func _on_expander_button_pressed():
	$ExpanderButton.disabled = true
	if is_in_view:
		_slide_panel_out_view()
	else:
		_slide_panel_into_view()
	$ExpanderButton.release_focus()
	scoreboard_toggled.emit()


# Slide the panel up into the player's viewport
func _slide_panel_into_view():
	# Determine new position for panel
	var target_pos = Vector2(position.x, position.y - SLIDE_TARGET_Y)
	
	# Use a tween to slide panel
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.5)
	tween.set_trans(Tween.TRANS_BACK)
	tween.play()
	await tween.finished
	
	# After tween is finished, update button and is_in_view value
	is_in_view = true
	$ExpanderButton.text = "v"
	$ExpanderButton.disabled = false


# Slide the panel down out of the player's viewport
func _slide_panel_out_view():
	var target_pos = Vector2(position.x, position.y + SLIDE_TARGET_Y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 0.5)
	tween.set_trans(Tween.TRANS_BACK)
	tween.play()
	await tween.finished
	
	is_in_view = false
	$ExpanderButton.text = "^"
	$ExpanderButton.disabled = false
