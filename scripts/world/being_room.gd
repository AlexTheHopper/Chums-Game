extends room
class_name being_room

const TYPE := "being"

const being_chums: Dictionary[int, int] = {1: 17, 2: 18, 3: 19, 4: 20} #world: chum_id


func _ready() -> void:
	#$RoomActivator.activate_bell.connect(close_doors)
	#
	#if not Global.world_map[Global.room_location]["activated"]:
		#close_doors()
	#else:
		#$RoomActivator.finish_spawning()
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

func decorate() -> void:
	pass

func set_player_loc_on_entry():
	move_player_and_camera(player_spawn.global_position, 0.0)
