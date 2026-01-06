extends Node2D

var generation_params = {
	"fluid_frequency" : 0.05, # Smaller values mean larger fluid spots
	"fluid_threshold" : 0.3, # Smaller means more fluid
	"high_terrain_frequency" : 0.05, # Smaller values mean larger terrain spots
	"high_terrain_threshold" : 0.3, # Smaller means more terrain
	"item_probability" : 50,
	"max_num_rooms" : 8, # Do not set to 1, otherwise infinite recursion occurs, because the pathbuilder tries to find a partner room different from the selected one
	"max_num_1_tile_rooms" : 4, # Do not set to 1, otherwise infinite recursion occurs, because the pathbuilder tries to find a partner room different from the selected one
	"grid_width" : 118,
	"grid_height" : 83
}

# Terrain generation parameters
var min_room_radius = 3
var max_room_radius = 7
var room_to_border_margin = 24 # Margin that a new room needs to have from the border of the grid
var room_to_room_margin = 1
var entry_exit_placement_margin = 2 # Margin that entry and exit need to have from the border of their room, should not be larger than the room min radius

# Floor setup
var seed_generator = RandomNumberGenerator.new()
var terrain_rng = RandomNumberGenerator.new()
var item_rng = RandomNumberGenerator.new()
var detail_rng = RandomNumberGenerator.new()
var noise_gen = FastNoiseLite.new()
var dungeon_floor

# Generates a single dungeon floor
func generate_dungeon_floor(dungeon_seed, dungeon_id):
	dungeon_floor = DungeonFloor.new()
	# Set up the random number generators
	seed_generator.seed = dungeon_seed
	terrain_rng.seed = seed_generator.randi()
	item_rng.seed = seed_generator.randi()
	detail_rng.seed = seed_generator.randi()
	noise_gen.seed = seed_generator.randi()
	
	if GameData.dungeon_data[dungeon_id].has("generation_params"):
		print("loaded generation params")
		generation_params = GameData.dungeon_data[dungeon_id].generation_params
	instatiate_empty_grid()
	generate_grid()
	return dungeon_floor

## Generates the dungeon floor in an empty grid
func generate_grid():
	reset_dungeon()
	for n in generation_params.max_num_rooms:
		generate_room()
	for m in generation_params.max_num_1_tile_rooms:
		generate_one_tile_room()
	for room in dungeon_floor.rooms:
		generate_path(room)
		#generate_rocks(room)
	for one_tile_room in dungeon_floor.one_tile_rooms:
		generate_one_tile_room_path(one_tile_room)
	generate_item_locations()
	place_entry_and_exit()
	if !check_all_rooms_connected():
		generate_grid()
	generate_fluid()
	generate_high_terrain()
	generate_detail_locations()

## Replaces all grid values with zeros to reset the grid to its initial state
func reset_dungeon():
	dungeon_floor.rooms = []
	dungeon_floor.paths = []
	dungeon_floor.one_tile_rooms = []
	dungeon_floor.dungeon_item_locations = []
	for x in range(generation_params.grid_width):
		for y in range(generation_params.grid_height):
			dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["terrain"]

## Initiates the grid with zeros, indicating a completely filled grid
func instatiate_empty_grid():
	dungeon_floor.grid = []
	for i in generation_params.grid_width:
		dungeon_floor.grid.append([])
		for j in generation_params.grid_height:
			dungeon_floor.grid[i].append(GameData.dungeon_tile_ids["terrain"]) # Set a starter value for each position

## Places a room on the grid, checking that it is within bounds and not within another room
func generate_room():
	var center = Vector2i(terrain_rng.randi_range(0 + room_to_border_margin, generation_params.grid_width-1 - room_to_border_margin), terrain_rng.randi_range(0 + room_to_border_margin, generation_params.grid_height-1 - room_to_border_margin))
	var round_room = terrain_rng.randi_range(0, 1)
	var radius = Vector2i(terrain_rng.randi_range(min_room_radius, max_room_radius), terrain_rng.randi_range(min_room_radius, max_room_radius))
	var room = Room.new()
	room.radius = radius
	room.center = center
	if !check_overlap_room(room):
		dungeon_floor.rooms.append(room)
		for x in range(center.x - radius.x, center.x + radius.x):
			for y in range(center.y - radius.y, center.y + radius.y):
				if x >= 0 && x <= generation_params.grid_width-1 && y >= 0 && y <= generation_params.grid_height-1:
					dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["ground"]
					if round_room == 1:
						if (x == center.x - radius.x && y == center.y - radius.y) || (x == center.x + radius.x - 1 && y == center.y - radius.y) || (x == center.x - radius.x && y == center.y + radius.y - 1) || (x == center.x + radius.x - 1 && y == center.y + radius.y - 1):
							dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["terrain"]
	else:
		generate_room()

