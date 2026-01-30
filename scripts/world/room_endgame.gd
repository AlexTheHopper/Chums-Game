extends room
class_name endgame_room

const TYPE := "endgame"

var thrown_prisoners := []
@onready var tiles: GridMap = $NavigationRegion3D/GridMap
@onready var random_level_being: CharacterBody3D = $Decorations/EndgameBeing
@onready var endgame_being: CharacterBody3D = $Decorations/EndgameBeing
@onready var void_pool: Node3D = $Decorations/Void


func _ready() -> void:
	void_pool.prisoner_entered.connect(on_prisoner_thrown)
	move_player_and_camera($PlayerSpawn.global_position, PI)
	set_chums_loc_on_entry()
	tiles.mesh_library = load("res://assets/world/meshlib_world_%s.tres" % Global.current_world_num)
	for text in $Texts.get_children():
		text.player_entered.connect(change_being_goal)

func on_prisoner_thrown(chum_id: int) -> void:
	thrown_prisoners.append(chum_id)
	thrown_prisoners.sort()
	if thrown_prisoners == [17, 18, 19, 20]:
		await get_tree().create_timer(10.0).timeout
		for child in Global.current_room_node.get_node("Decorations").get_children():
			if child is RandomLevelBeing:
				child.rising = true
		
		await get_tree().create_timer(5.0).timeout
		get_tree().get_first_node_in_group("Player")._on_health_health_depleted()

func save_room() -> void:
	pass

#func load_room() -> void:
	#pass
#
#func decorate() -> void:
	#pass
#
#func fill_tunnels() -> void:
	#pass
#
#func set_player_loc_on_entry() -> void:
	#pass
#
#func set_chums_loc_on_entry() -> void:
	#pass

func change_being_goal(text: Node3D) -> void:
	endgame_being.change_goal(text.global_position)
