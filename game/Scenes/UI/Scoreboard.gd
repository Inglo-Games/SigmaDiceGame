extends Control


# Update all of the UI elements on the scoreboard
func update_scoreboard(game_state:SigmaGame):
	_update_discard_lists(game_state.discard_pile)
	_update_score_lights(game_state.score_pair_count)
	_update_total_score(game_state.calculate_total_score())


# Update the discard progress bars
func _update_discard_lists(discards:Array[Vector2i]):
	for index in range(len(discards)):
		# Set the label's text to the given value 
		get_node("VBox/Grid2/DiscardLabel%d" % index).text = str(discards[index].x)
		# Set the progress bar's value to the number of times that value has been discarded
		get_node("VBox/Grid2/ProgBar%d" % index).value = discards[index].y


# Update the light icons representing pairs scored by player
func _update_score_lights(scores:Array[int]):
	pass


# Update total score label
func _update_total_score(score:int):
	$VBox/ScoreTotalLabel.text = "Total score: %d" % score
