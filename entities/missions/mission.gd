extends Resource
class_name Mission

@export var id : int
@export var status : String
@export var name : String

func random_mission_setup():
	id = randi_range(0, GameData.mission_data.size()-1)
	name = GameData.mission_data[id].name
	var status_array = ["Active", "Completed", "Failed"]
	status = status_array[randi_range(0, 2)]

func setup_with_details(setup_id):
	id = setup_id
	name = GameData.mission_data[id].name
	var status_array = ["Active", "Completed", "Failed"]
	status = status_array[randi_range(0, 2)]