## Places a specified number of one-tile-rooms for the grid to feature more paths and dead ends
func generate_one_tile_room():
	var center = Vector2i(terrain_rng.randi_range(0 + room_to_border_margin, generation_params.grid_width-1 - room_to_border_margin), terrain_rng.randi_range(0 + room_to_border_margin, generation_params.grid_height-1 - room_to_border_margin))
	var room = Room.new()
	room.center = center
	if !check_overlap_room(room):
		dungeon_floor.one_tile_rooms.append(room)
		if center.x >= 0 && center.x <= generation_params.grid_width-1 && center.y >= 0 && center.y <= generation_params.grid_height-1:
			dungeon_floor.grid[center.x][center.y] = GameData.dungeon_tile_ids["ground"]
	else:
		generate_one_tile_room()

## Generates a path for each room, connecting it to another randomly chosen room
func generate_path(room):
	var partner = dungeon_floor.rooms[terrain_rng.randi_range(0, dungeon_floor.rooms.size()-1)]
	var point_0 = Vector2i(room.center.x, partner.center.y)
	var point_1 = Vector2i(partner.center.x, room.center.y)
	
	if terrain_rng.randi_range(0, 1) == 0:
		for x in range(mini(point_0.x, partner.center.x), maxi(point_0.x, partner.center.x)):
			dungeon_floor.grid[x][point_0.y] = GameData.dungeon_tile_ids["path"]
		for y in range(mini(point_0.y, room.center.y), maxi(point_0.y, room.center.y)):
			dungeon_floor.grid[point_0.x][y] = GameData.dungeon_tile_ids["path"]
		dungeon_floor.grid[point_0.x][point_0.y] = GameData.dungeon_tile_ids["path_corner"]
	else: 
		for x in range(mini(point_1.x, room.center.x), maxi(point_1.x, room.center.x)):
			dungeon_floor.grid[x][point_1.y] = GameData.dungeon_tile_ids["path"]
		for y in range(mini(point_1.y, partner.center.y), maxi(point_1.y, partner.center.y)):
			dungeon_floor.grid[point_1.x][y] = GameData.dungeon_tile_ids["path"]
		dungeon_floor.grid[point_1.x][point_1.y] = GameData.dungeon_tile_ids["path_corner"]
	
	if partner == room:
		generate_path(room)
	else:
		dungeon_floor.paths.append([room, partner])


func generate_one_tile_room_path(one_tile_room):
	var partner = dungeon_floor.rooms[terrain_rng.randi_range(0, dungeon_floor.rooms.size()-1)]
	var point_0 = Vector2i(one_tile_room.center.x, partner.center.y)
	var point_1 = Vector2i(partner.center.x, one_tile_room.center.y)
	
	if terrain_rng.randi_range(0, 1) == 0:
		for x in range(mini(point_0.x, partner.center.x), maxi(point_0.x, partner.center.x)):
			dungeon_floor.grid[x][point_0.y] = GameData.dungeon_tile_ids["path"]
		for y in range(mini(point_0.y, one_tile_room.center.y), maxi(point_0.y, one_tile_room.center.y)):
			dungeon_floor.grid[point_0.x][y] = GameData.dungeon_tile_ids["path"]
		dungeon_floor.grid[point_0.x][point_0.y] = GameData.dungeon_tile_ids["path_corner"]
	else: 
		for x in range(mini(point_1.x, one_tile_room.center.x), maxi(point_1.x, one_tile_room.center.x)):
			dungeon_floor.grid[x][point_1.y] = GameData.dungeon_tile_ids["path"]
		for y in range(mini(point_1.y, partner.center.y), maxi(point_1.y, partner.center.y)):
			dungeon_floor.grid[point_1.x][y] = GameData.dungeon_tile_ids["path"]
		dungeon_floor.grid[point_1.x][point_1.y] = GameData.dungeon_tile_ids["path_corner"]
	
	if partner == one_tile_room:
		generate_path(one_tile_room)
	else:
		dungeon_floor.paths.append([one_tile_room, partner])

