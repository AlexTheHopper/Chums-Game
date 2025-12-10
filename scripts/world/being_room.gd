extends room
class_name being_room

const TYPE := "being"

const being_chums: Dictionary[int, int] = {1: 17, 2: 18, 3: 19, 4: 20} #world: chum_id


func _ready() -> void:
	super()
	
	#Spawns chum if not on team:
	var chum_id = being_chums[Global.room_location[1]]
	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		if chum.chum_id == chum_id:
			return
	
	var chum_instance = ChumsManager.get_specific_chum_id(chum_id).instantiate()
	chum_instance.start_health = 0
	chum_instance.stats_set = true
	chum_instance.initial_state_override = "Knock"
	chum_instance.spawn_currency.connect(spawn_currency)
	get_parent().get_parent().get_node("Chums").add_child(chum_instance)
	chum_instance.global_position = Vector3(1.0, 1.1, 1.0)

func fill_tunnels() -> void:
	pass

func save_room() -> void:
	pass

func decorate() -> void:
	#Other objects:
	var deco_n = 100
	var angles := [0, PI/2, PI, 3*PI/2]
	var decos_to_add := []

	for n in int(deco_n * DecorationManager.decorations_world[Global.room_location[1]]['multiplier']):
		var chosen_deco = DecorationManager.get_random_decoration(Global.room_location[1])
		var pos = Vector3(randf_range(-14, -1) if randf() < 0.5 else randf_range(3, 16),
						0, randf_range(-14, -1) if randf() < 0.5 else randf_range(3, 16)).snapped(Vector3(0.1, 0.1, 0.1))
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

func set_player_loc_on_entry():
	move_player_and_camera(player_spawn.global_position, 0.0)
