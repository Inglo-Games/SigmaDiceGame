class_name Die
extends RigidBody3D


# Transparent color value for background glow
const GLOW_NONE := Color(0, 0, 0, 0)

signal color_selection_changed
signal finished_moving

@onready var GLOW_A : Color = ProjectSettings.get_setting("user_settings/colors/dice_color_a")
@onready var GLOW_B : Color = ProjectSettings.get_setting("user_settings/colors/dice_color_b")

@onready var face_cast : RayCast3D = $FaceDetectorRaycast

@onready var original_pos := global_position
@onready var glow_color := GLOW_NONE

var is_moving := false


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
	$MeshInstance3D.set_instance_shader_parameter("outline_color", glow_color)


# Reset die to original positions and clear outline glow
func _reset_die():
	global_position = original_pos
	freeze = true
	global_position = original_pos
	
	is_moving = false
	glow_color = GLOW_NONE
	$MeshInstance3D.set_instance_shader_parameter("outline_color", glow_color)
	emit_signal("color_selection_changed")


# Randomize the rotation values
func _randomize_orientation():
	var x_rot := randf_range(0.0, 2*PI)
	var y_rot := randf_range(0.0, 2*PI)
	var z_rot := randf_range(0.0, 2*PI)
	rotation = Vector3(x_rot, y_rot, z_rot)


# Emit a force to push the die "forward" relative to the world
func _launch_die():
	freeze = false
	_randomize_orientation()
	# Apply a force with a large forward force and a small upward force
	apply_impulse(
		Vector3(0, randf_range(0,5), randf_range(-20, -25)), 
		Vector3.ZERO
	)
	# Apply a random rotational force around the x (sideways) axis
	apply_torque_impulse(
		Vector3(randf_range(50.0, 250.0), 0, 0)
	)
	# Delay setting is_moving so it doesn't trigger on the next frame
	await get_tree().create_timer(0.02).timeout
	is_moving = true
