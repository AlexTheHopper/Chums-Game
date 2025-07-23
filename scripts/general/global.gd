extends Node
var dev_mode = true

var game_begun := false
var world_transition_count := 0
var map_size:int
var room_size:float
var world_map := {}
var world_grid := []
var viewed_lore := []
var save_seed: int
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
var world_info: Dictionary
var game_scene: PackedScene = load("res://scenes/general/game.tscn")
var game_save_id := 1
var player: Player

signal room_changed
signal room_changed_to_boss
signal room_changed_from_boss 

func _ready():
	#required and optional are the statue chum ids. To be super safe only rely on the last entry in required.
	#room_counts are how many of each normal room to replace with that id. They will not replace ones next to the lobby.
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
			"statue_required": [4], 					   #To world 2
			"statue_optional": [1, 2, 3, 4, 5, 6, 7, 8], #To worlds 1, 2
			"room_counts": {	1: 0, #Lobby - keep this as 0
							2: 0, #Normal room - also 0
							3: 3, #Fountain
							4: 2, #Void
							5: 3, #Statue - AT LEAST length of statue_required
							6: 0, #Upgrade
							7: 1, #Lore
							}, 
			},

		2: {'map_size': 5,
			"room_size": 40.0,
			"max_chums": 8,
			"statue_required": [1, 3, 4, 13],  #To worlds 1, 2, 3
			"statue_optional": [5, 8, 4, 4], #To worlds 1, 2
			"room_counts": {	1: 0, #Lobby - keep this as 0
							2: 0, #Normal room - also 0
							3: 6, #Fountain
							4: 5, #Void
							5: 6, #Statue - AT LEAST length of statue_required
							6: 5, #Upgrade
							7: 1, #Lore
							},
			},

		3: {'map_size': 5,
			"room_size": 40.0,
			"max_chums": 10,
			"statue_required": [4, 6, 8],  #To worlds 1, 2
			"statue_optional": [6, 11, 13], #To worlds 1, 2
			"room_counts": {	1: 0, #Lobby - keep this as 0
							2: 0, #Normal room - also 0
							3: 6, #Fountain
							4: 5, #Void
							5: 6, #Statue - AT LEAST length of statue_required
							6: 5, #Upgrade
							7: 1, #Lore
							},
			},
	}

func get_room_tscn(world_n, room_id) -> PackedScene:
	if world_n == 0:
		return load("res://scenes/world/boss_room_world_%s.tscn" % [room_id])
	match room_id:
		1:
			return load("res://scenes/world/lobby_world_%s.tscn" % [world_n])
		2:
			return load("res://scenes/world/room_world_%s.tscn" % [world_n])
		3:
			return load("res://scenes/world/fountain_room_world_%s.tscn" % [world_n])
		4:
			return load("res://scenes/world/void_room_world_%s.tscn" % [world_n])
		5:
			return load("res://scenes/world/statue_room_world_%s.tscn" % [world_n])
		6:
			return load("res://scenes/world/upgrade_room_world_%s.tscn" % [world_n])
		7:
			return load("res://scenes/world/lore_room_world_%s.tscn" % [world_n])

	print("SHOULD NOT REACH HERE - Global.get_room_tscn()")
	return load("res://scenes/world/lobby_world_1.tscn") #Only as backup when room cannot be found.

func start_game(save_id = null, new_game = false) -> void:
	if save_id != null:
		game_save_id = save_id
	in_battle = false
	current_world_num = 1
	save_seed = randi()
	if save_id != null and dev_mode:
		save_seed = save_id
	
	world_map = {}
	world_grid = []
	world_map_guide = {"lobby": {},
						"room": {},
						"fountain": {},
						"void": {},
						"statue": {},
						"upgrade": {},
						}
						

	if new_game:
		#Creates scaffold for world
		map_size = world_info[current_world_num]["map_size"]
		room_size = world_info[current_world_num]["room_size"]
		room_location = Vector2i(map_size, map_size)
		room_history = [[current_world_num, room_location]]
		
		if world_map == {} or new_game == true:
			world_grid = get_world_grid(current_world_num)
			create_world(current_world_num)
			set_world_map_guides()
		
		#Creates Player, Lobby, HUD
		get_node("/root").add_child(game_scene.instantiate())
		player = get_tree().get_first_node_in_group("Player")
		
		#Sets initial values for some singletons and connects important signals.
		PlayerStats.initialize()
		get_node("/root/Game/HUD").initialize()
		
		rooms = get_parent().get_node("Game/Rooms")
		var lobby_room = get_room_tscn(1, 1) #Lobby of world 1
		current_room_node = lobby_room.instantiate()
		rooms.add_child(current_room_node)
	
	else:
		get_node("/root").add_child(game_scene.instantiate())
		player = get_tree().get_first_node_in_group("Player")
		
		#Sets initial values for some singletons and connects important signals.
		PlayerStats.initialize()
		get_node("/root/Game/HUD").initialize()
		
		rooms = get_parent().get_node("Game/Rooms")
		SaverLoader.load_game(save_id)
		map_size = world_info[current_world_num]["map_size"]
		room_size = world_info[current_world_num]["room_size"]
		set_world_map_guides()
		
		if Global.dev_mode:
			print('In world %s, room %s.' % [Global.current_world_num, str(room_location)])

		#Create new room:
		if current_world_num == 0:
			var new_room = get_room_tscn(current_world_num, room_location[0])
			current_room_node = new_room.instantiate()
			rooms.add_child(current_room_node)
		else:
			var new_room = get_room_tscn(current_world_num, world_map[room_location]["type"])
			current_room_node = new_room.instantiate()
			rooms.add_child(current_room_node)

		#Look at center of room when load
		if len(room_history) > 1 and current_room_node.TYPE != "lobby":
			var cam_rotation = Functions.angle_to_xz(current_room_node, player)
			player.get_node("Camera_Controller").rotation.y = cam_rotation
			#Set camera goal to nearest multiple of PI / 4
			player.camera_goal_horz = round(cam_rotation / (PI / 4)) * (PI / 4) # cam_rotation

	get_node("/root/Game/HUD").add_chum_indicators()

	if Global.dev_mode:
		for x in range(world_grid.size() - 1, -1, -1):
			print(world_grid[x])

