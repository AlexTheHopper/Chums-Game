extends Node

var game_begun := false
var map_size: int = 5
var room_size: float = 40.0
var world_map := {}
var world_grid := []
var world_map_guide := {}
var room_location := Vector2i(map_size, map_size)
var room_history := [room_location]
var in_battle := false
var current_room_node: Node3D
var current_world_num := 1
var rooms: Node3D

var room_lookup: Dictionary[int, Dictionary]
var game_scene: PackedScene = load("res://scenes/general/game.tscn")

func _ready():
	room_lookup = {
		1: {1: load("res://scenes/world/lobby_world_1.tscn"),
				2: load("res://scenes/world/room_world_1.tscn"),
				3: load("res://scenes/world/fountain_room_world_1.tscn"),
				}
			}

func start_game() -> void:
	map_size = 5
	room_size = 40.0
	world_map = {}
	world_grid = []
	world_map_guide = {}
	room_location = Vector2i(map_size, map_size)
	room_history = [room_location]
	in_battle = false
	current_world_num = 1

	#Creates scaffold for world
	if world_map == {}:
		world_grid = get_world_grid(map_size)
		create_world(map_size)
	
	#Creates Player, Lobby, HUD
	get_node("/root").add_child(game_scene.instantiate())
	current_room_node = get_parent().get_node("Game/Rooms/Lobby_World1")
	rooms = get_parent().get_node("Game/Rooms")

	#Sets initial values for some singletons and connects important signals.
	PlayerStats.initialize()
	get_node("/root/Game/HUD").initialize()
	

func get_world_grid(size):
	#2D Array of where actual rooms are in the world
	var corridor_count := int(max(20 + size * size / 2, 5))
	var corridor_lengths := range(2, max(size, 4))
	var walks := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var room_count := int(max(size * size / 2, 1))
	var bounds = [-1, (2 * size) + 1]
	
	#Set all to 0s - no room:
	var grid = []
	for y in range(0, (2 * size) + 1):
		var row = []
		for x in range(0, (2 * size) + 1):
			row.append(0)
		grid.append(row)

	#Start with coridoors:
	var room_points = [Vector2i(size, size), Vector2i(size, size), Vector2i(size, size)]
	#print('starting at: ' + str(room_points[0]))
	#For each corridor:
	for N in range(corridor_count):
		var pos = room_points.pick_random()
		var length = corridor_lengths.pick_random()
		var dir = walks[0]
		walks.append(walks.pop_front())
		#print('At point ' + str(pos) + ' and heading in dir ' + str(dir) + ' for length ' + str(length))
		
		#For each tile:
		for n in range(length):
			grid[pos.x][pos.y] = set_room_type(pos)
			if pos.x + dir.x in bounds or pos.y + dir.y in bounds:
				break
			pos = Vector2i(pos.x + dir.x, pos.y + dir.y)
			
		#Add end of corridor to list of spots:
		if pos not in room_points:
			room_points.append(pos)
			#print('Appending ' + str(pos) + 'to room locs')
			
	#Rooms:
	for N in range(room_count):
		var pos = room_points.pick_random()
		for remove_pos in walks:
			var x_remove = pos.x + remove_pos.x
			var y_remove = pos.y + remove_pos.y
		
			if not x_remove in bounds and not y_remove in bounds:
				grid[x_remove][y_remove] = set_room_type(Vector2i(x_remove, y_remove))
	
	#TESTPRINT:
	for x in range(grid.size() - 1, -1, -1):
		print(grid[x])

	world_map_guide = Functions.astar2d(grid, Vector2i(size, size))
	return(grid)
	
func set_room_type(location: Vector2i) -> int:
	#Percentage to edge of map
	var per: float = Functions.map_range((location - Vector2i(map_size, map_size)).length(), Vector2(0, map_size), Vector2(0, 1))
	if location == Vector2i(map_size, map_size):
		return 1 #Lobby
		
	elif randf() < (per / 8):
		return 3 #Fountain
		
	else:
		return 2 #Normal Room

func create_world(size):
	#Uses the world_grid to construct information about all rooms.	
	for y in range(0, (2 * size) + 1):
		for x in range(0, (2 * size) + 1):
			#This dict only has values for rooms you can enter.
			if world_grid[x][y] != 0:
				world_map[Vector2i(x, y)] = {
										"type": world_grid[x][y],
										"entered": false,
										"activated": false,
										"to_spawn": -1,
										"value": Vector2(x - size, y - size).length(),
										"bell_angle": randf_range(0, 2 * PI),
										"heart_count": 3,
										"chums": [],
										"light_position": Vector3(),
										"decorations": [],
										"has_x_pos": has_door(Vector2(x, y), Vector2(1, 0)),
										"has_x_neg": has_door(Vector2(x, y), Vector2(-1, 0)),
										"has_z_pos": has_door(Vector2(x, y), Vector2(0, 1)),
										"has_z_neg": has_door(Vector2(x, y), Vector2(0, -1))}
	
func has_door(location: Vector2, direction: Vector2) -> bool:
	#Location in gridform
	var bounds = [-1, (2 * map_size) + 1]
	var next_room_loc = location + direction
	
	#No door if on map edge
	if int(next_room_loc.x) in bounds or int(next_room_loc.y) in bounds:
		return false
		
	#No door if 0 in grid
	if world_grid[next_room_loc.x][next_room_loc.y] == 0:
		return false
	
	#Otherwise g2g
	return true
	
func transition_to_level(new_room_location: Vector2i):
	if new_room_location in world_map:
		TransitionScreen.transition(1)
		await TransitionScreen.on_transition_finished
		
		room_location = new_room_location
		print('Now in: ' + str(new_room_location))
		room_history.append(new_room_location)
		
		if current_room_node:
			current_room_node.queue_free()

		#Create new room:
		var new_room = room_lookup[current_world_num][world_map[room_location]["type"]]
		current_room_node = new_room.instantiate()
		rooms.add_child(current_room_node)
	
func reset():
	room_location = Vector2(0, 0)
	room_history = [Vector2(0, 0)]
	game_begun = false
	world_map = {}
	_ready()
	#get_tree().reload_current_scene()
