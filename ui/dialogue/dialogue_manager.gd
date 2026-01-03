extends MenuPanel

@onready var speaker_name = $DialoguePanel/Name
@onready var dialogue = $DialoguePanel/DialogueBackground/Dialogue
@onready var image = $ImagePanel/ImageBackground/Image
@onready var dialogue_data = GameData.dialogue_data

var in_dialogue = false
var current_dialogue = []
var current_line = 0
var current_dialogue_length = 0

func update_ui():
	start_dialogue("debug_dialogue")

func start_dialogue(dialogue_id):
	if dialogue_data[dialogue_id] != null:
		in_dialogue = true
		current_dialogue = dialogue_data[dialogue_id]
		current_line = 0
		current_dialogue_length = current_dialogue.size() -1
		advance_dialogue()

func _input(event):
	if in_dialogue:
		if event.is_action_pressed("confirm") && current_line <= current_dialogue_length:
			print("Advance Dialogue")
			advance_dialogue()
		elif event.is_action_pressed("confirm") && current_line > current_dialogue_length:
			get_viewport().set_input_as_handled()
			print("End Dialogue")
			in_dialogue = false
			Global.ui_manager.close_ui()
		elif event.is_action_pressed("cancel"):
			print("Cancel Dialogue")
			in_dialogue = false
			Global.ui_manager.close_ui()

func advance_dialogue():
	speaker_name.text = current_dialogue[current_line].speaker
	dialogue.text = current_dialogue[current_line].text
	image.texture = load(current_dialogue[current_line].image)
	current_line += 1
