extends room

const TYPE := "lobby"
@onready var player_spawn_node := $PlayerSpawn

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

func load_room():
	pass

func set_player_loc_on_entry():
	super()
	if len(Global.room_history) >= 2:
		if Global.room_history[-1][0] != Global.room_history[-2][0]:
			move_player_and_camera(player_spawn_node.global_position)
