extends Control

@onready var level_selector : OptionButton = $PromptContainer/VBoxContainer/LevelSelector


func _ready():
	# Select the item that is already in the stage setting if possible
	var current_stage = ProjectSettings.get_setting("user_settings/game/stage")
	for index in range(level_selector.item_count):
		if level_selector.get_item_text(index) == current_stage:
			level_selector.select(index)
			break


# Triggered by pressing "Cancel" button; closes popup
func _on_cancel_button_pressed():
	self.queue_free()


# Triggered by pressing "Play" button; loads game with selected stage
func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


# Triggered by selecting an item in the level dropdown; sets stage variable to
# the selected item
func _on_menu_button_item_selected(index):
	ProjectSettings.set_setting(
			"user_settings/game/stage",
			level_selector.get_item_text(index)
			)
	level_selector.release_focus()
