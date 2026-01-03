extends Node2D

@onready var renderer = $DungeonRenderer
var debug = false

var current_dungeon_config
var dungeon_floors = []
var dungeon_items : Array = []
var dungeon_details : Array = []
var current_floor_index = 0

var floor_turn_counter = 0

func make_turn():
	floor_turn_counter += 1
	print("Turns on current floor: " + str(floor_turn_counter))
	PlayerData.current_stats.hp -= 1
	if Global.show_dungeon_hud:
		Global.ui_manager.dungeon_hud.update_ui()

func end_turn():
	if Global.player.get_player_grid_position() == dungeon_floors[current_floor_index].exit_point:
		print("Reached exit of floor")
		floor_exit_reached()
	elif Global.player.get_player_grid_position() == dungeon_floors[current_floor_index].entry_point:
		print("Reached entry of floor")

func setup(dungeon):
	renderer = $DungeonRenderer
	generate_dungeon(dungeon)
	Global.game_state = Global.GameStates.DUNGEON
	Global.instantiate_ui() # Fix because the CanvasLayer doesnt instantiate in the scene for some reason

func generate_dungeon(dungeon_id):
	current_dungeon_config = GameData.dungeon_data[dungeon_id]
	Global.current_scene = self
	var base_seed = randi()
	if dungeon_id == "debug":
		base_seed = 0
	for i in current_dungeon_config.floors:
		dungeon_floors.append(DungeonGenerator.generate_dungeon_floor(base_seed + i, dungeon_id))
	load_floor(current_floor_index)
	if current_dungeon_config.has("dungeon_ost"):
		AudioManager.start_ost(current_dungeon_config.dungeon_ost)

func load_floor(dungeon_floor):
	# Decide between final and debug render
	if !debug:
		renderer.render_final(dungeon_floors[dungeon_floor].grid, current_dungeon_config.terrain_id, current_dungeon_config.fluid_id)
		Global.show_dungeon_hud = true
	else:
		renderer.render_debug(dungeon_floors[dungeon_floor].grid)
		Global.show_dungeon_hud = false
	Global.ui_manager.update_ui()
	# Remove previous details and items
	for item in dungeon_items:
		item.queue_free()
	for detail in dungeon_details:
		detail.queue_free()
	dungeon_items = []
	dungeon_details = []
	# Instantiate new items and details
	instatiate_dungeon_items()
	instantiate_dungeon_details()
	# Place entry and exit
	$Entry.position = grid_to_world_position(dungeon_floors[dungeon_floor].entry_point)
	$Exit.position = grid_to_world_position(dungeon_floors[dungeon_floor].exit_point)
	# Place the player
	place_player()

func _input(event):
	## Debug: Jumps to next level if 
	if event.is_action_pressed("debug_skip"):
		floor_exit_reached()

func floor_exit_reached():
	# Check if the next floor should be loaded, or if the dungeon has been finished
	if current_floor_index + 1 >= current_dungeon_config.floors:
		get_tree().change_scene_to_file("res://debug/debug_map.tscn")
		if current_dungeon_config.has("dungeon_ost"):
			AudioManager.stop_ost(current_dungeon_config.dungeon_ost)
	else:
		advance_to_next_floor()

func advance_to_next_floor():
	if current_floor_index + 1 >= current_dungeon_config.floors:
		return
	current_floor_index += 1
	floor_turn_counter = 0
	load_floor(current_floor_index)

func place_player():
	Global.player.set_player_grid_position(dungeon_floors[current_floor_index].entry_point)
	Global.player.set_player_position(grid_to_world_position(dungeon_floors[current_floor_index].entry_point))
	#Global.player.show_darkness()
	print("Setting player to entry point")

func instatiate_dungeon_items():
	for item_location in dungeon_floors[current_floor_index].dungeon_item_locations:
		var item_resource = load("res://entities/items/world_item.tscn")
		var item = item_resource.instantiate()
		item.position = grid_to_world_position(item_location)
		item.setup(GameData.item_data.keys().pick_random(), self, item_location)
		renderer.add_child(item)
		dungeon_items.append(item)
	print("items instantiated")

func instantiate_dungeon_details():
	for large_detail_location in dungeon_floors[current_floor_index].dungeon_large_detail_locations:
		var detail_resource = load("res://world/dungeon/dungeon_detail.tscn")
		var detail = detail_resource.instantiate()
		detail.setup("large", current_dungeon_config)
		detail.position = grid_to_world_position(large_detail_location)
		renderer.add_child(detail)
		dungeon_details.append(detail)
	for small_detail_location in dungeon_floors[current_floor_index].dungeon_small_detail_locations:
		var detail_resource = load("res://world/dungeon/dungeon_detail.tscn")
		var detail = detail_resource.instantiate()
		detail.setup("small", current_dungeon_config)
		detail.position = grid_to_world_position(small_detail_location)
		renderer.add_child(detail)
		dungeon_details.append(detail)
	print("details instantiated")

func remove_item(item):
	dungeon_items.remove_at(dungeon_items.find(item))

func is_position_free(pos : Vector2i):
	return dungeon_floors[current_floor_index].grid[pos.x][pos.y] != GameData.dungeon_tile_ids["wall"] && dungeon_floors[current_floor_index].grid[pos.x][pos.y] != GameData.dungeon_tile_ids["fluid"]

func grid_to_world_position(grid_pos : Vector2i):
	return grid_pos * GameData.cell_size
