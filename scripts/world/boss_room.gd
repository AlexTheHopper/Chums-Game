extends room
class_name boss_room

const TYPE := "boss"


func _ready() -> void:
	super()
	$RoomActivator.activate_bell.connect(close_doors)
	Global.world_map[Global.room_location]["entered"] = true
	spawn_boss_chums()

func fill_tunnels() -> void:
	pass

func set_player_loc_on_entry():
	move_player_and_camera(player_spawn.global_position, 0.0)

func spawn_boss_chums() -> void:
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

func decorate() -> void:
	pass
