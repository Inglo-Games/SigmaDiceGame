extends HBoxContainer
class_name ScoreLightRow


# LED indicator light textures
const LED_GREEN_OFF = preload("res://Assets/images/ui/score_led_blank.png")
const LED_GREEN_ON = preload("res://Assets/images/ui/score_led_green.png")
const LED_RED_OFF = preload("res://Assets/images/ui/score_led_blank.png")
const LED_RED_ON = preload("res://Assets/images/ui/score_led_red.png")

# Ideal width of row, in pixels
const ROW_WIDTH_TARGET := 980

# Score value that this row represents
@export var row_value := 2


# Set up width and number of green LED indicators
func _ready():
	# Set number label for this row
	$Label.text = str(row_value)
	
	# Determine width of green LEDs, less common values like 2 and 12 are wider
	var green_led_width = floor($Led2.size.x * (1 + 0.23 * abs(7 - row_value)))
	$Led2.custom_minimum_size.x = green_led_width
	
	# Determine number of LEDs based on above width
	var sep_const := get_theme_constant("separation")
	var avbl_width = ROW_WIDTH_TARGET - ($Label.size.x + green_led_width * 2 \
												+ sep_const * 3)
	var num_lights : int = floor(avbl_width / (green_led_width + sep_const))
	
	# Duplicate $Led2 until there are num_lights of them
	for index in range(num_lights - 1):
		# Keep groups and scripts, not instance
		add_child($Led2.duplicate(DUPLICATE_SCRIPTS | DUPLICATE_GROUPS))


# Set light textures based on current number of points for this value
func set_lights(points:int):
	
	# If points are 0-2, we only need to modify the red lights
	if points == 0:
		$Led0.set_texture(LED_RED_OFF)
		$Led1.set_texture(LED_RED_OFF)
	
	elif points == 1:
		$Led0.set_texture(LED_RED_ON)
		$Led1.set_texture(LED_RED_OFF)
	
	elif points == 2:
		$Led0.set_texture(LED_RED_ON)
		$Led1.set_texture(LED_RED_ON)
	
	# If points is more than 2, go through as many lights as there are points 
	# and set them to green
	else:
		var counter = points
		for child_node in get_children():
			if child_node is NinePatchRect:
				child_node.set_texture(LED_GREEN_ON)
				counter -= 1
				if counter <= 0:
					break
