extends Node

func _ready() -> void:
	ensure_save_folder()

func ensure_save_folder() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func save_game(save_id) -> void:
	if Global.dev_mode:
		print("saving game to id %s" % [save_id])
	ensure_save_folder()
	var saved_game:SavedGame = SavedGame.new()
	
	#Save all save data:
	#Time
	saved_game.unix_time = int(Time.get_unix_time_from_system())
	saved_game.date_time = Time.get_datetime_string_from_unix_time(saved_game.unix_time)
	
	#Player Data:
	saved_game.player_health = PlayerStats.player_health
	saved_game.player_max_health = PlayerStats.player_max_health
	saved_game.player_max_chums = PlayerStats.player_max_chums
	saved_game.player_bracelets = PlayerStats.bracelets
	
	#Friend Chums Data:
	saved_game.friendly_chums = []
	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		saved_game.friendly_chums.append({"type": chum.chum_str,
											"quality": chum.quality,
											"health": chum.health_node.get_health(),
											"max_health": chum.health_node.get_max_health(),
											"state": "Idle"})
	
	#World Data:
	saved_game.world_transition_count = Global.world_transition_count
	saved_game.current_world_num = Global.current_world_num
	saved_game.world_grid = Global.world_grid
	saved_game.room_location = Global.room_location
	saved_game.room_history = Global.room_history
	saved_game.world_map_guide = Global.world_map_guide
	saved_game.world_map = Global.world_map
	
	ResourceSaver.save(saved_game, "user://saves/%s.tres" % [save_id])


func load_game(save_id) -> void:
	if Global.dev_mode:
		print("loading game from id %s" % [save_id])
	ensure_save_folder()
	var saved_game:SavedGame = load("user://saves/%s.tres" % [save_id])
	
	#Load all save data:
	#Player Data
	get_tree().get_first_node_in_group("Player").health_node.health = saved_game.player_health
	get_tree().get_first_node_in_group("Player").health_node.max_health = saved_game.player_max_health
	PlayerStats.player_max_chums = saved_game.player_max_chums
	PlayerStats.bracelets = saved_game.player_bracelets
	PlayerStats.hud_bracelets_change.emit()
	
	#Friend Chums Data:
	for chum in saved_game.friendly_chums:
		var chum_to_add = ChumsManager.get_specific_chum_str(chum["type"])
		var chum_instance = chum_to_add.instantiate()
		
		#chum_instance.attack = chum["attack"]
		#chum_instance.move_speed = chum["move_speed"]
		chum_instance.quality = chum["quality"]
		chum_instance.stats_set = true
		
		chum_instance.start_health = chum["health"]
		chum_instance.max_health = chum["max_health"]
		chum_instance.initial_state_override = chum["state"]
		
		get_parent().get_node("Game/Chums").add_child(chum_instance)
		chum_instance.make_friendly()
		chum_instance.health_node.immune = false
	PlayerStats.player_chums_changed.emit()

	#World Data:
	Global.world_transition_count = saved_game.world_transition_count
	Global.current_world_num = saved_game.current_world_num
	Global.world_grid = saved_game.world_grid
	Global.room_location = saved_game.room_location
	Global.room_history = saved_game.room_history
	Global.world_map_guide = saved_game.world_map_guide
	Global.world_map = saved_game.world_map
	
	Global.game_save_id = save_id

func delete_save(save_id) -> void:
	if Global.dev_mode:
		print("deleting save from id %s" % [save_id])
	ensure_save_folder()
	
	var dir = DirAccess.open("user://")
	dir.remove("saves/%s.tres" % [save_id])
