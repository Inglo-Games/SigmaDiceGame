extends PanelContainer
class_name TempNotification


# Constants for how long the notif shows and fades
const NOTIF_LIFETIME := 2.5
const NOTIF_FADE_TIME := 0.75

# Save the notification text to set it during _ready()
var notif_text := ""


func _ready():
	# Set label text
	$NotifLabel.text = notif_text
	# Wait until lifetime expires, then remove
	await get_tree().create_timer(NOTIF_LIFETIME).timeout
	_fade_out_and_remove()


# Fade the notification out of view and remove it
func _fade_out_and_remove():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), NOTIF_FADE_TIME)
	tween.play()
	await tween.finished
	self.queue_free()
