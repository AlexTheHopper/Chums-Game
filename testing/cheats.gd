extends Node

var chum_spawn_timer := 0.0
var chum_to_spawn := 0

var to_statue_timer := 0.0
var statue_id := 0

func _ready() -> void:
	if not Global.dev_mode:
		queue_free()

func _process(delta: float) -> void:
	#Handling spawning chums:
	if chum_spawn_timer > 0.0:
		chum_spawn_timer -= delta
		if chum_spawn_timer < 0.0:
			chum_spawn_timer = 0
			#SPAWN CHUM HERE
			var player = get_tree().get_first_node_in_group("Player")
			#Spawns chum
			var chum_instance = ChumsManager.get_specific_chum_id(chum_to_spawn).instantiate()
			if Global.world_map[Global.room_location]["activated"]:
				chum_instance.initial_state_override = "Idle"
			get_parent().get_node("Game/Chums").add_child(chum_instance)
			if Global.world_map[Global.room_location]["activated"]:
				chum_instance.make_friendly(false)
				chum_instance.health_node.immune = false
			chum_instance.global_position = player.global_position + Vector3(0, 2, 0)
			chum_to_spawn = 23
			
			PlayerStats.bracelets_added(10)
		
	if Input.is_action_just_pressed("test1"):
		chum_to_spawn += 1
		chum_spawn_timer = 1.0
		print('preparing to spawn chum %s' % chum_to_spawn)

	#Handling taking to statue room.
	if to_statue_timer > 0.0:
		to_statue_timer -= delta
		if to_statue_timer < 0.0:
			#GO TO STATUE ROOM HERE
			var found := false
			var loc := Vector2i(0, 0)
			
			#LOOK
			for room_loc in Global.world_map.keys():
				if Global.world_map[room_loc]["type"] == 5 and Global.world_map[room_loc]["statue_id"] == statue_id:
					found = true
					loc = room_loc
			
			if found:
				Global.transition_to_level(loc)
				print("travelling to room %s with statue id %s" % [loc, statue_id])
			else:
				print("unable to find statue id %s" % statue_id)
			statue_id = 0
			to_statue_timer = 0
			
		
	if Input.is_action_just_pressed("test2"):
		PlayerStats.bracelets_added(1)
		if not Global.in_battle:
			statue_id += 1
			to_statue_timer = 1.0
			print('preparing to go to statue %s' % statue_id)
		else:
			for chum in get_tree().get_nodes_in_group("Chums_Enemy"):
				chum.health_node.health = 0
		
		for loc in Global.world_map.keys():
			Global.world_map[loc]["entered"] = true
