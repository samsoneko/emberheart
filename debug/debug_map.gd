extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.game_state = Global.GameStates.OVERWORLD
	Global.current_scene = self
	Global.show_dungeon_hud = false
	Global.ui_manager.update_ui()

func identify():
	return Global.SceneTypes.OVERWORLD
