extends room

const TYPE := "lobby"

func load_room():
	remove_destroyed_decorations()

func set_player_loc_on_entry():
	super()
	if len(Global.room_history) >= 2:
		if Global.room_history[-1][0] != Global.room_history[-2][0]:
			move_player_and_camera(player_spawn.global_position)
