extends Node
var dev_mode = true

var game_begun := false
var world_transition_count := 0
var map_size:int
var room_size:float
var world_map := {}
var world_grid := []
var world_map_guide = {"lobby": {},
						"room": {},
						"fountain": {},
						"void": {},
						"statue": {},
						"upgrade": {},
						}
						

var in_battle := false
var is_alive := true
var current_room_node: Node3D
var current_world_num := 1
var room_location := Vector2i(map_size, map_size)
var room_history: Array
var rooms: Node3D

var room_lookup: Dictionary[int, Dictionary]
var world_info: Dictionary
var game_scene: PackedScene = load("res://scenes/general/game.tscn")
var game_save_id := 1

func _ready():
	room_lookup = {
		#world 0 is the boss rooms, the keys of inner dict are the world you come from.
		0:		{1: load("res://scenes/world/boss_room_world_1.tscn"),
				2: load("res://scenes/world/boss_room_world_2.tscn"),
				},
				
		1:		{1: load("res://scenes/world/lobby_world_1.tscn"),
				2: load("res://scenes/world/room_world_1.tscn"),
				3: load("res://scenes/world/fountain_room_world_1.tscn"),
				4: load("res://scenes/world/void_room_world_1.tscn"),
				5: load("res://scenes/world/statue_room_world_1.tscn"),
				6: load("res://scenes/world/upgrade_room_world_1.tscn"),
				},
				
		2:		{1: load("res://scenes/world/lobby_world_2.tscn"),
				2: load("res://scenes/world/room_world_2.tscn"),
				3: load("res://scenes/world/fountain_room_world_2.tscn"),
				4: load("res://scenes/world/void_room_world_2.tscn"),
				5: load("res://scenes/world/statue_room_world_2.tscn"),
				6: load("res://scenes/world/upgrade_room_world_2.tscn"),
				},
			}
	#required and optional are the statue chum ids. To be super safe only rely on the last entry in required.
	#Max chums needs to be AT LEAST 4, or change room.gd
	world_info = {
		0: {'map_size': 3,
			"room_size": 40.0,
			"max_chums": 100,
			"required": [1],  #To 1, redundant
			"optional": [1]}, #To 1, redundant
			
		1: {'map_size': 3,
			"room_size": 40.0,
			"max_chums": 5,
			"required": [4], 					   #To world 2
			"optional": [1, 2, 3, 4, 5, 6, 7, 8]}, #To worlds 1, 2
		
		2: {'map_size': 5,
			"room_size": 40.0,
			"max_chums": 8,
			"required": [1, 2, 4, 3],  #To worlds 1, 2
			"optional": [1, 2, 3, 4]}, #To worlds 1, 2
	}

func start_game(save_id = null, new_game = false) -> void:
	if save_id != null:
		game_save_id = save_id
	in_battle = false
	current_world_num = 1
	
	map_size = world_info[current_world_num]["map_size"]
	room_size = world_info[current_world_num]["room_size"]
	world_map = {}
	world_grid = []
	world_map_guide = {"lobby": {},
						"room": {},
						"fountain": {},
						"void": {},
						"statue": {},
						"upgrade": {},
						}
						
	room_location = Vector2i(map_size, map_size)
	room_history = [[current_world_num, room_location]]
	
	#Creates scaffold for world
	if world_map == {} or new_game == true:
		world_grid = get_world_grid(current_world_num)
		create_world(current_world_num)
	
	#Creates Player, Lobby, HUD
	get_node("/root").add_child(game_scene.instantiate())
	var lobby_room = room_lookup[current_world_num][1].instantiate()
	get_node("/root/Game/Rooms").add_child(lobby_room)
	current_room_node = lobby_room
	rooms = get_parent().get_node("Game/Rooms")
	
	#Sets initial values for some singletons and connects important signals.
	PlayerStats.initialize()
	get_node("/root/Game/HUD").initialize()
	
	if new_game == false:
		SaverLoader.load_game(save_id)
		
		if Global.dev_mode:
			print('In world %s, room %s.' % [Global.current_world_num, str(room_location)])
		
		if current_room_node:
			current_room_node.queue_free()

		#Create new room:
		if current_world_num == 0:
			var new_room = room_lookup[current_world_num][room_location[0]]
			current_room_node = new_room.instantiate()
			rooms.add_child(current_room_node)
		else:
			var new_room = room_lookup[current_world_num][world_map[room_location]["type"]]
			current_room_node = new_room.instantiate()
			rooms.add_child(current_room_node)

	if Global.dev_mode:
		for x in range(world_grid.size() - 1, -1, -1):
			print(world_grid[x])


