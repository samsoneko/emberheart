extends Node

var debug_tiles = [
	Vector2i(0, 3), # terrain
	Vector2i(0, 2), # ground
	Vector2i(1, 1), # dark blue = fluid
	Vector2i(0, 0), # entry
	Vector2i(0, 1), # exit
	Vector2i(1, 3), # item
	Vector2i(1, 0), # red = path
	Vector2i(1, 2), # yellow = path edge
	Vector2i(0, 3), # higher terrain, currently same as normal terrain
]

var tile_dictionary = {
	"ground": Vector2i(1, 2),
	"solid": Vector2i(0, 2),
	"vertical-edge-left": Vector2i(2, 3),
	"vertical-edge-right": Vector2i(3, 2),
	"horizontal-edge-up": Vector2i(2, 2),
	"horizontal-edge-down": Vector2i(3, 3),
	"outer-corner-left-up": Vector2i(0, 0),
	"outer-corner-right-up": Vector2i(1, 0),
	"outer-corner-right-down": Vector2i(1, 1),
	"outer-corner-left-down": Vector2i(0, 1),
	"inner-corner-left-up": Vector2i(2, 0),
	"inner-corner-right-up": Vector2i(3, 0),
	"inner-corner-right-down": Vector2i(3, 1),
	"inner-corner-left-down": Vector2i(2, 1),
	"ground-details": [Vector2i(12, 0), Vector2i(12, 1), Vector2i(12, 2), Vector2i(12, 3), Vector2i(13, 0), Vector2i(13, 1), Vector2i(13, 2), Vector2i(13, 3)]
}

var tileset_offsets = [Vector2i(0, 0), Vector2i(4, 0), Vector2i(8, 0)]

@onready var layers = {
	"ground": $Ground,
	"ground_detail": $GroundDetail,
	"terrain": $Terrain,
	"high_terrain": $Terrain2,
	"terrain_detail": $TerrainDetail,
	"fluid": $Fluid
}

## Renders the entire dungeon grid in debug mode
func render_debug(dungeon_grid):
	for x in range(dungeon_grid.size()):
		for y in range(dungeon_grid[0].size()):
			layers["ground"].set_cell(0 ,Vector2i(x, y) ,0 , debug_tiles[dungeon_grid[x][y]])

## Renders the entire dungeon grid in final mode
func render_final(dungeon_grid, terrain_tileset_id, fluid_tileset_id):
	for layer in layers.values():
		layer.clear()
	tileset_offsets = [Vector2i(0, 0), Vector2i(4, 0), Vector2i(8, 0)]
	# Render background
	for x in range(dungeon_grid.size()):
		for y in range(dungeon_grid[0].size()):
			layers["ground"].set_cell(Vector2i(2*x, 2*y) ,terrain_tileset_id , tileset_offsets.pick_random() + tile_dictionary["ground"])
			layers["ground"].set_cell(Vector2i(2*x+1, 2*y) ,terrain_tileset_id , tileset_offsets.pick_random() + tile_dictionary["ground"])
			layers["ground"].set_cell(Vector2i(2*x, 2*y+1) ,terrain_tileset_id , tileset_offsets.pick_random() + tile_dictionary["ground"])
			layers["ground"].set_cell(Vector2i(2*x+1, 2*y+1) ,terrain_tileset_id , tileset_offsets.pick_random() + tile_dictionary["ground"])
	render_feature(dungeon_grid, GameData.dungeon_tile_ids["terrain"], terrain_tileset_id, layers["terrain"], true) # terrain
	render_feature(dungeon_grid, GameData.dungeon_tile_ids["high_terrain"], terrain_tileset_id, layers["high_terrain"], true) # higher terrain
	render_feature(dungeon_grid, GameData.dungeon_tile_ids["fluid"], fluid_tileset_id, layers["fluid"], false) # water / fluid
	
	# Render ground details at the edge of the terrain
	for x in range(dungeon_grid.size()):
		for y in range(dungeon_grid[0].size()):
			var nine_grid = get_nine_grid(dungeon_grid, [0], x, y)
			
			if (nine_grid[1][0] == 0 || nine_grid[0][1] == 0) && randi_range(0, 2) == 0:
				layers["ground_detail"].set_cell(Vector2i(2*x, 2*y) ,terrain_tileset_id , tile_dictionary["ground-details"].pick_random())
			if (nine_grid[0][1] == 0 || nine_grid[1][2] == 0) && randi_range(0, 2) == 0:
				layers["ground_detail"].set_cell(Vector2i(2*x+1, 2*y) ,terrain_tileset_id , tile_dictionary["ground-details"].pick_random())
			if (nine_grid[1][0] == 0 || nine_grid[2][1] == 0) && randi_range(0, 2) == 0:
				layers["ground_detail"].set_cell(Vector2i(2*x, 2*y+1) ,terrain_tileset_id , tile_dictionary["ground-details"].pick_random())
			if (nine_grid[1][2] == 0 || nine_grid[2][1] == 0) && randi_range(0, 2) == 0:
				layers["ground_detail"].set_cell(Vector2i(2*x+1, 2*y+1) ,terrain_tileset_id , tile_dictionary["ground-details"].pick_random())

