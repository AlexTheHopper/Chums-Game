extends room

const TYPE := "boss"
@onready var player_spawn_node := $PlayerSpawn

func _ready() -> void:
	$RoomActivator.activate_bell.connect(close_doors)
	print('connecting to bell')
	for group in ["Chums_Enemy", "Chums_Neutral"]:
	#Remove all previous enemy chums:
		for chum in get_tree().get_nodes_in_group(group):
			chum.queue_free()
	load_room()
	set_player_loc_on_entry()
	set_chums_loc_on_entry()
	
	#Spawns boss chums(s)
	if Global.world_map[Global.room_location]["activated"] == false:
		for chum_id in ChumsManager.boss_chums[Global.room_location].keys():
			for n in ChumsManager.boss_chums[Global.room_location][chum_id]:
				#Spawns chum
				var chum_instance = ChumsManager.get_specific_chum_id(chum_id).instantiate()
				chum_instance.spawn_currency.connect(spawn_currency)
				get_parent().get_parent().get_node("Chums").add_child(chum_instance)
				chum_instance.global_position = get_chum_spawn_loc()
				
				#Spawn spawn particles:
				call_deferred("apply_spawn_particles", chum_instance)
	close_doors()

func set_player_loc_on_entry():
	move_player_and_camera(player_spawn_node.global_position, 0.0)

func set_chums_loc_on_entry():
	#Place friendly chums in front of the player:
	if len(Global.room_history) >= 2:
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			if chum.state_machine.current_state.name != "Carry":
				var rand_angle = randf_range(0, 2*PI)
				chum.global_position = player.global_position + 3 * Vector3(sin(rand_angle), 0, cos(rand_angle))
				chum.rotation.y = randf_range(0, 2*PI)
				chum.set_state("Idle")