func get_world_grid(world_n):
	var size = world_info[world_n]["map_size"]
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
	#For each corridor:
	for N in range(corridor_count):
		var pos = room_points.pick_random()
		var length = corridor_lengths.pick_random()
		var dir = walks[0]
		walks.append(walks.pop_front())

		#For each tile:
		for n in range(length):
			grid[pos.x][pos.y] = set_room_type(pos)
			if pos.x + dir.x in bounds or pos.y + dir.y in bounds:
				break
			pos = Vector2i(pos.x + dir.x, pos.y + dir.y)
			
		#Add end of corridor to list of spots:
		if pos not in room_points:
			room_points.append(pos)
			
	#Rooms:
	for N in range(room_count):
		var pos = room_points.pick_random()
		grid[pos.x][pos.y] = set_room_type(Vector2i(pos.x, pos.y))
		for remove_pos in walks:
			var x_remove = pos.x + remove_pos.x
			var y_remove = pos.y + remove_pos.y
		
			if not x_remove in bounds and not y_remove in bounds:
				grid[x_remove][y_remove] = set_room_type(Vector2i(x_remove, y_remove))
		
	#Must have that at least one of each room type is present.
	#Mainly for the world_map_guide
	#this is a bit sloopy, maybe TODO later.
	#especially since it starts as 5,5 to ensure at least 3 statue rooms.
	var room_missing = [5, 5]
	var rooms_replace = []
	for n in room_lookup[world_n].keys():
		var exists = false
		for y in grid.size():
			for x in grid[0].size():

				if grid[x][y] == 2:
					rooms_replace.append(Vector2i(x, y))
				if grid[x][y] == n:
					exists = true

		if not exists:
			room_missing.append(n)
	#Replace some normal rooms with the missing:
	rooms_replace.shuffle()
	for add_type in room_missing:
		grid[rooms_replace[-1][0]][rooms_replace[-1][1]] = add_type
		rooms_replace.pop_back()

	world_map_guide["lobby"] = Functions.astar2d(grid, 1)
	world_map_guide["room"] = Functions.astar2d(grid, 2)
	world_map_guide["fountain"] = Functions.astar2d(grid, 3)
	world_map_guide["void"] = Functions.astar2d(grid, 4)
	world_map_guide["statue"] = Functions.astar2d(grid, 5)
	world_map_guide["upgrade"] = Functions.astar2d(grid, 6)
	return(grid)
	
func set_room_type(location: Vector2i) -> int:
	#Percentage to edge of map
	var per: float = Functions.map_range((location - Vector2i(map_size, map_size)).length(), Vector2(0, map_size), Vector2(0, 1))
	if location == Vector2i(map_size, map_size):
		return 1 #Lobby
		
	elif randf() < (per / 9):
		if randf() < 0.7:
			return 3 #Fountain
		elif randf() < 0.5:
			return 6 # Upgrade
		elif randf() < 0.7:
			return 5 # Statue
		else:
			return 4 #Void Pit
		
	else:
		return 2 #Normal Room

func create_world(world_n):
	var size = world_info[world_n]["map_size"]
	var required_statues = world_info[world_n]["required"]
	var other_statues = world_info[world_n]["optional"]
	var statue_id = 1
	world_map = {}
	#Uses the world_grid to construct information about all rooms.
	for y in range(0, (2 * size) + 1):
		for x in range(0, (2 * size) + 1):
			#This dict only has values for rooms you can enter.
			#All rooms are assigned a statue id, but ensured that required statues are in the world.
			statue_id = other_statues.pick_random()
			if world_grid[x][y] == 5 and len(required_statues) > 0:
				statue_id = required_statues.pop_back()
				
			if world_grid[x][y] != 0:
				world_map[Vector2i(x, y)] = {
										"type": world_grid[x][y],
										"entered": false,
										"activated": false,
										"to_spawn": -1,
										"value": Vector2(x - size, y - size).length(),
										"bell_angle": [0, PI / 2, PI, -PI / 2].pick_random(),
										"item_count": 3,
										"light_position": Vector3(),
										"statue_id": statue_id,
										"statue_activated": false,
										"has_x_pos": has_door(Vector2(x, y), Vector2(1, 0)),
										"has_x_neg": has_door(Vector2(x, y), Vector2(-1, 0)),
										"has_z_pos": has_door(Vector2(x, y), Vector2(0, 1)),
										"has_z_neg": has_door(Vector2(x, y), Vector2(0, -1)),
										"chums": [],
										"decorations": [],
										}
