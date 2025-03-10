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
	current_room_node = get_parent().get_node("Game/Rooms/Lobby_World1")
	rooms = get_parent().get_node("Game/Rooms")
	
	room_info = {"lobby_world1": load("res://scenes/world/lobby_world_1.tscn"),
				"normal_room_world1": load("res://scenes/world/room_world_1.tscn"),
				"fountain_room_world1": load("res://scenes/world/fountain_room_world_1.tscn"),
				}

func create_world(size):
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			world_map[Vector2(x,y)] = {"type": "normal_room_world1" if randf() < 0.5 else "fountain_room_world1",
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
