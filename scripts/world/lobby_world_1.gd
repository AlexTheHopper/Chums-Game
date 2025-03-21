extends room


func _ready() -> void:	
	super()
	set_player_loc_on_entry()
	set_chums_loc_on_entry()
	
	
func set_chums_loc_on_entry():
	#Place friendly chums in front of the player:
	if len(Global.room_history) >= 2:
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			if chum.state_machine.current_state.name != "Carry":
				chum.global_position = lerp(player.global_position, Vector3(1, 0, 1), 0.5) + Vector3(randf_range(-3, 3), 0, randf_range(-3, 3))
				chum.rotation.y = randf_range(0, 2*PI)
				chum.set_state("Idle")

func load_room():
	pass
