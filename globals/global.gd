extends Node
# Topmost global script, responsible for handling communication and systemwide referencing
var debug = false

# Nodes for accessing other game objects
var player : Node
var current_scene : Node
var ui_manager : Node

# Settings for the movement
enum MovementTypes {NONE, DEBUG, FREE, GRID}
var player_movement_type:
	get:
		if game_state == GameStates.OVERWORLD && !ui_open:
			return MovementTypes.FREE
		elif game_state == GameStates.DUNGEON && !ui_open:
			return MovementTypes.GRID
		elif debug == true:
			return MovementTypes.DEBUG
		else:
			return MovementTypes.NONE

# Global enum for managing game behaviour
enum GameStates {CUTSCENE, OVERWORLD, DUNGEON}
var game_state = GameStates.OVERWORLD
var ui_open:
	get:
		return ui_manager.open_ui != "none"

var show_dungeon_hud = false

func register_player(node):
	player = node

func register_ui(node):
	ui_manager = node

func setup_debug_game():
	GameData.load()
	PlayerData.setup_new_data()

func instantiate_ui():
	var ui_scene = load("res://ui/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	current_scene.add_child(ui_instance)

func modify_theme(color):
	var default = load("res://ui/theme/default_theme.tres")
	default.get_stylebox("panel", "Panel").modulate_color = color
	default.get_stylebox("panel", "InteractPanel").modulate_color = color
	default.get_stylebox("panel", "TextBackgroundPanel").modulate_color = color
	default.get_stylebox("focus", "Button").modulate_color = color
	default.get_stylebox("hover", "Button").modulate_color = color
	default.get_stylebox("normal", "Button").modulate_color = color
	default.get_stylebox("pressed", "Button").modulate_color = color
	default.get_stylebox("grabber", "VScrollBar").modulate_color = color
	default.get_stylebox("grabber_highlight", "VScrollBar").modulate_color = color
	default.get_stylebox("grabber_pressed", "VScrollBar").modulate_color = color
	default.get_stylebox("scroll", "VScrollBar").modulate_color = color
	default.get_stylebox("scroll_focus", "VScrollBar").modulate_color = color
