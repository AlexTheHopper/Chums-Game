extends room
class_name endgame_room

const TYPE := "endgame"

var thrown_prisoners := []
@onready var tiles: GridMap = $NavigationRegion3D/GridMap
@onready var random_level_being: CharacterBody3D = $Decorations/EndgameBeing
@onready var endgame_being: CharacterBody3D = $Decorations/EndgameBeing

func _ready() -> void:
	$Decorations/Void.prisoner_entered.connect(being_thrown)
	move_player_and_camera($PlayerSpawn.global_position, PI)
	set_chums_loc_on_entry()
	tiles.mesh_library = load("res://assets/world/meshlib_world_%s.tres" % Global.current_world_num)
	for text in $Texts.get_children():
		text.player_entered.connect(change_being_goal)

func being_thrown(chum_id: int) -> void:
	print(chum_id)

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
