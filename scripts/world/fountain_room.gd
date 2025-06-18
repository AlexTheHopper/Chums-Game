extends room

const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")
const TYPE := "fountain"

func _ready() -> void:	
	super()
	set_player_loc_on_entry()
	set_chums_loc_on_entry()
			
func set_chums_loc_on_entry():
	#Place friendly chums in front of the player:
	if len(Global.room_history) >= 2:
		for chum in get_tree().get_nodes_in_group("Chums_Friend"):
			if chum.state_machine.current_state.name != "Carry":
				var rand_angle = randf_range(0, 2*PI)
				chum.global_position = player.global_position + 3 * Vector3(sin(rand_angle), 0, cos(rand_angle))
				chum.rotation.y = randf_range(0, 2*PI)
				chum.set_state("Idle")

	
func decorate():
	super()
	
	#Streetlamp generally points to fastest way to lobby.
	var to_lobby = Global.world_map_guide["lobby"][Global.room_location] * 13
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x + randf_range(-1.5, 1.5)
	spawn_pos.z += to_lobby.y + randf_range(-1.5, 1.5)
		
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = spawn_pos
	Global.world_map[Global.room_location]["light_position"] = spawn_pos
	
	#Other objects:
	#Other objects:
	var from_lobby = Global.world_map[Global.room_location]["value"]
	var deco_n = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(5, 20))
	var angles = [0, PI/2, PI, 3*PI/2]
	var dummy = 0
	for n in int(deco_n * DecorationManager.decorations_world[Global.current_world_num]['multiplier']):
		var chosen_deco = DecorationManager.get_common_decoration(Global.current_world_num)
		var deco_inst = chosen_deco[0].instantiate()
		$Decorations.add_child(deco_inst)
		
		var x = randf_range(-13, 15)
		var y = 0
		if -9 < x and x < 11:
			y = randf_range(-13, -9) if randf() < 0.5 else randf_range(11, 15)
		else:
			y = randf_range(-13, 15)
		if randf() < 0.5:
			dummy = x
			x = y
			y = dummy
		var pos = Vector3(x, 0, y)
		
		deco_inst.global_position = pos
		var angle = angles.pick_random()
		deco_inst.rotation.y = angle
		
		Global.world_map[Global.room_location]["decorations"].append({"name": chosen_deco[1], "position": pos, "rotation": angle})
	
	
