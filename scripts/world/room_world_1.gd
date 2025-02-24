extends room

@onready var grid_map: GridMap = $GridMap
@onready var spawn_point: PathFollow3D = $SpawnPath/SpawnPoint
@onready var room_value := Global.room_location.length()
const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")

func _ready() -> void:	
	
	$RoomActivator.activate_bell.connect(close_doors)
	
	if Global.world_map[Global.room_location]["to_spawn"] < 0:
		enemies_to_spawn = 5
	else:
		enemies_to_spawn = Global.world_map[Global.room_location]["to_spawn"]
	
	randomize_spawn_loc()
	super()
	set_player_loc_on_entry()
	fill_tunnels()

func fill_tunnels():
	#Fix walls etc.
	var door_dist := 9
	if not Global.world_map[Global.room_location]["has_x_pos"]:
		get_node("Doors/x_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(door_dist, 0, w), 5, 22)
			grid_map.set_cell_item(Vector3(door_dist + 1, 0, w), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(door_dist - 1, 0, w), 15, 0)

	if not Global.world_map[Global.room_location]["has_x_neg"]:
		get_node("Doors/x_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(-door_dist, 0, w), 5, 16)
			grid_map.set_cell_item(Vector3(-(door_dist + 1), 0, w), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(-(door_dist - 1), 0, w), 15, 10)

	if not Global.world_map[Global.room_location]["has_z_pos"]:
		get_node("Doors/z_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, door_dist), 5, 10)
			grid_map.set_cell_item(Vector3(w, 0, door_dist + 1), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, door_dist - 1), 15, 22)

	if not Global.world_map[Global.room_location]["has_z_neg"]:
		get_node("Doors/z_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, -door_dist), 5, 0)
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist + 1)), 4, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist - 1)), 15, 16)
			
func close_doors():
	for door in get_node("Doors").get_children():
		door.lower()
	#Connect to enemies to know when to open doors
	for chum in get_tree().get_nodes_in_group("Chums_Enemy"):
		chum.health_depleted.connect(check_enemy_count)
		
func check_enemy_count():
	if len(get_tree().get_nodes_in_group("Chums_Enemy")) == 0:
		Global.in_battle = false
		open_doors()
	
func open_doors():
	for door in get_node("Doors").get_children():
		door.raise()

#Enemy chum spawner:
func _on_spawn_timer_timeout() -> void:
	enemies_to_spawn -= 1
	randomize_spawn_loc()
	
	#var chum_to_spawn = ChumsManager.get_random_world1_chum(Global.room_location)
	
	var chum_info = ChumsManager.get_random_world1_chum(room_value)
	var chum_to_spawn = chum_info["object"]
	var chum_value = chum_info["value"]
	
	if chum_to_spawn:
		var chum_instance = chum_to_spawn.instantiate()
		chum_instance.spawn_currency.connect(spawn_currency)
		get_parent().get_parent().get_node("Chums").add_child(chum_instance)
		chum_instance.global_position = spawn_point.global_position
		
	room_value -= chum_value
	
	
	
	
	if enemies_to_spawn > 0:
		spawn_timer.start()
	elif not Global.world_map[Global.room_location]["activated"]:
		$RoomActivator.finish_spawning()
		
func randomize_spawn_loc():
	#Randomize location:
	spawn_point.progress_ratio = randf()
	spawn_point.h_offset = randf_range(-2, 2)

func decorate():
	super()
	
	#Streetlamp generally points to lobby.
	var to_lobby = -Global.room_location.normalized() * 8
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x + randf_range(-2, 2)
	spawn_pos.z += to_lobby.y + randf_range(-2, 2)
	
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = spawn_pos
	Global.world_map[Global.room_location]["light_position"] = spawn_pos
	
	#Other objects:
	var per_to_edge = max(abs(Global.room_location[0]), abs(Global.room_location[1])) / Global.MAP_SIZE
	var deco_n = Functions.map_range(per_to_edge, Vector2(0, 1), Vector2(10, 100))
	var angles = [0, PI/2, PI, 3*PI/2]
	for n in deco_n:
		var chosen_deco = DecorationManager.get_random_decoration_world1()
		var deco_inst = chosen_deco[0].instantiate()
		$Decorations.add_child(deco_inst)
		
		var pos = Vector3(randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15),
						0, randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15))
		deco_inst.global_position = pos
		var angle = angles.pick_random()
		deco_inst.rotation.y = angle
		
		Global.world_map[Global.room_location]["decorations"].append({"name": chosen_deco[1], "position": pos, "rotation": angle})
	
	
