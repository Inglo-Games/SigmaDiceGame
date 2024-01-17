extends PanelContainer


func _ready():
	get_tree().paused = true


func set_score_label(score:int):
	$VBox/ScoreLabel.text = "Final score: %d" % score


func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Menus/MainMenu.tscn")
