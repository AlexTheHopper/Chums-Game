extends Node

var game_begun = false
const MAP_SIZE = 5
var room_size = 40.0
var world_map = {}
var room_location = Vector2(0, 0)
var room_history = [Vector2(0, 0)]
var in_battle := false
var current_room_node: Node3D
var rooms: Node3D

var room_info : Dictionary


func _ready():
	if world_map == {}:
		create_world(MAP_SIZE)
		for x in range(10):
			test_generation()
	current_room_node = get_parent().get_node("Game/Rooms/Lobby_World1")
	rooms = get_parent().get_node("Game/Rooms")
	
	room_info = {"lobby_world1": load("res://scenes/world/lobby_world_1.tscn"),
				"normal_room_world1": load("res://scenes/world/room_world_1.tscn"),
				"fountain_room_world1": load("res://scenes/world/fountain_room_world_1.tscn"),
				}
				
func test_generation():
	var size := 5
	var corridor_count := int(size * size)
	var corridor_lengths := range(3, size)
	var walks := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var room_count := int(size * size / 2)
	var bounds = [-1, (2 * size) + 1]
	print(bounds)
	
	var test_do := 0
	var test_try := 0
	
	#Set all to 1s:
	var grid = []
	for y in range(0, (2 * size) + 1):
		var row = []
		for x in range(0, (2 * size) + 1):
			row.append(1)
		grid.append(row)

	#Start with coridoors:
	var room_points = [Vector2(size, size), Vector2(size, size), Vector2(size, size)]
	print('starting at: ' + str(room_points[0]))
	#For each corridor:
	for N in range(corridor_count):
		var pos = room_points.pick_random()
		var length = corridor_lengths.pick_random()
		var dir = walks.pick_random()
		#print('At point ' + str(pos) + ' and heading in dir ' + str(dir) + ' for length ' + str(length))
		
		#For each tile:
		for n in range(length):
			
			if grid[pos.x][pos.y] == 1:
				test_do += 1
			test_try += 1
			
			grid[pos.x][pos.y] = 0
			if int(pos.x + dir.x) in bounds or int(pos.y + dir.y) in bounds:
				break
			pos += Vector2(int(dir.x), int(dir.y))
			
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
				
	for x in grid:
		print(x)

		
	
	

func get_room_type(_world_num: int):
	if randf() < 0.1:
		return "fountain_room_world1"
	else:
		return "normal_room_world1"

func create_world(size):
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			world_map[Vector2(x,y)] = {"type": get_room_type(1),
										"entered": false,
										"activated": false,
										"to_spawn": -1,
										"value": Vector2(x, y).length(),
										"bell_angle": randf_range(0, 2 * PI),
										"heart_count": 3,
										"chums": [],
										"light_position": Vector3(),
										"decorations": [],
										"has_x_pos": true if x < MAP_SIZE else false,
										"has_x_neg": true if x > -MAP_SIZE else false,
										"has_z_pos": true if y < MAP_SIZE else false,
										"has_z_neg": true if y > -MAP_SIZE else false}
	world_map[Vector2(0, 0)]["type"] = "lobby_world1"
	
func transition_to_level(new_room_location: Vector2):
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	
	room_location = new_room_location
	room_history.append(new_room_location)
	
	if current_room_node:
		current_room_node.queue_free()

	#Create new room:
	var new_room = room_info[world_map[room_location]["type"]]
	current_room_node = new_room.instantiate()
	rooms.add_child(current_room_node)
	
func reset():
	room_location = Vector2(0, 0)
	room_history = [Vector2(0, 0)]
	game_begun = false
	world_map = {}
	_ready()
	#get_tree().reload_current_scene()
