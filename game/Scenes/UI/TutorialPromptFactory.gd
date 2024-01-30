extends Node
class_name TutorialPromptFactory


const PROMPT_CLASS = preload("res://Scenes/UI/TutorialPrompt.tscn")


# Create an instance of TutorialPrompt with the given text and return it
static func create_prompt(text:String) -> TutorialPrompt:
	var prompt = PROMPT_CLASS.instantiate()
	prompt.prompt_text = text
	return prompt


# Create an instance of TutorialPrompt with given text and anchor points
static func create_prompt_with_anchors(text:String, anc:Vector4) -> TutorialPrompt:
	var prompt = create_prompt(text)
	prompt.anc_left = anc.x
	prompt.anc_right = anc.y
	prompt.anc_top = anc.z
	prompt.anc_bottom = anc.w
	return prompt
