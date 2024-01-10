class_name SigmaGame
extends Node


# Number of times a value has to be discarded before game ends
const END_GAME_THRESHOLD := 10

# Constants used in calculating final score
const NEGATIVE_SCORE_VALUE := -200
const POSITIVE_SCORE_VALUE := 100
const SCORE_SCALING_BONUS := 20

# Signals to alert game that an error message needs to be displayed
signal selection_error_two_pairs
signal selection_error_bad_discard

# Keeps track of how many of each sum has been scored by the player
var score_pair_count : Array[int] = []
# Keeps track of the "discard pile" of dice that weren't paired up each round
# as Vector2i's, where x is a die value and y is the number of times that value
# has been the discard value
var discard_pile : Array[Vector2i] = []


func _init():
	# Initialize values 0-12 of score_pair_count
	# 0 and 1 won't be used but this makes logic simpler
	for index in range(13):
		score_pair_count.append(0)


# Checks if the current selection of dice is legal
func _check_selection_legality(dice:Dictionary) -> bool :
	
	# First, check there are exactly 2 dice for each color selected
	if len(dice["color_a"]) != 2 or len(dice["color_b"]) != 2:
		print("Must have 2 dice of each color!")
		selection_error_two_pairs.emit()
		return false
	
	# Next check if the discard list already has 3 values
	if len(discard_pile) < 3:
		return true
	else:
		# Otherwise, see if the leftover die is one of the values in discard_pile
		var discard_vals := [discard_pile[0].x, discard_pile[1].x, discard_pile[2].x]
		if dice["discard"][0] in discard_vals:
			return true
		else:
			# Otherwise see if none of the 5 dice's values were in the discard pile
			for val in (dice["color_a"] + dice["color_b"]):
				if val in discard_vals:
					print("Discard die must be one of %s" % str(discard_vals))
					selection_error_bad_discard.emit(discard_vals)
					return false
	
	# If we reach this point, then none of the 5 dice values were in the already
	# filled discard pile.  Player selection is legal by default.
	return true


# Add this round's sums and discard to the game's arrays
func end_round(dice:Dictionary) -> bool :
	# First ensure that the given set of dice is a legal selection
	if not _check_selection_legality(dice):
		return false
	
	# First add the sums of each color pair
	score_pair_count[dice["color_a"][0] + dice["color_a"][1]] += 1
	score_pair_count[dice["color_b"][0] + dice["color_b"][1]] += 1
	
	# Next add the discard die to the discard pile, if it's there
	for index in range(len(discard_pile)):
		if dice["discard"][0] == discard_pile[index].x:
			discard_pile[index].y += 1
			return true
	
	# If it's not in the discard pile already and the discard pile isn't full,
	# add it to the discard pile
	if len(discard_pile) < 3:
		discard_pile.append(Vector2i(dice["discard"][0], 1))
	
	# Otherwise the discard pile is full and _check_selection_legality already
	# confirmed none of the dice are there, so player gets a free round
	return true


# Calculate the player's current total score
func calculate_total_score() -> int :
	
	var ret_val := 0
	for index in range(len(score_pair_count)):
		if score_pair_count[index] <= 2:
			# If pair has only one or two, it gets a negative value
			ret_val += score_pair_count[index] * NEGATIVE_SCORE_VALUE
		else:
			# If pair has more than two, it's value scales based on pair's
			# relative frequency (7 is most common, so it's worth the least)
			var score_amount : int = POSITIVE_SCORE_VALUE + SCORE_SCALING_BONUS * abs(7 - index)
			ret_val += (score_pair_count[index] - 2) * score_amount
	
	return ret_val


# Determine if the player has triggered the end of the game
func _is_game_over() -> bool :
	# Check each discard value's frequency against the end-game threshold
	for value in discard_pile:
		if value.y >= END_GAME_THRESHOLD:
			return true
	
	return false
