extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/MenuButtons/NewGame.grab_focus()
	get_window().size = Vector2i(1280, 720)
	get_window().position = get_window().position - Vector2i(480, 270)
	#Global.modify_theme("a5dbe5")

func _on_new_game_pressed():
	print("Starting new game")
	Global.setup_debug_game()
	get_tree().change_scene_to_file("res://debug/debug_map.tscn")

func _on_load_pressed():
	print("Loading savestate")

func _on_options_pressed():
	print("Going to options")

func _on_quit_pressed():
	print("Quitting the game")
	get_tree().quit()
