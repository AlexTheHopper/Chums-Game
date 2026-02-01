extends Node

signal Saved
signal Loaded
signal Deleted

signal Gamestate_Saved
signal Gamestate_Loaded

var game_settings: Dictionary
var default_game_settings: Dictionary = {
		"is_fullscreen": false,
		"camera_shake": 2,
		"selected_language": "en_US",
		"volume_Music": 3,
		"volume_SFX": 3,
	}

var game_stats: Dictionary
var default_game_stats = {
}

func _ready() -> void:
	ensure_save_folder()
	ensure_gamestate()
	load_gamestate()

func ensure_save_folder() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func ensure_gamestate() -> void:
	if FileAccess.file_exists("user://saves/gamestate.tres"):
		return

	game_settings = default_game_settings
	game_stats = default_game_stats
	save_gamestate()

func save_gamestate() -> void:
	var saved_gamestate: GameState = GameState.new()
	
	saved_gamestate.game_settings = game_settings
	saved_gamestate.game_stats = game_stats
	
	ResourceSaver.save(saved_gamestate, "user://saves/gamestate.tres")
	
	Gamestate_Saved.emit()

func load_gamestate() -> void:
	ensure_gamestate()
	
	var saved_gamestate:GameState = load("user://saves/gamestate.tres")
	
	game_settings = saved_gamestate.game_settings
	game_stats = saved_gamestate.game_stats
	
	#Make sure any new data are added:
	for key in default_game_settings.keys():
		if key not in game_settings.keys():
			game_settings[key] = default_game_settings[key]
	for key in default_game_stats.keys():
		if key not in game_stats.keys():
			game_stats[key] = default_game_stats[key]
	
	Gamestate_Loaded.emit()

func save_game(save_id) -> void:
	ensure_save_folder()
	var saved_game:SavedGame = SavedGame.new()
	
	#Save all save data:
	#Time
	saved_game.unix_time = int(Time.get_unix_time_from_system())
	saved_game.date_time = Time.get_datetime_string_from_unix_time(saved_game.unix_time)
	saved_game.save_seed = Global.save_seed

	#Player Data:
	saved_game.player_health = PlayerStats.player_health
	saved_game.player_max_health = PlayerStats.player_max_health
	saved_game.player_max_chums = PlayerStats.player_max_chums
	saved_game.player_bracelets = PlayerStats.bracelets
	saved_game.player_collected_lanterns = PlayerStats.collected_lanterns
	saved_game.player_damage = get_tree().get_first_node_in_group("Player").base_damage
	saved_game.player_extra_damage = get_tree().get_first_node_in_group("Player").max_extra_damage
	saved_game.player_chums_befriended = PlayerStats.player_chums_befriended
	saved_game.player_unique_chums_befriended = PlayerStats.player_unique_chums_befriended
	saved_game.player_bracelets_collected = PlayerStats.player_bracelets_collected
	saved_game.player_bracelets_spent = PlayerStats.player_bracelets_spent

	#Friend Chums Data:
	saved_game.friendly_chums = []
	for chum in get_tree().get_nodes_in_group("Chums_Friend").filter(func(c): return not c.is_temporary):
		saved_game.friendly_chums.append({
			"id": chum.chum_id,
			"quality": chum.quality,
			"health": chum.health_node.get_health(),
			"state": "Idle",
			"cost": chum.bracelet_cost,
			})
	
	#World Data:
	saved_game.world_transition_count = Global.world_transition_count
	saved_game.viewed_lore = Global.viewed_lore
	saved_game.current_world_num = Global.current_world_num
	saved_game.world_grid = Global.world_grid
	saved_game.room_location = Global.room_location
	saved_game.room_history = Global.room_history
	saved_game.world_map = Global.world_map
	
	ResourceSaver.save(saved_game, "user://saves/%s.tres" % [save_id])
	Saved.emit()

func load_game(save_id) -> void:
	ensure_save_folder()
	var saved_game:SavedGame = load("user://saves/%s.tres" % [save_id])

	if Global.dev_mode:
		print("loading game from id %s with seed %s" % [save_id, saved_game.save_seed])

	#Load all save data:
	Global.save_seed = saved_game.save_seed
	#Player Data
	get_tree().get_first_node_in_group("Player").health_node.health = saved_game.player_health
	get_tree().get_first_node_in_group("Player").health_node.max_health = saved_game.player_max_health
	get_tree().get_first_node_in_group("Player").base_damage = saved_game.player_damage
	get_tree().get_first_node_in_group("Player").max_extra_damage = saved_game.player_extra_damage
	PlayerStats.player_max_chums = saved_game.player_max_chums
	PlayerStats.bracelets = saved_game.player_bracelets
	PlayerStats.hud_bracelets_change.emit()
	PlayerStats.collected_lanterns = saved_game.player_collected_lanterns
	PlayerStats.player_chums_befriended = saved_game.player_chums_befriended
	PlayerStats.player_unique_chums_befriended = saved_game.player_unique_chums_befriended
	PlayerStats.player_bracelets_collected = saved_game.player_bracelets_collected
	PlayerStats.player_bracelets_spent = saved_game.player_bracelets_spent

	#Friend Chums Data:
	for chum in saved_game.friendly_chums:
		var chum_to_add = ChumsManager.get_specific_chum_id(chum["id"])
		var chum_instance = chum_to_add.instantiate()
		
		chum_instance.quality = chum["quality"]
		chum_instance.bracelet_cost = chum["cost"]
		chum_instance.stats_set = true
		
		chum_instance.start_health = chum["health"]
		chum_instance.initial_state_override = chum["state"]
		
		get_parent().get_node("Game/Chums").add_child(chum_instance)
		chum_instance.make_friendly(false)
		chum_instance.health_node.immune = false
	PlayerStats.player_chums_changed.emit()

	#World Data:
	Global.world_transition_count = saved_game.world_transition_count
	Global.viewed_lore = saved_game.viewed_lore
	Global.current_world_num = saved_game.current_world_num
	Global.world_grid = saved_game.world_grid
	Global.room_location = saved_game.room_location
	Global.room_history = saved_game.room_history
	Global.world_map = saved_game.world_map
	
	Global.game_save_id = save_id
	
	Loaded.emit()

func delete_save(save_id) -> void:
	if Global.dev_mode:
		print("deleting save from id %s" % [save_id])
	ensure_save_folder()
	
	var dir = DirAccess.open("user://")
	dir.remove("saves/%s.tres" % [save_id])
	
	Deleted.emit()
