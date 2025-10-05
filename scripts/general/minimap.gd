extends Control

@export var room_tscn: PackedScene
var room_size := (128.0/5.0)*1.25
var max_distance := 2
var player_room: Vector2i

func _ready() -> void:
	call_deferred("update_minimap")

func update_minimap() -> void:
	for child in get_children():
		child.queue_free()

	if Global.current_world_num == 0:
		return
	
	#TEMPORARY FOR ALIGNMET
	for world_room in Global.world_map.keys():
		#Dont display if havent entered
		if Global.world_map[world_room]["entered"] == false:
			continue
		#Dont display if too far away

		if abs(world_room.x - Global.room_location.x) > max_distance or abs(world_room.y - Global.room_location.y) > max_distance:
			continue
		
		add_room(world_room)

func add_room(location: Vector2i) -> void:
	var new_room = room_tscn.instantiate()
	new_room.position = relative_to_player_pos(location, Global.room_location)
	new_room.x_pos = Global.world_map[location]["has_x_pos"]
	new_room.x_neg = Global.world_map[location]["has_x_neg"]
	new_room.z_pos = Global.world_map[location]["has_z_pos"]
	new_room.z_neg = Global.world_map[location]["has_z_neg"]
	add_child(new_room)

func relative_to_player_pos(this_position: Vector2i, player_pos: Vector2i) -> Vector2i:
	return (this_position - player_pos) * room_size
