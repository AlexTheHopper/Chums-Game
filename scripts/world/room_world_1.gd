extends room

@onready var grid_map: GridMap = $GridMap
@onready var spawn_point: PathFollow3D = $SpawnPath/SpawnPoint

func _ready() -> void:	
	
	$RoomActivator.activate_lever.connect(close_doors)
	
	if Global.world_map[Global.room_location]["to_spawn"] < 0:
		enemies_to_spawn = 3
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
		open_doors()
	
func open_doors():
	for door in get_node("Doors").get_children():
		door.raise()

#Enemy chum spawner:
func _on_spawn_timer_timeout() -> void:
	enemies_to_spawn -= 1
	randomize_spawn_loc()
	
	var chum_to_spawn = ChumsManager.get_random_world1_chum(Global.room_location)
	var chum_instance = chum_to_spawn.instantiate()
	chum_instance.global_position = spawn_point.global_position
	
	get_parent().get_parent().get_node("Chums").add_child(chum_instance)
	
	if enemies_to_spawn > 0:
		spawn_timer.start()
	elif not Global.world_map[Global.room_location]["activated"]:
		$RoomActivator.finish_spawning()
		
func randomize_spawn_loc():
	#Randomize location:
	spawn_point.progress_ratio = randf()
	spawn_point.h_offset = randf_range(-2, 2)
