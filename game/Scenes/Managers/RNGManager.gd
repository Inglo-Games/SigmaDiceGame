# The RNGManager class allows more control over the random number generator,
# such as setting and saving RNG states to provide consistency across game
# sessions.
extends Node

var rng := RandomNumberGenerator.new()


func _init():
	rng.randomize()


func get_rng_state() -> int:
	return rng.state


func restore_rng_state(new_state:int):
	rng.state = new_state