## Checks if all rooms are connected
## Necessary to guarantee that the exit can be reached from the entry
func check_all_rooms_connected():
	var test_rooms = []
	var visited_rooms = []
	var test_paths = []
	var room_counter = 0
	for room in dungeon_floor.rooms:
		test_rooms.append(room_counter)
		visited_rooms.append(false)
		room_counter += 1
	for path in dungeon_floor.paths:
		test_paths.append([test_rooms[dungeon_floor.rooms.find(path[0])], test_rooms[dungeon_floor.rooms.find(path[1])]])
	print("Rooms: " + str(test_rooms))
	print("paths: " + str(test_paths))
	get_all_connected_rooms(test_paths, test_rooms[0], visited_rooms)
	for entry in visited_rooms:
		if entry == false:
			return false
	return true

## Recursively go through all rooms and document which are connected
func get_all_connected_rooms(test_paths, room, visited_rooms):
	visited_rooms[room] = true
	for i in range(test_paths.size()):
		if room == test_paths[i][0]:
			var connected_room = test_paths[i][1]
			if visited_rooms[connected_room] == false:
				get_all_connected_rooms(test_paths, connected_room, visited_rooms)
		elif room == test_paths[i][1]:
			var connected_room = test_paths[i][0]
			if visited_rooms[connected_room] == false:
				get_all_connected_rooms(test_paths, connected_room, visited_rooms)

## Generates spots where dungeon items are placed on the grid
func generate_item_locations():
	for x in range(generation_params.grid_width):
		for y in range(generation_params.grid_height):
			if dungeon_floor.grid[x][y] == 1 && item_rng.randi_range(0, generation_params.item_probability) == 0:
				dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["item"]
				dungeon_floor.dungeon_item_locations.append(Vector2i(x, y))


func generate_detail_locations():
	for x in range(generation_params.grid_width):
		for y in range(generation_params.grid_height):
			var placement_possible = true
			for i in range(-1, 2):
				for j in range(-1, 2):
					if x+i < 0 || x+i >= dungeon_floor.grid.size() || y+j < 0 || y+j >= dungeon_floor.grid[0].size():
						continue
					if dungeon_floor.grid[x+i][y+j] != GameData.dungeon_tile_ids["terrain"]:
						placement_possible = false
			if placement_possible && detail_rng.randi_range(0, 10) == 0:
				dungeon_floor.dungeon_large_detail_locations.append(Vector2i(x, y))
			elif placement_possible && detail_rng.randi_range(0, 5) == 0:
				dungeon_floor.dungeon_small_detail_locations.append(Vector2i(x, y))


func generate_rocks(room):
	for x in range(room.center.x-room.radius.x, room.center.x+room.radius.x):
		for y in range(room.center.y-room.radius.y, room.center.y+room.radius.y):
			var placement_possible = true
			for i in range(-1, 2):
				for j in range(-1, 2):
					if x+i < 0 || x+i >= dungeon_floor.grid.size() || y+j < 0 || y+j >= dungeon_floor.grid[0].size():
						placement_possible = false
					elif dungeon_floor.grid[x+i][y+j] == GameData.dungeon_tile_ids["terrain"]:
						placement_possible = false
			if placement_possible && detail_rng.randi_range(0, 10) == 0:
				dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["terrain"]

