extends Node

var game_begun = false
const MAP_SIZE = 5
var room_size = 40.0
var world_map = {}
var room_location = Vector2(0, 0)
var room_history = [Vector2(0, 0)]
var in_battle := false


func _ready():
	if world_map == {}:
		create_world(MAP_SIZE)

func create_world(size):
	for x in range(-size, size + 1):
		for y in range(-size, size + 1):
			world_map[Vector2(x,y)] = {"entered": false,
										"activated": false,
										"to_spawn": -1,
										"bell_angle": randf_range(0, 2 * PI),
										"chums": [],
										"light_position": Vector3(),
										"decorations": [],
										"has_x_pos": true if x < MAP_SIZE else false,
										"has_x_neg": true if x > -MAP_SIZE else false,
										"has_z_pos": true if y < MAP_SIZE else false,
										"has_z_neg": true if y > -MAP_SIZE else false}
	
func transition_to_level(new_room_location: Vector2):
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	
	room_location = new_room_location
	room_history.append(new_room_location)
	print("Now in room: " + str(room_location))
	
	get_parent().get_node("Game/Rooms").get_children()[0].queue_free()

	#Create new room:
	if room_location == Vector2(0, 0):
		var new_lobby: PackedScene = load("res://scenes/world/lobby_world_1.tscn")
		var roomInstance = new_lobby.instantiate()
		get_parent().get_node("Game/Rooms").add_child(roomInstance)
	else:
		var new_room: PackedScene = load("res://scenes/world/room_world_1.tscn")
		var roomInstance = new_room.instantiate()
		get_parent().get_node("Game/Rooms").add_child(roomInstance)
	
	
func reset():
	room_location = Vector2(0, 0)
	room_history = [Vector2(0, 0)]
	game_begun = false
	world_map = {}
	create_world(MAP_SIZE)
	#get_tree().reload_current_scene()