func render_feature(dungeon_grid, feature_id, map_id, layer, randomize_grid):
	for x in range(dungeon_grid.size()):
		for y in range(dungeon_grid[0].size()):
			var feature_ids = []
			if feature_id == 0:
				feature_ids = [0, 8]
			else:
				feature_ids = [feature_id]
			var nine_grid = get_nine_grid(dungeon_grid, feature_ids, x, y)
			
			var left_up_grid = [nine_grid[0][0], nine_grid[0][1], nine_grid[1][0], nine_grid[1][1]]
			var right_up_grid = [nine_grid[0][1], nine_grid[0][2], nine_grid[1][1], nine_grid[1][2]]
			var left_down_grid = [nine_grid[1][0], nine_grid[1][1], nine_grid[2][0], nine_grid[2][1]]
			var right_down_grid = [nine_grid[1][1], nine_grid[1][2], nine_grid[2][1], nine_grid[2][2]]
			var random_offset = tileset_offsets.pick_random()
			
			if !randomize_grid:
				tileset_offsets = [Vector2i(0, 0)]
			
			if left_up_grid[3] == 1:
				pass
			elif left_up_grid == [0, 0, 0, 0]:
				layer.set_cell(Vector2i(2*x, 2*y) ,map_id , random_offset + tile_dictionary["solid"])
			elif left_up_grid == [1, 0, 0, 0]:
				layer.set_cell(Vector2i(2*x, 2*y) ,map_id , random_offset + tile_dictionary["inner-corner-left-up"])
			elif left_up_grid == [1, 1, 1, 0] || left_up_grid == [0, 1, 1, 0]:
				layer.set_cell(Vector2i(2*x, 2*y) ,map_id , random_offset + tile_dictionary["outer-corner-left-up"])
			elif left_up_grid == [0, 0, 1, 0] || left_up_grid == [1, 0, 1, 0]:
				layer.set_cell(Vector2i(2*x, 2*y) ,map_id , random_offset + tile_dictionary["vertical-edge-left"])
			elif left_up_grid == [0, 1, 0, 0] || left_up_grid == [1, 1, 0, 0]:
				layer.set_cell(Vector2i(2*x, 2*y) ,map_id , random_offset + tile_dictionary["horizontal-edge-up"])
			
			random_offset = tileset_offsets.pick_random()
			
			if right_up_grid[2] == 1:
				pass
			elif right_up_grid == [0, 0, 0, 0]:
				layer.set_cell(Vector2i(2*x+1, 2*y) ,map_id , random_offset + tile_dictionary["solid"])
			elif right_up_grid == [0, 1, 0, 0]:
				layer.set_cell(Vector2i(2*x+1, 2*y) ,map_id , random_offset + tile_dictionary["inner-corner-right-up"])
			elif right_up_grid == [1, 1, 0, 1] || right_up_grid == [1, 0, 0, 1]:
				layer.set_cell(Vector2i(2*x+1, 2*y) ,map_id , random_offset + tile_dictionary["outer-corner-right-up"])
			elif right_up_grid == [0, 0, 0, 1] || right_up_grid == [0, 1, 0, 1]:
				layer.set_cell(Vector2i(2*x+1, 2*y) ,map_id , random_offset + tile_dictionary["vertical-edge-right"])
			elif right_up_grid == [1, 0, 0, 0] || right_up_grid == [1, 1, 0, 0]:
				layer.set_cell(Vector2i(2*x+1, 2*y) ,map_id , random_offset + tile_dictionary["horizontal-edge-up"])
			
			random_offset = tileset_offsets.pick_random()
			
			if left_down_grid[1] == 1:
				pass
			elif left_down_grid == [0, 0, 0, 0]:
				layer.set_cell(Vector2i(2*x, 2*y+1) ,map_id , random_offset + tile_dictionary["solid"])
			elif left_down_grid == [0, 0, 1, 0]:
				layer.set_cell(Vector2i(2*x, 2*y+1) ,map_id , random_offset + tile_dictionary["inner-corner-left-down"])
			elif left_down_grid == [1, 0, 1, 1] || left_down_grid == [1, 0, 0, 1]:
				layer.set_cell(Vector2i(2*x, 2*y+1) ,map_id , random_offset + tile_dictionary["outer-corner-left-down"])
			elif left_down_grid == [1, 0, 0, 0] || left_down_grid == [1, 0, 1, 0]:
				layer.set_cell(Vector2i(2*x, 2*y+1) ,map_id , random_offset + tile_dictionary["vertical-edge-left"])
			elif left_down_grid == [0, 0, 0, 1] || left_down_grid == [0, 0, 1, 1]:
				layer.set_cell(Vector2i(2*x, 2*y+1) ,map_id , random_offset + tile_dictionary["horizontal-edge-down"])
			
			random_offset = tileset_offsets.pick_random()
			
			if right_down_grid[0] == 1:
				pass
			elif right_down_grid == [0, 0, 0, 0]:
				layer.set_cell(Vector2i(2*x+1, 2*y+1) ,map_id , random_offset + tile_dictionary["solid"])
			elif right_down_grid == [0, 0, 0, 1]:
				layer.set_cell(Vector2i(2*x+1, 2*y+1) ,map_id , random_offset + tile_dictionary["inner-corner-right-down"])
			elif right_down_grid == [0, 1, 1, 1] || right_down_grid == [0, 1, 1, 0]:
				layer.set_cell(Vector2i(2*x+1, 2*y+1) ,map_id , random_offset + tile_dictionary["outer-corner-right-down"])
			elif right_down_grid == [0, 1, 0, 0] || right_down_grid == [0, 1, 0, 1]:
				layer.set_cell(Vector2i(2*x+1, 2*y+1) ,map_id , random_offset + tile_dictionary["vertical-edge-right"])
			elif right_down_grid == [0, 0, 1, 0] || right_down_grid == [0, 0, 1, 1]:
				layer.set_cell(Vector2i(2*x+1, 2*y+1) ,map_id , random_offset + tile_dictionary["horizontal-edge-down"])

func get_nine_grid(dungeon_grid, feature_id, x, y):
	var nine_grid = [[0, 0, 0], [0, 0, 0], [0, 0, 0]]
	for i in range(-1, 2):
		for j in range(-1, 2):
			if x+i < 0 || x+i >= dungeon_grid.size() || y+j < 0 || y+j >= dungeon_grid[0].size():
				nine_grid[j+1][i+1] = 0
			elif dungeon_grid[x+i][y+j] in feature_id:
				nine_grid[j+1][i+1] = 0
			else:
				nine_grid[j+1][i+1] = 1
	return nine_grid
