extends Resource
class_name DataItem

@export var id : String = "debug_item"
@export var count : int = 1

func random_setup():
	id = GameData.item_data.keys().pick_random()

func setup(item_id):
	id = item_id

func change_count(count_change):
	count += count_change
