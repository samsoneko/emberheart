extends MenuPanel

@onready var dungeon_label = $HBoxContainer/LocationContainer/HBoxContainer/DungeonLabel
@onready var floor_label = $HBoxContainer/LocationContainer/HBoxContainer/FloorLabel
@onready var tile_map = $TileMap
@onready var stats_label = $PanelContainer/StatsLabel

var tile_dictionary = {
	"ground": Vector2i(0, 0),
	"player": Vector2i(1, 0),
	"item": Vector2i(0, 1),
	"enemy": Vector2i(1, 1)
}

func update_ui():
	dungeon_label.text = Global.current_scene.current_dungeon_config["name"]
	floor_label.text = "B" + str(Global.current_scene.current_floor_index + 1)
	stats_label.text = str(PlayerData.current_stats.hp) + "HP | " + str(PlayerData.current_stats.ap) + "AP"
	update_minimap()
	update_minimap_entities()
	
func update_minimap():
	tile_map.clear()
	var dungeon_grid = Global.current_scene.dungeon_floors[Global.current_scene.current_floor_index].grid
	for x in range(dungeon_grid.size()):
		for y in range(dungeon_grid[0].size()):
			if(dungeon_grid[x][y] != 0 && dungeon_grid[x][y] != 2): # If grid is neither terrain nor fluid
				tile_map.set_cell(0, Vector2i(x, y), 0, tile_dictionary["ground"])

func update_minimap_entities():
	tile_map.clear_layer(1)
	var player_position = Global.player.get_player_grid_position()
	tile_map.set_cell(1, player_position, 0, tile_dictionary["player"])
	
	if Global.game_state == Global.GameStates.DUNGEON:
		var items = Global.current_scene.dungeon_items
		for item in items:
			tile_map.set_cell(1, item.grid_position, 0, tile_dictionary["item"])
	
