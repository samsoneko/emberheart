extends Node2D

# Called when the node enters the scene tree for the first time.
func setup(type, dungeon):
	if type == "large" && dungeon.has("details_large"):
		$Sprite2D.texture = load(dungeon["details_large"].pick_random())
	elif type == "small" && dungeon.has("details_small"):
		$Sprite2D.texture = load(dungeon["details_small"].pick_random())
	else:
		$Sprite2D.texture = null
