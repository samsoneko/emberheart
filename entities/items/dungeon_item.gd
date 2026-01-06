extends Node2D

var item_id : String
var scene
var grid_position

# Called when the node enters the scene tree for the first time.
func _ready():
	item_id = GameData.item_data.keys().pick_random()
	$ItemSprite.texture = load(GameData.item_data[item_id].spritePath)

func setup(id, scene_reference, dungeon_position):
	item_id = id
	scene = scene_reference
	grid_position = dungeon_position
