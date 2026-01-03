extends MenuPanel

func update_ui():
	for dungeon_select_button in $MainPanel/ScrollContainer/VBoxContainer.get_children():
		dungeon_select_button.queue_free()
	var dungeons = GameData.dungeon_data
	for i in range(dungeons.keys().size()):
		var dungeon = dungeons.keys()[i]
		var dungeon_select_button = Button.new()
		dungeon_select_button.text = dungeons[dungeon].name
		$MainPanel/ScrollContainer/VBoxContainer.add_child(dungeon_select_button)
		dungeon_select_button.pressed.connect(dungeon_selected.bind(dungeon))
		if i == 0:
			dungeon_select_button.grab_focus()

func dungeon_selected(dungeon):
	print(dungeon)
	# Freeing the current scene
	get_tree().current_scene.queue_free()
	# Instantiating the new scene
	var dungeon_scene = preload("res://world/dungeon/dungeon.tscn").instantiate()
	get_tree().root.add_child(dungeon_scene)
	get_tree().set_current_scene(dungeon_scene)
	dungeon_scene.setup(dungeon)
