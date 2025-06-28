extends room
class_name boss_room

const TYPE := "boss"

var boss_chums_to_spawn := []


func _ready() -> void:
	super()
	$RoomActivator.activate_bell.connect(close_doors)
	

	for chum_id in ChumsManager.boss_chums[Global.room_location].keys():
		for n in ChumsManager.boss_chums[Global.room_location][chum_id]:
			boss_chums_to_spawn.append(chum_id)
	boss_chums_to_spawn.shuffle()
	
	if not Global.world_map[Global.room_location]["activated"]:
		close_doors()
	if not Global.world_map[Global.room_location]["entered"]:
		$Timer.start()
	
	Global.world_map[Global.room_location]["entered"] = true


func fill_tunnels() -> void:
	pass

func decorate() -> void:
	pass

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
