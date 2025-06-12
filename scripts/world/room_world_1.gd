extends room

@onready var spawn_point: PathFollow3D = $SpawnPath/SpawnPoint
@onready var room_value = Global.world_map[Global.room_location]["value"]
const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")
const TYPE := "room"
var spawn_particles = preload("res://particles/spawn_particles_world1.tscn")

func _ready() -> void:	
	
	$RoomActivator.activate_bell.connect(close_doors)
	
	if Global.world_map[Global.room_location]["to_spawn"] < 0:
		#Maximum to spawn:
		enemies_to_spawn = int(Functions.map_range(room_value, Vector2(1, Global.map_size), Vector2(3, 8)))
	else:
		enemies_to_spawn = Global.world_map[Global.room_location]["to_spawn"]
		
	if Global.dev_mode:
		$SpawnPath/SpawnTimer.wait_time = 0.1
	
	super()
	set_player_loc_on_entry()
	set_chums_loc_on_entry()

func set_chums_loc_on_entry():
	#Place friendly chums in front of the player:
	if len(Global.room_history) >= 2:
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			if chum.state_machine.current_state.name != "Carry":
				chum.global_position = lerp(player.global_position, Vector3(1, 0, 1), 0.5) + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
				chum.rotation.y = randf_range(0, 2*PI)
				chum.set_state("Idle")


func fill_tunnels():
	#Fix walls etc.
	var door_dist := 9
	if not Global.world_map[Global.room_location]["has_x_pos"]:
		if get_node_or_null("Doors/x_pos"):
			get_node("Doors/x_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(door_dist + 1, 0, w), 1, 22)
			#Ramps:
			grid_map.set_cell_item(Vector3(door_dist, 0, w), 16, 22)

	if not Global.world_map[Global.room_location]["has_x_neg"]:
		if get_node_or_null("Doors/x_neg"):
			get_node("Doors/x_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(-(door_dist + 1), 0, w), 1, 16)
			#Ramps:
			grid_map.set_cell_item(Vector3(-door_dist, 0, w), 16, 16)

	if not Global.world_map[Global.room_location]["has_z_pos"]:
		if get_node_or_null("Doors/z_pos"):
			get_node("Doors/z_pos").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, door_dist + 1), 1, 10)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, door_dist), 16, 10)

	if not Global.world_map[Global.room_location]["has_z_neg"]:
		if get_node_or_null("Doors/z_neg"):
			get_node("Doors/z_neg").queue_free()
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist + 1)), 1, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, -door_dist), 16, 0)

#Enemy chum spawner:
func _on_spawn_timer_timeout() -> void:
	enemies_to_spawn -= 1
	
	var chum_info = ChumsManager.get_world_random_chum(room_value, Global.current_world_num)
	var chum_to_spawn = chum_info["object"]
	var chum_value = chum_info["value"]
	
	if chum_to_spawn:
		#Spawns chum
		var chum_instance = chum_to_spawn.instantiate()
		chum_instance.spawn_currency.connect(spawn_currency)
		get_parent().get_parent().get_node("Chums").add_child(chum_instance)
		chum_instance.global_position = get_chum_spawn_loc()
		
		#Spawn spawn particles:
		call_deferred("apply_spawn_particles", chum_instance)
	room_value -= chum_value / 2
	Global.world_map[Global.room_location]["value"] = room_value

	#If still spawning:
	if enemies_to_spawn > 0:
		spawn_timer.start()

	#If reach maximum chum count
	else:
		$RoomActivator.finish_spawning()
		enemies_to_spawn = 0
		
		#Save game
		save_room()
		
func apply_spawn_particles(chum):
	chum.particle_zone.add_child(spawn_particles.instantiate())
		
func get_chum_spawn_loc():
	var pos = Vector3(1, 0, 1)
	pos.x += randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15)
	pos.z += randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15)
	return pos


func decorate():
	super()
	
	#Streetlamp generally points to fastest way to lobby.
	var to_lobby = Global.world_map_guide["lobby"][Global.room_location] * 8
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x + randf_range(-1.5, 1.5)
	spawn_pos.z += to_lobby.y + randf_range(-1.5, 1.5)
	
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = spawn_pos
	Global.world_map[Global.room_location]["light_position"] = spawn_pos
	
	#Other objects:
	var from_lobby = Global.world_map[Global.room_location]["value"]
	var deco_n = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(10, 100))
	var angles = [0, PI/2, PI, 3*PI/2]
	for n in deco_n:
		var chosen_deco = DecorationManager.get_random_decoration(Global.current_world_num)
		var deco_inst = chosen_deco[0].instantiate()
		$Decorations.add_child(deco_inst)
		
		var pos = Vector3(randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15),
						0, randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15))
		deco_inst.global_position = pos
		var angle = angles.pick_random()
		deco_inst.rotation.y = angle
		
		Global.world_map[Global.room_location]["decorations"].append({"name": chosen_deco[1], "position": pos, "rotation": angle})
	
	
