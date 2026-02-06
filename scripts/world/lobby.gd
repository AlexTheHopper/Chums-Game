extends room

const TYPE := "lobby"
const BONUS_CHUM_LOC := Vector3(1.0, 0.0, -8.0)

func _ready() -> void:
	super()
	set_bonus_chum_on_load()

func load_room():
	remove_destroyed_decorations()

func set_player_loc_on_entry():
	super()
	if len(Global.room_history) >= 2:
		if Global.room_history[-1][0] != Global.room_history[-2][0]:
			move_player_and_camera(player_spawn.global_position)

func set_bonus_chum_on_load() -> void:
	#First make sure there is a bonus chum for this save:
	if Global.game_save_id not in SaverLoader.game_stats["bonus_chums"].keys():
		return
	var bonus_chum_stats = SaverLoader.game_stats["bonus_chums"][Global.game_save_id]
	Global.print_dev("Creating bonus chum. ID: %s, COST: %s, QUALITY: %s" % [bonus_chum_stats.chum_id, bonus_chum_stats.bracelet_cost, bonus_chum_stats.quality])

	var bonus_chum = ChumsManager.get_specific_chum_id(bonus_chum_stats["chum_id"]).instantiate()
	bonus_chum.bracelet_cost = bonus_chum_stats["bracelet_cost"]
	bonus_chum.quality = bonus_chum_stats["quality"]
	bonus_chum.stats_set = true
	bonus_chum.initial_state_override = "Knock"
	bonus_chum.start_health = 0
	
	get_parent().get_parent().get_node("Chums").add_child(bonus_chum)

	bonus_chum.global_position = BONUS_CHUM_LOC
	bonus_chum.befriended.connect(on_bonus_chum_befriended)

func on_bonus_chum_befriended() -> void:
	#Remove the bonus chum from spawning in the future:
	SaverLoader.game_stats["bonus_chums"].erase(Global.game_save_id)
	SaverLoader.save_gamestate()
