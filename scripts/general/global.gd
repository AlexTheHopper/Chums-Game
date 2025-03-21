extends Node

var game_begun := false
var map_size := 5
var room_size := 40.0
var world_map := {}
var world_grid := []
var world_map_guide := {}
var room_location := Vector2(map_size, map_size)
var room_history := [room_location]
var in_battle := false
var current_room_node: Node3D
var rooms: Node3D

var room_lookup: Dictionary


func _ready():
	if world_map == {}:
		world_grid = get_world_grid(map_size)
		create_world(map_size)
		
	current_room_node = get_parent().get_node("Game/Rooms/Lobby_World1")
	rooms = get_parent().get_node("Game/Rooms")
	
	room_lookup = {"lobby_world1": load("res://scenes/world/lobby_world_1.tscn"),
				"normal_room_world1": load("res://scenes/world/room_world_1.tscn"),
				"fountain_room_world1": load("res://scenes/world/fountain_room_world_1.tscn"),
				}
				
func get_world_grid(size):
	#2D Array of where actual rooms are in the world
	var corridor_count := int(max(5 + size * size / 2, 5))
	var corridor_lengths := range(3, max(size / 2, 4))
	var walks := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var room_count := int(max(size * size / 2, 1))
	var bounds = [-1, (2 * size) + 1]
	
	#Set all to 1s:
	var grid = []
	for y in range(0, (2 * size) + 1):
		var row = []
		for x in range(0, (2 * size) + 1):
			row.append(1)
		grid.append(row)

	#Start with coridoors:
	var room_points = [Vector2(size, size), Vector2(size, size), Vector2(size, size)]
	#print('starting at: ' + str(room_points[0]))
	#For each corridor:
	for N in range(corridor_count):
		var pos = room_points.pick_random()
		var length = corridor_lengths.pick_random()
		var dir = walks.pick_random()
		#print('At point ' + str(pos) + ' and heading in dir ' + str(dir) + ' for length ' + str(length))
		
		#For each tile:
		for n in range(length):
			grid[pos.x][pos.y] = 0
			if int(pos.x + dir.x) in bounds or int(pos.y + dir.y) in bounds:
				break
			pos = Vector2(int(pos.x + dir.x), int(pos.y + dir.y))
			
		#Add end of corridor to list of spots:
		if pos not in room_points:
			room_points.append(pos)
			#print('Appending ' + str(pos) + 'to room locs')
			
	#Rooms:
	for N in range(room_count):
		var pos = room_points.pick_random()
		for x in [-1, 0, 1]:
			for y in [-1, 0, 1]:
				var x_remove := int(pos.x + x)
				var y_remove := int(pos.y + y)
				if not x_remove in bounds and not y_remove in bounds:
					grid[x_remove][y_remove] = 0
	
	#TESTPRINT:
	for x in range(grid.size() - 1, -1, -1):
		print(grid[x])

	world_map_guide = Functions.astar2d(grid, Vector2(size, size))
	return(grid)
	


func get_room_type(_world_num: int):
	#TODO make this more sophisticated
	if randf() < 0.5:
		return "fountain_room_world1"
	else:
		return "normal_room_world1"

func create_world(size):
	#Uses the world_grid to construct information about all rooms.	
	for y in range(0, (2 * size) + 1):
		for x in range(0, (2 * size) + 1):
			#This dict only has values for rooms you can enter.
			if world_grid[x][y] == 0:
				world_map[Vector2(x, y)] = {
										"type": get_room_type(1),
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

	world_map[Vector2(size, size)]["type"] = "lobby_world1"
	
func has_door(location: Vector2, direction: Vector2) -> bool:
	#Location in gridform
	var bounds = [-1, (2 * map_size) + 1]
	var next_room_loc = location + direction
	
	#No door if on map edge
	if int(next_room_loc.x) in bounds or int(next_room_loc.y) in bounds:
		return false
		
	#No door if 1 in grid
	if world_grid[next_room_loc.x][next_room_loc.y]:
		return false
	
	#Otherwise g2g
	return true
	
func transition_to_level(new_room_location: Vector2):
	if new_room_location in world_map:
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		
		room_location = new_room_location
		print('Now in: ' + str(new_room_location))
		room_history.append(new_room_location)
		
		if current_room_node:
			current_room_node.queue_free()

		#Create new room:
		var new_room = room_lookup[world_map[room_location]["type"]]
		current_room_node = new_room.instantiate()
		rooms.add_child(current_room_node)
	
func reset():
	room_location = Vector2(0, 0)
	room_history = [Vector2(0, 0)]
	game_begun = false
	world_map = {}
	_ready()
	#get_tree().reload_current_scene()