func create_world_boss() -> void:
	#Created boss room information
	world_map = {}
	#There is a boss room defined going from every world to any other world.
	var max_world_n = room_lookup.keys().max()
	for y in range(1, max_world_n + 1):
		for x in range(1, max_world_n + 1):
			world_map[Vector2i(x, y)] = {
										"type": 0,
										"entered": false,
										"activated": false,
										"to_spawn": 0,
										"value": y * 2,
										"bell_angle": 0,
										"item_count": 3,
										"light_position": Vector3(1.0, 0.0, -10.0),
										"statue_id": 1,
										"statue_activated": false,
										"has_x_pos": false,
										"has_x_neg": false,
										"has_z_pos": false,
										"has_z_neg": true,
										"chums": [],
										"decorations": [],
										}


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
	
func transition_to_level(new_room_location: Vector2i, length = 1):
	if new_room_location in world_map:
		TransitionScreen.transition(length)
		await TransitionScreen.on_transition_finished
		current_room_node.save_room()
		
		room_location = new_room_location
		if Global.dev_mode:
			print('Now in world %s, room %s.' % [Global.current_world_num, str(new_room_location)])
		if room_history[-1][1] != new_room_location or room_history[-1][0] != current_world_num:
			room_history.append([current_world_num, new_room_location])
		
		if current_room_node:
			current_room_node.queue_free()

		#Create new room:
		var new_room = room_lookup[current_world_num][world_map[room_location]["type"]]
		current_room_node = new_room.instantiate()
		rooms.add_child(current_room_node)


func transition_to_boss(source_world_n: int, destination_world_n: int, length = 1):
	TransitionScreen.transition(length)
	await TransitionScreen.on_transition_finished
	current_room_node.save_room()
	
	create_world_boss()
	current_world_num = 0
	
	var new_room_location = Vector2i(source_world_n, destination_world_n)
	room_location = new_room_location
	if Global.dev_mode:
		print('Now in world %s, room %s.' % [Global.current_world_num, str(new_room_location)])

	if room_history[-1][1] != new_room_location or room_history[-1][0] != current_world_num:
			room_history.append([current_world_num, new_room_location])
	
	if current_room_node:
		current_room_node.queue_free()

	#Create new room:
	var new_room = room_lookup[0][new_room_location[0]] #Go to boss room of the world you came from.
	current_room_node = new_room.instantiate()
	rooms.add_child(current_room_node)
	

func transition_to_world(destination_world_n: int, length = 1):
	TransitionScreen.transition(length)
	await TransitionScreen.on_transition_finished
	current_room_node.save_room()
	
	current_world_num = destination_world_n
	world_transition_count += 1
	map_size = world_info[current_world_num]["map_size"]
	room_size = world_info[current_world_num]["room_size"]
	
	world_grid = get_world_grid(current_world_num)
	
	if Global.dev_mode:
		for x in range(world_grid.size() - 1, -1, -1):
			print(world_grid[x])
	create_world(current_world_num)
	
	var new_room_location = Vector2i(map_size, map_size)
	room_location = new_room_location
	print('Now in world %s, room %s.' % [Global.current_world_num, str(new_room_location)])

	if room_history[-1][1] != new_room_location or room_history[-1][0] != current_world_num:
			room_history.append([current_world_num, new_room_location])
	
	if current_room_node:
		current_room_node.queue_free()

	#Create new room:
	var new_room = room_lookup[current_world_num][world_map[room_location]["type"]]
	current_room_node = new_room.instantiate()
	rooms.add_child(current_room_node)


func return_to_menu(delete = false):
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	is_alive = true
	call_deferred("restart_game_and_delete", delete)

func restart_game_and_delete(delete):
	get_node("/root/Game").queue_free()
	if delete:
		SaverLoader.delete_save(game_save_id)
	game_begun = false
	game_save_id = 1
	get_node("/root").add_child(load("res://scenes/general/main_menu.tscn").instantiate())
