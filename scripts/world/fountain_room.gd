extends room
class_name fountain_room

const STREETLAMP = preload("res://scenes/world/streetlamp.tscn")
const TYPE := "fountain"

func decorate():
	super()
	#Streetlamp generally points to fastest way to lobby.
	var to_lobby = Global.world_map_guide["lobby"][Global.room_location] * 13
	var spawn_pos = Vector3(1, 0, 1)
	spawn_pos.x += to_lobby.x + randf_range(-1.5, 1.5)
	spawn_pos.z += to_lobby.y + randf_range(-1.5, 1.5)
		
	var light_obj = STREETLAMP.instantiate()
	$Decorations.add_child(light_obj)
	light_obj.global_position = spawn_pos.snapped(Vector3(0.1, 0.1, 0.1))
	
	#Other objects:
	var from_lobby = Global.world_map[Global.room_location]["max_value"]
	var deco_n = Functions.map_range(from_lobby, Vector2(0, Global.map_size), Vector2(10, 100))
	var angles := [0, PI/2, PI, 3*PI/2]
	var dummy = 0
	var decos_to_add := []

	for n in int(deco_n * DecorationManager.decorations_world[Global.current_world_num]['multiplier']):
		var chosen_deco = DecorationManager.get_random_decoration(Global.current_world_num)
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
		var pos = Vector3(x, 0, y).snapped(Vector3(0.1, 0.1, 0.1))
		var angle = angles.pick_random()

		decos_to_add.append([chosen_deco[0], pos, angle])

	for deco in decos_to_add:
		if deco[1] not in Global.world_map[Global.room_location]["removed_decorations"]:
			var to_add = deco[0].instantiate()
			$Decorations.add_child(to_add)
			to_add.global_position = deco[1]
			to_add.rotation.y = deco[2]
	decos_to_add = []
