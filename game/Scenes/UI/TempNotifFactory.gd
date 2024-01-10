extends Node
class_name TempNotifFactory


const TEMP_NOTIF_CLASS = preload("res://Scenes/UI/TempNotification.tscn")


# Create an instance of TempNotification with the given text and return it
static func create_notif(text:String) -> TempNotification:
	var notif = TEMP_NOTIF_CLASS.instantiate()
	notif.notif_text = text
	return notif
