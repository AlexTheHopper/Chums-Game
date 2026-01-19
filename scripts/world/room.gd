extends room
class_name fight_room

@onready var room_value = Global.world_map[Global.room_location]["value"]
const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")
const TYPE := "room"
var rot_count : int

func _ready() -> void:
	#Create custom terrain
	var terrain = DecorationManager.get_terrain(Global.current_world_num, Global.world_map[Global.room_location]["room_specific_id"])
	if not terrain:
		terrain = DecorationManager.get_terrain(Global.current_world_num, 0)
	var nav_region: NavigationRegion3D = terrain.instantiate()
	add_child(nav_region)
	#Since the nav regions are not centered in the middle of the "center" tile, when they are rotated they also need to be shifted to fit in the room.
	var rot_choice = [[0, Vector3(0.0, 0.0, 0.0)],
					[1,   Vector3(0.0, 0.0, 2.0)],
					[2,   Vector3(2.0, 0.0, 2.0)],
					[3,   Vector3(2.0, 0.0, 0.0)]].pick_random()
	rot_count = rot_choice[0]
	nav_region.rotation.y = rot_count * PI / 2
	nav_region.global_position += rot_choice[1]
	grid_map = nav_region.get_node("GridMap") #This is the new one we want to block tunnels that dont lead anywhere
	
	$RoomActivator.activate_bell.connect(close_doors)
	
	if Global.world_map[Global.room_location]["to_spawn"] < 0:
		#Maximum to spawn:
		enemies_to_spawn = int(Functions.map_range(room_value, Vector2(1, Global.map_size), Vector2(Global.world_info[Global.current_world_num]["min_chums"], Global.world_info[Global.current_world_num]["max_chums"])))
	else:
		enemies_to_spawn = Global.world_map[Global.room_location]["to_spawn"]
		
	if Global.dev_mode:
		$SpawnTimer.wait_time = 0.1
	
	super()

func fill_tunnels():
	#Fix walls etc.
	var door_dist := 9
	if not Global.has_door(Global.room_location, rotate_vec2i(Vector2i(1, 0), rot_count)):
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(door_dist + 1, 0, w), 1, 22)
			#Ramps:
			grid_map.set_cell_item(Vector3(door_dist, 0, w), 16, 22)

	if not Global.has_door(Global.room_location, rotate_vec2i(Vector2i(-1, 0), rot_count)):
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(-(door_dist + 1), 0, w), 1, 16)
			#Ramps:
			grid_map.set_cell_item(Vector3(-door_dist, 0, w), 16, 16)

	if not Global.has_door(Global.room_location, rotate_vec2i(Vector2i(0, 1), rot_count)):
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, door_dist + 1), 1, 10)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, door_dist), 16, 10)

	if not Global.has_door(Global.room_location, rotate_vec2i(Vector2i(0, -1), rot_count)):
		for w in range(-3, 4):
			#Solid Blocks
			grid_map.set_cell_item(Vector3(w, 0, -(door_dist + 1)), 1, 0)
			#Ramps:
			grid_map.set_cell_item(Vector3(w, 0, -door_dist), 16, 0)

func rotate_vec2i(v: Vector2i, n: int) -> Vector2i:
	match n % 4:
		0: return v
		1: return Vector2i(v.y, -v.x)
		2: return Vector2i(-v.x, -v.y)
		3: return Vector2i(-v.y, v.x)
	return v

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
		chum_instance.increase_stats(randi_range(int(count/2.0), int(1.5*count)),
									randi_range(int(count/2.0), int(1.5*count)),
									randi_range(int(count/2.0), int(1.5*count)),
									randi_range(int(count/2.0), int(1.5*count)),)
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
	$RoomActivator.global_position = align_loc_to_ground($RoomActivator.global_position)
	super()
	#Streetlamp generally points to fastest way to lobby.
	var to_lobby = Global.world_map_guide["lobby"][Global.room_location] * 8
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x #+ randf_range(-1.5, 1.5)
	spawn_pos.z += to_lobby.y #+ randf_range(-1.5, 1.5)
	
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = align_loc_to_ground(spawn_pos).snapped(Vector3(0.1, 0.1, 0.1))
	
	#Other objects:
	var from_lobby = Global.world_map[Global.room_location]["max_value"]
	var deco_n = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(10, 100))
	var angles := [0, PI/2, PI, 3*PI/2]
	var decos_to_add := []

	for n in int(deco_n * DecorationManager.decorations_world[Global.current_world_num]['multiplier']):
		var chosen_deco = DecorationManager.get_random_decoration([Global.current_world_num])
		var pos = get_deco_loc()
		var angle = angles.pick_random()
		
		#Here we want to check the terrain to make sure decos arent inside walls or hanging off edges
		pos = align_loc_to_ground(pos)
		if is_valid_deco_loc(pos, chosen_deco["radius"]):
			decos_to_add.append([chosen_deco["scene"], pos, angle])

	for deco in decos_to_add:
		var to_add = deco[0].instantiate()
		$Decorations.add_child(to_add)
		to_add.global_position = deco[1]
		to_add.rotation.y = deco[2]
		if deco[1] in Global.world_map[Global.room_location]["removed_decorations"] and to_add is DestructibleDeco:
			to_add.remove_on_entry()
	decos_to_add = []

func get_deco_loc() -> Vector3:
	return(Vector3(randf_range(-16, -1) if randf() < 0.5 else randf_range(3, 18),
				0, randf_range(-16, -1) if randf() < 0.5 else randf_range(3, 18)).snapped(Vector3(0.1, 0.1, 0.1)))
