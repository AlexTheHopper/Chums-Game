extends room
class_name being_room

const TYPE := "being"


func _ready() -> void:
	$RoomActivator.activate_bell.connect(close_doors)
	
	if not Global.world_map[Global.room_location]["activated"]:
		close_doors()
	else:
		$RoomActivator.finish_spawning()
	super()

func fill_tunnels() -> void:
	pass

func decorate() -> void:
	pass

func set_player_loc_on_entry():
	move_player_and_camera(player_spawn.global_position, 0.0)