func get_world_grid(world_n):
	#Seeded randomness - Same based on global seed, world number and transition count.
	seed(save_seed + hash(str(world_n) + str(world_transition_count)))

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
			grid[pos.x][pos.y] = 2
			if pos.x + dir.x in bounds or pos.y + dir.y in bounds:
				break
			pos = Vector2i(pos.x + dir.x, pos.y + dir.y)
			
		#Add end of corridor to list of spots:
		if pos not in room_points:
			room_points.append(pos)
			
	#Rooms:
	for N in range(room_count):
		var pos = room_points.pick_random()
		grid[pos.x][pos.y] = 2
		for remove_pos in walks:
			var x_remove = pos.x + remove_pos.x
			var y_remove = pos.y + remove_pos.y
		
			if not x_remove in bounds and not y_remove in bounds:
				grid[x_remove][y_remove] = 2

	#Define lobby starting room
	grid[map_size][map_size] = 1
	#Define rooms to add:
	var rooms_missing := []
	for type in world_info[world_n]["room_counts"].keys():
		for count in world_info[world_n]["room_counts"][type]:
			rooms_missing.append(type)
	rooms_missing = bring_to_front(rooms_missing, 5, false) # We want to put in the statues first *just in case* this list is too long and we miss the statues

	#Replaces normal rooms with required from world_info
	var rooms_replace := []
	for y in grid.size():
		for x in grid[0].size():
			if abs(x - map_size) <= 1 and abs(y - map_size) <= 1:
				continue
			if grid[x][y] == 2: # if normal room - safe to potentially replace
				rooms_replace.append(Vector2i(x, y))
	rooms_replace.shuffle()

	#Replace some normal rooms with the missing:
	for add_type in rooms_missing:
		grid[rooms_replace[-1][0]][rooms_replace[-1][1]] = add_type
		rooms_replace.pop_back()
		if len(rooms_replace) <= 0:
			break

	return(grid)

func set_world_map_guides() -> void:
	if current_world_num == 0:
		return
	world_map_guide["lobby"] = Functions.astar2d(world_grid, 1, false)
	world_map_guide["room"] = Functions.astar2d(world_grid, 2, true)
	world_map_guide["fountain"] = Functions.astar2d(world_grid, 3, true)
	world_map_guide["void"] = Functions.astar2d(world_grid, 4, false)
	world_map_guide["statue"] = Functions.astar2d(world_grid, 5, true)
	world_map_guide["upgrade"] = Functions.astar2d(world_grid, 6, true)

func bring_to_front(list: Array, to_front: int, shuffle: bool) -> Array:
	var to_front_list := []
	var others := []
	
	for value in list:
		if value == to_front:
			to_front_list.append(value)
		else:
			others.append(value)
	if shuffle:
		others.shuffle()
	return to_front_list + others

