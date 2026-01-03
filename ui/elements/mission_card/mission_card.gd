extends Control

var mission : Mission

signal mission_selected(mission)

func setup(mission_reference):
	mission = mission_reference
	$Panel/MissionName.text = mission_reference.name
	if GameData.mission_data[mission.id].category == "Main":
		$Panel/MissionIcon.texture = load("res://ui/elements/ui_icons_8x8/icon_important.tres")
	elif GameData.mission_data[mission.id].category == "Material":
		$Panel/MissionIcon.texture = load("res://ui/elements/ui_icons_8x8/icon_stick.tres")
	elif GameData.mission_data[mission.id].category == "Rescue":
		$Panel/MissionIcon.texture = load("res://ui/elements/ui_icons_8x8/icon_help.tres")

func _on_button_pressed():
	mission_selected.emit(self)
