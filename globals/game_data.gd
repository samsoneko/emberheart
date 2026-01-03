extends Node
# Global script holding static information about the game to provide at runtime

const cell_size : int = 16

var item_data : Dictionary
var dungeon_data : Dictionary
var dialogue_data : Dictionary

const dungeon_tile_ids = {
	"wall": 0,
	"ground": 1,
	"fluid": 2,
	"entry": 3,
	"exit": 4,
	"item": 5,
	"path": 6,
	"path_corner": 7,
}

const mission_data = {
	0 : {
		"name" : "Main Mission",
		"category" : "Main",
		"description" : "A debug main mission with an extremely long text that can probably not be displayed",
	},
	1 : {
		"name" : "Material Mission",
		"category" : "Material",
		"description" : "A debug material mission",
	},
	2 : {
		"name" : "Rescue Mission",
		"category" : "Rescue",
		"description" : "A debug rescue mission",
	},
}

func load():
	item_data = load_json("res://globals/game_data/item_data.json")
	dungeon_data = load_json("res://globals/game_data/dungeon_data.json")
	dialogue_data = load_json("res://globals/game_data/dialogue_data.json")

func load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if data is Dictionary:
		return data
	else:
		return null
