extends Area2D

var player_in_proximity : bool = false
@export var displayed_text : String
@export var menu_to_open : String

func _ready():
	$Panel.hide()
	$Panel/RichTextLabel.text = displayed_text

func _input(event):
	if event.is_action_pressed("confirm") && player_in_proximity:
		Global.ui_manager.interaction_registered(menu_to_open)

func _on_body_entered(body):
	if body == Global.player:
		player_in_proximity = true
		$Panel.show()

func _on_body_exited(body):
	if body == Global.player:
		player_in_proximity = false
		$Panel.hide()