func create_world(world_n):
	#Seeded randomness - Same based on global seed, world number and transition count.
	seed(save_seed + hash(str(world_n) + str(world_transition_count)))
	
	var size: int = world_info[world_n]["map_size"]
	var required_statues := []
	for id in world_info[world_n]["statue_required"]:
		required_statues.append(id) 
	var other_statues: Array = world_info[world_n]["statue_optional"]
	var statue_id := 1
	var item_count := 3
	world_map = {}
	#Uses the world_grid to construct information about all rooms.
	for y in range(0, (2 * size) + 1):
		for x in range(0, (2 * size) + 1):
			#This dict only has values for rooms you can enter.
			#All rooms are assigned a statue id, but ensured that required statues are in the world.
			statue_id = other_statues.pick_random()
			if world_grid[x][y] == 5 and len(required_statues) > 0:
				statue_id = required_statues.pop_back()

			if world_grid[x][y] == 7:
				#item_count is used to determine the lore text on appropriate rooms
				#Filter all of them to remove ones that have been read.
				#If all have been read, show 0.
				var unseen_lores = DecorationManager.lore_texts.keys().filter(func(item): return not (Global.viewed_lore).has(item))
				if len(unseen_lores) > 0:
					item_count = unseen_lores.pick_random()
				else:
					item_count = 0
			else:
				#otherwise choose actual item count
				item_count = int(Functions.map_range(Global.world_transition_count, Vector2(0, 7), Vector2(3, 6))) + [-1, 0, 1].pick_random()
				
			if world_grid[x][y] != 0:
				world_map[Vector2i(x, y)] = {
										"type": world_grid[x][y],
										"entered": false,
										"activated": false,
										"to_spawn": -1,
										"value": Vector2(x - size, y - size).length(),
										"bell_angle": [0, PI / 2, PI, -PI / 2].pick_random(),
										"item_count": item_count,
										"statue_id": statue_id,
										"has_x_pos": has_door(Vector2(x, y), Vector2(1, 0)),
										"has_x_neg": has_door(Vector2(x, y), Vector2(-1, 0)),
										"has_z_pos": has_door(Vector2(x, y), Vector2(0, 1)),
										"has_z_neg": has_door(Vector2(x, y), Vector2(0, -1)),
										"chums": [],
										}
func create_world_boss() -> void:
	#Created boss room information
	world_map = {}
	#There is a boss room defined going from every world to any other world.
	var max_world_n = world_info.keys().max()
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
										"has_x_pos": false,
										"has_x_neg": false,
										"has_z_pos": false,
										"has_z_neg": true,
										"chums": [],
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
		room_changed.emit()
		TransitionScreen.transition(length)
		await TransitionScreen.on_transition_finished
		
		room_location = new_room_location
		if Global.dev_mode:
			print('Now in world %s, room %s.' % [Global.current_world_num, str(new_room_location)])
		if room_history[-1][1] != new_room_location or room_history[-1][0] != current_world_num:
			room_history.append([current_world_num, new_room_location])
		
		if current_room_node:
			current_room_node.queue_free()

		#Create new room:
		var new_room = get_room_tscn(current_world_num, world_map[room_location]["type"])
		current_room_node = new_room.instantiate()
		rooms.add_child(current_room_node)

func transition_to_boss(source_world_n: int, destination_world_n: int, length = 1):
	room_changed_to_boss.emit()
	TransitionScreen.transition(length)
	await TransitionScreen.on_transition_finished
	
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
	var new_room = get_room_tscn(0, new_room_location[0]) #Go to boss room of the world you came from.
	current_room_node = new_room.instantiate()
	rooms.add_child(current_room_node)

func transition_to_world(destination_world_n: int, length = 1):
	room_changed_from_boss.emit()
	TransitionScreen.transition(length)
	await TransitionScreen.on_transition_finished
	
	current_world_num = destination_world_n
	world_transition_count += 1
	map_size = world_info[current_world_num]["map_size"]
	room_size = world_info[current_world_num]["room_size"]
	
	world_grid = get_world_grid(current_world_num)
	
	if Global.dev_mode:
		for x in range(world_grid.size() - 1, -1, -1):
			print(world_grid[x])
	create_world(current_world_num)
	set_world_map_guides()
	
	var new_room_location = Vector2i(map_size, map_size)
	room_location = new_room_location
	if Global.dev_mode:
		print('Now in world %s, room %s.' % [Global.current_world_num, str(new_room_location)])

	if room_history[-1][1] != new_room_location or room_history[-1][0] != current_world_num:
			room_history.append([current_world_num, new_room_location])
	
	if current_room_node:
		current_room_node.queue_free()

	#Create new room:
	var new_room = get_room_tscn(current_world_num, world_map[room_location]["type"])
	current_room_node = new_room.instantiate()
	rooms.add_child(current_room_node)

func randomize_seed() -> void:
	seed(randi())

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
	world_transition_count = 0
	get_node("/root").add_child(load("res://scenes/general/main_menu.tscn").instantiate())




func test_grid_system(world_n, count):
	for n in count:
		var test_world_grid = get_world_grid(world_n)
		
		var is_okay: bool = true
		var counts = {0: 0, #Nothing
					1: 0, #Lobby 
					2: 0, #Normal room 
					3: 0, #Fountain
					4: 0, #Void
					5: 0, #Statue 
					6: 0} #Upgrade
					
		for y in test_world_grid.size():
			for x in test_world_grid[0].size():
				counts[test_world_grid[x][y]] += 1
		
		for type in world_info[world_n]["room_counts"].keys():
			if world_info[world_n]["room_counts"][type] != 0:
				if world_info[world_n]["room_counts"][type] != counts[type]:
					is_okay = false
		
		if not is_okay:
			print("faulty grid:")
			for x in range(test_world_grid.size() - 1, -1, -1):
				print(test_world_grid[x])
		else:
			pass
			#print("Grid %s successful" % [n])
