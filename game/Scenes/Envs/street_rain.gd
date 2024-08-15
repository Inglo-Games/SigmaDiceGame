extends Node3D

func _ready() -> void:
	# Decrease roughness of surfaces to simulate wetness
	$dice_box_street.get_child(0).mesh.surface_get_material(0).roughness = 0.6
	$dice_box_street.get_child(0).mesh.surface_get_material(1).roughness = 0.6
	$dice_box_street.get_child(0).mesh.surface_get_material(2).roughness = 0.6
	$dice_box_street.get_child(1).mesh.surface_get_material(0).roughness = 0.6
