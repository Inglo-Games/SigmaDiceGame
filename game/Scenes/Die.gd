class_name Die
extends RigidBody3D


# Transparent color value for background glow
const GLOW_NONE := Color(0, 0, 0, 1)

signal color_selection_changed
signal finished_moving

@onready var GLOW_A : Color = ProjectSettings.get_setting("user_settings/colors/dice_color_a")
@onready var GLOW_B : Color = ProjectSettings.get_setting("user_settings/colors/dice_color_b")

@onready var face_cast : RayCast3D = $FaceDetectorRaycast
@onready var audio_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

@onready var original_pos := global_position
@onready var glow_color := GLOW_NONE

# Material used for the die pips
var pip_material : StandardMaterial3D

# Record whether die is currently moving
var is_moving := false

# Three audio tracks for collisions with die, floor, and wall respectively
var die_sounds : Array[AudioStream] = [
	preload("res://Assets/sfx/DieOnDie01.wav"),
	preload("res://Assets/sfx/DieOnDie02.wav"),
	preload("res://Assets/sfx/DieOnDie03.wav")]
var floor_sounds : Array[AudioStream] = [
	preload("res://Assets/sfx/DieOnStone01.wav"),
	preload("res://Assets/sfx/DieOnStone02.wav"),
	preload("res://Assets/sfx/DieOnStone03.wav")
]

func _ready():
	# Override material 1 (the pip material) so that changing colors will only
	# affect this instance
	$basic_die/die.set_surface_override_material(1, \
				$basic_die/die.get_mesh().surface_get_material(1).duplicate())
	pip_material = $basic_die/die.get_surface_override_material(1)
	
	# Enable collision detection with up to 5 contact points
	contact_monitor = true
	max_contacts_reported = 5


func _physics_process(_delta):
	# If moving, check magnitude of velocity vector to see if stopped
	if is_moving:
		if linear_velocity.length() <= 0.0001:
			is_moving = false
			emit_signal("finished_moving")
	
	# Reposition face detecting raycast to be above die WRT global position
	face_cast.global_position = global_position + Vector3.UP


# Get the current value of the die, i.e. the number on the top face
func get_value() -> int :
	var up_face = face_cast.get_collider()
	
	if up_face == $FaceArea1:
		return 1
	elif up_face == $FaceArea2:
		return 2
	elif up_face == $FaceArea3:
		return 3
	elif up_face == $FaceArea4:
		return 4
	elif up_face == $FaceArea5:
		return 5
	elif up_face == $FaceArea6:
		return 6
	else:
		print("Error in Die.get_value(): FaceDetectorRaycast is not colliding!")
		return 0


# Get the current glow color of the dice that the player has selected
func get_color() -> Color :
	return glow_color


# Triggered by player input; change color if player taps/clicks on die
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if event.is_action("select_die") and event.is_pressed():
		_change_glow_color()
		emit_signal("color_selection_changed")


# Change the color of the glow around the die's edge
func _change_glow_color():
	match glow_color:
		GLOW_B:
			glow_color = GLOW_NONE
		GLOW_A:
			glow_color = GLOW_B
		GLOW_NONE:
			glow_color = GLOW_A
	pip_material.albedo_color = glow_color
	pip_material.emission = glow_color
	pip_material.emission_enabled = true


# Reset die to original positions and clear outline glow
func _reset_die():
	global_position = original_pos
	freeze = true
	global_position = original_pos
	
	is_moving = false
	glow_color = GLOW_NONE
	pip_material.albedo_color = glow_color
	pip_material.emission_enabled = false
	emit_signal("color_selection_changed")


# Randomize the rotation values
func _randomize_orientation():
	var x_rot := RngManager.rng.randf_range(0.0, 2*PI)
	var y_rot := RngManager.rng.randf_range(0.0, 2*PI)
	var z_rot := RngManager.rng.randf_range(0.0, 2*PI)
	rotation = Vector3(x_rot, y_rot, z_rot)


# Emit a force to push the die "forward" relative to the world
func _launch_die():
	freeze = false
	_randomize_orientation()
	# Apply a force with a large forward force and a small upward force
	apply_impulse(
		Vector3(0, RngManager.rng.randf_range(0,5), RngManager.rng.randf_range(-20, -25)), 
		Vector3.ZERO
	)
	# Apply a random rotational force around the x (sideways) axis
	apply_torque_impulse(
		Vector3(RngManager.rng.randf_range(50.0, 250.0), 0, 0)
	)
	# Delay setting is_moving so it doesn't trigger on the next frame
	await get_tree().create_timer(0.02).timeout
	is_moving = true


# Triggered by collision with another object; play appropriate sound
func _on_body_entered(body):
	
	# Case 1: Body is another die
	if body is Die:
		audio_player.set_stream(die_sounds.pick_random())
		audio_player.play()
	
	# Case 2: Body is dice box
	else:
		# TODO: Differentiate between hitting floor and wall
		audio_player.set_stream(floor_sounds.pick_random())
		audio_player.play()
