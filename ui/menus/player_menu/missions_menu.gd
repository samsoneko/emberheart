extends MenuPanel

var mission_card_resource = preload("res://ui/elements/mission_card/mission_card.tscn")
@onready var mission_tab_buttons = [$MissionsPanel/HBoxContainer/AllMissions, $MissionsPanel/HBoxContainer/ActiveMissions, $MissionsPanel/HBoxContainer/CompletedMissions, $MissionsPanel/HBoxContainer/FailedMissions]
var selected_mission
var mission_type_shown

# Called when the node enters the scene tree for the first time.
func _ready():
	$DetailPanel.hide()

func update_ui():
	update_missions("all")
	update_mission_buttons($MissionsPanel/HBoxContainer/AllMissions)
	$MissionsPanel/HBoxContainer/AllMissions.grab_focus()

func ready_to_close():
	if selected_mission == null:
		return true
	else:
		return false

func close_layer():
	if selected_mission != null:
		close_details_panel()

func update_missions(mission_type):
	mission_type_shown = mission_type
	for mission in $MissionsPanel/ScrollContainer/MissionList.get_children():
		mission.queue_free()
	for mission in PlayerData.missions:
		if mission_type_shown == "all":
			var mission_card = mission_card_resource.instantiate()
			mission_card.setup(mission)
			mission_card.mission_selected.connect(open_details_panel)
			$MissionsPanel/ScrollContainer/MissionList.add_child(mission_card)
		elif mission.status == mission_type_shown:
			var mission_card = mission_card_resource.instantiate()
			mission_card.setup(mission)
			mission_card.mission_selected.connect(open_details_panel)
			$MissionsPanel/ScrollContainer/MissionList.add_child(mission_card)
	if selected_mission != null && PlayerData.get_mission_by_id(selected_mission.id) == null:
		close_details_panel()

func close_details_panel():
	$DetailPanel.hide()
	if mission_type_shown == "all":
		$MissionsPanel/HBoxContainer/AllMissions.grab_focus()
	if mission_type_shown == "Active":
		$MissionsPanel/HBoxContainer/ActiveMissions.grab_focus()
	if mission_type_shown == "Completed":
		$MissionsPanel/HBoxContainer/CompletedMissions.grab_focus()
	if mission_type_shown == "Failed":
		$MissionsPanel/HBoxContainer/FailedMissions.grab_focus()
	selected_mission = null

func update_mission_buttons(active_button):
	for button in mission_tab_buttons:
		if button != active_button:
			button.button_pressed = false
		else:
			button.button_pressed = true

func open_details_panel(mission_card):
	$DetailPanel.show()
	selected_mission = mission_card.mission
	$DetailPanel/DetailTitlePanel/Title.text = GameData.mission_data[selected_mission.id].name
	$DetailPanel/Category.text = GameData.mission_data[selected_mission.id].category
	$DetailPanel/Description.text = GameData.mission_data[selected_mission.id].description
	$DetailPanel/ActionPanel/UseButton.grab_focus()

func _on_all_missions_pressed():
	update_missions("all")
	update_mission_buttons($MissionsPanel/HBoxContainer/AllMissions)

func _on_active_missions_pressed():
	update_missions("Active")
	update_mission_buttons($MissionsPanel/HBoxContainer/ActiveMissions)

func _on_completed_missions_pressed():
	update_missions("Completed")
	update_mission_buttons($MissionsPanel/HBoxContainer/CompletedMissions)

func _on_failed_missions_pressed():
	update_missions("Failed")
	update_mission_buttons($MissionsPanel/HBoxContainer/FailedMissions)
