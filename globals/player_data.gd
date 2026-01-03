extends Node
# Global script for holding player data during runtime

var items : Array[DataItem]
var spirits : Array[Spirit]
var missions : Array[Mission]

var current_stats = {
	"hp" = 0,
	"ap" = 0,
	"attack" = 0,
	"defence" = 0
}

var max_stats = {
	"hp" = 20,
	"ap" = 10,
	"attack" = 5,
	"defence" = 5
}

func setup_new_data():
	for i in range(16):
		add_random_item()
	for i in range(20):
		add_random_spirit()
	for i in range(20):
		add_random_mission()
	max_stats.hp = 20
	max_stats.ap = 10
	max_stats.attack = 5
	max_stats.defence = 5
	heal()

func heal():
	for stat in max_stats.keys():
		current_stats[stat] = max_stats[stat]

#Spirits
func add_spirit(spirit):
	spirits.append(spirit)

func add_random_spirit():
	var spirit = Spirit.new()
	spirit.random_spirit_setup()
	spirits.append(spirit)

func remove_spirit(spirit):
	spirits.remove_at(spirits.find(spirit))

#Items
func add_item(item_id):
	if get_item_by_id(item_id) != null:
		get_item_by_id(item_id).change_count(1)
	else:
		var item = DataItem.new()
		item.setup(item_id)
		items.append(item)

func add_random_item():
	var item_id = GameData.item_data.keys().pick_random()
	if get_item_by_id(item_id) != null:
		get_item_by_id(item_id).change_count(1)
	else:
		var item = DataItem.new()
		item.setup(item_id)
		items.append(item)

func get_item_by_id(item_id):
	for item in items:
		if item.id == item_id:
			return item
	return null

func remove_item(item_id):
	if get_item_by_id(item_id) != null:
		if get_item_by_id(item_id).count >= 2:
			get_item_by_id(item_id).change_count(-1)
		else:
			items.remove_at(items.find(get_item_by_id(item_id)))

#Missions
func add_mission(mission):
	missions.append(mission)

func add_random_mission():
	var mission = Mission.new()
	mission.random_mission_setup()
	missions.append(mission)

func get_mission_by_id(mission_id):
	for mission in missions:
		if mission.id == mission_id:
			return mission
	return null

func remove_mission(mission):
	missions.remove_at(missions.find(mission))
