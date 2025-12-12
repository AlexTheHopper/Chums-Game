extends room
class_name boss_room

const TYPE := "boss"

var boss_chums_to_spawn := []


func _ready() -> void:
	$RoomActivator.activate_bell.connect(close_doors)
	
	for chum_id in ChumsManager.boss_chums[Global.room_location].keys():
		for n in ChumsManager.boss_chums[Global.room_location][chum_id]:
			boss_chums_to_spawn.append(chum_id)
	boss_chums_to_spawn.shuffle()
	
	if not Global.world_map[Global.room_location]["activated"]:
		close_doors()
	if not Global.world_map[Global.room_location]["entered"]:
		$Timer.start()
	else:
		$RoomActivator.finish_spawning()
	super()
	get_node("/root/Game/HUD").display_minimap(false)

func fill_tunnels() -> void:
	pass

func decorate() -> void:
	#Other objects:
	var deco_n = 100
	var angles := [0, PI/2, PI, 3*PI/2]
	var decos_to_add := []

	for n in int(deco_n * (DecorationManager.decorations_world[Global.room_location[0]]['multiplier'] + DecorationManager.decorations_world[Global.room_location[1]]['multiplier']) / 2):
		var chosen_deco = DecorationManager.get_random_decoration([Global.room_location[0], Global.room_location[1]])
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

func _on_timer_timeout() -> void:
	if len(boss_chums_to_spawn) == 0:
		$Timer.stop()
		$RoomActivator.finish_spawning()
		save_room()
		return

	#Spawns chum
	var chum_id = boss_chums_to_spawn.pop_back()
	var chum_instance = ChumsManager.get_specific_chum_id(chum_id).instantiate()
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
