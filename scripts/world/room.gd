extends room
class_name fight_room

@onready var spawn_point: PathFollow3D = $SpawnPath/SpawnPoint
@onready var room_value = Global.world_map[Global.room_location]["value"]
const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")
const TYPE := "room"

func _ready() -> void:
	
	$RoomActivator.activate_bell.connect(close_doors)
	
	if Global.world_map[Global.room_location]["to_spawn"] < 0:
		#Maximum to spawn:
		enemies_to_spawn = int(Functions.map_range(room_value, Vector2(1, Global.map_size), Vector2(3, Global.world_info[Global.current_world_num]["max_chums"])))
	else:
		enemies_to_spawn = Global.world_map[Global.room_location]["to_spawn"]
		
	if Global.dev_mode:
		$SpawnPath/SpawnTimer.wait_time = 0.1
	
	super()

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
		
		#Scale based on world transition count.
		#For X transition counts, each quality stat can increase from X to 2X.
		var count = Global.world_transition_count
		chum_instance.increase_stats(randi_range(count, 2 * count), randi_range(count, 2 * count), randi_range(count, 2 * count), randi_range(count, 2 * count))
		#chum_instance.bracelet_cost += count
		chum_instance.bracelet_cost = get_chum_cost(chum_instance)

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

func decorate():
	super()
	#Streetlamp generally points to fastest way to lobby.
	var to_lobby = Global.world_map_guide["lobby"][Global.room_location] * 8
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x + randf_range(-1.5, 1.5)
	spawn_pos.z += to_lobby.y + randf_range(-1.5, 1.5)
	
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = spawn_pos.snapped(Vector3(0.1, 0.1, 0.1))
	
	#Other objects:
	var from_lobby = Global.world_map[Global.room_location]["max_value"]
	var deco_n = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(10, 100))
	var angles := [0, PI/2, PI, 3*PI/2]
	var decos_to_add := []

	for n in int(deco_n * DecorationManager.decorations_world[Global.current_world_num]['multiplier']):
		var chosen_deco = DecorationManager.get_random_decoration(Global.current_world_num)
		var pos = Vector3(randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15),
						0, randf_range(-13, -1) if randf() < 0.5 else randf_range(3, 15)).snapped(Vector3(0.1, 0.1, 0.1))
		var angle = angles.pick_random()

		decos_to_add.append([chosen_deco[0], pos, angle])

	for deco in decos_to_add:
		var to_add = deco[0].instantiate()
		$Decorations.add_child(to_add)
		to_add.global_position = deco[1]
		to_add.rotation.y = deco[2]
		if deco[1] in Global.world_map[Global.room_location]["removed_decorations"] and to_add is DestructibleDeco:
			to_add.remove_on_entry()
	decos_to_add = []
