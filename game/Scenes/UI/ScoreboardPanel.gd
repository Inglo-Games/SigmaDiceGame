extends HBoxContainer

# X coordinate for where panel should sit when "in view", relative to start pos
const SLIDE_TARGET_X := 256.0

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


# Slide the panel left into the player's viewport
func _slide_panel_into_view():
	# Determine new position for panel
	var target_pos = Vector2(position.x - SLIDE_TARGET_X, position.y)
	
	# Use a tween to slide panel
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 1.5).set_trans(Tween.TRANS_SPRING)
	tween.play()
	await tween.finished
	
	# After tween is finished, update button and is_in_view value
	is_in_view = true
	$ExpanderButton.text = ">"
	$ExpanderButton.disabled = false


# Slide the panel right out of the player's viewport
func _slide_panel_out_view():
	var target_pos = Vector2(position.x + SLIDE_TARGET_X, position.y)
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_pos, 1.5).set_trans(Tween.TRANS_SPRING)
	tween.play()
	await tween.finished
	
	is_in_view = false
	$ExpanderButton.text = "<"
	$ExpanderButton.disabled = false