## Places the entry and the exit in random rooms on the grid
func place_entry_and_exit():
	#TODO: Fix that the chosen room matches the margin
	var entry_room = dungeon_floor.rooms[terrain_rng.randi_range(0, dungeon_floor.rooms.size()-1)]
	entry_room.is_entry_room = true
	var exit_room = dungeon_floor.rooms[terrain_rng.randi_range(0, dungeon_floor.rooms.size()-1)]
	while exit_room.is_entry_room == true:
		exit_room = dungeon_floor.rooms[terrain_rng.randi_range(0, dungeon_floor.rooms.size()-1)]
	dungeon_floor.entry_point = Vector2i(terrain_rng.randi_range(entry_room.upper_left.x + entry_exit_placement_margin, entry_room.upper_right.x - entry_exit_placement_margin), terrain_rng.randi_range(entry_room.upper_left.y + entry_exit_placement_margin, entry_room.lower_right.y - entry_exit_placement_margin))
	dungeon_floor.grid[clamp(dungeon_floor.entry_point.x, 0, generation_params.grid_width-1)][clamp(dungeon_floor.entry_point.y, 0, generation_params.grid_height-1)] = GameData.dungeon_tile_ids["entry"]
	dungeon_floor.exit_point = Vector2i(terrain_rng.randi_range(exit_room.upper_left.x + entry_exit_placement_margin, exit_room.upper_right.x - entry_exit_placement_margin), terrain_rng.randi_range(exit_room.upper_left.y + entry_exit_placement_margin, exit_room.lower_right.y - entry_exit_placement_margin))
	dungeon_floor.grid[clamp(dungeon_floor.exit_point.x, 0, generation_params.grid_width-1)][clamp(dungeon_floor.exit_point.y, 0, generation_params.grid_height-1)] = GameData.dungeon_tile_ids["exit"]

## Uses FastNoise to place random spots of fluid on the grid
func generate_fluid():
	noise_gen.frequency = generation_params.fluid_frequency
	for x in range(generation_params.grid_width):
		for y in range(generation_params.grid_height):
			if dungeon_floor.grid[x][y] == 0 && noise_gen.get_noise_2d(x, y) >= generation_params.fluid_threshold:
				dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["fluid"]

## Uses FastNoise to place random spots of higher terrain on the grid
func generate_high_terrain():
	noise_gen.frequency = generation_params.high_terrain_frequency
	for x in range(1, generation_params.grid_width - 1):
		for y in range(1, generation_params.grid_height - 1):
			if dungeon_floor.grid[x][y] == 0 && noise_gen.get_noise_2d(x, y) >= generation_params.high_terrain_threshold:
				var suitable_spot = true
				for i in range(-1, 2):
					for j in range(-1, 2):
						if dungeon_floor.grid[x+i][y+j] != 0 && dungeon_floor.grid[x+i][y+j] != 8:
							suitable_spot = false
				if suitable_spot:
					dungeon_floor.grid[x][y] = GameData.dungeon_tile_ids["high_terrain"]


## Checks if the room with the specified dimensions is inside of another room already placed on the grid
func check_overlap_room(new_room : Room):
	for room in dungeon_floor.rooms:
		for tile_x in range(new_room.center.x-new_room.radius.x, new_room.center.x+new_room.radius.x):
			for tile_y in range(new_room.center.y-new_room.radius.y, new_room.center.y+new_room.radius.y):
				if tile_x >= room.upper_left.x - room_to_room_margin && tile_y >= room.upper_left.y - room_to_room_margin && tile_x <= room.lower_right.x + room_to_room_margin && tile_y <= room.lower_right.y + room_to_room_margin:
					return true
	return false

## Class for holding information about a generated room
class Room:
	var radius := Vector2i(0, 0)
	var center := Vector2i(0, 0)
	var is_entry_room := false
	
	var lower_left:
		get:
			return center + Vector2i(-radius.x, radius.y)
	var upper_right:
		get:
			return center + Vector2i(radius.x, -radius.y)
	var lower_right:
		get:
			return center + Vector2i(radius.x, radius.y)
	var upper_left:
		get:
			return center + Vector2i(-radius.x, -radius.y)

# Class for holding the dungeon floor information
class DungeonFloor:
	var grid = []
	var rooms = []
	var one_tile_rooms = []
	var paths = []
	
	var entry_point : Vector2i
	var exit_point : Vector2i
	var dungeon_item_locations = []
	var dungeon_large_detail_locations = []
	var dungeon_small_detail_locations = []
