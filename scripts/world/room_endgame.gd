extends room
class_name endgame_room

const TYPE := "endgame"

var thrown_prisoners := []
@onready var tiles: GridMap = $NavigationRegion3D/GridMap
@onready var random_level_being: CharacterBody3D = $Decorations/EndgameBeing
@onready var endgame_being: CharacterBody3D = $Decorations/EndgameBeing
@onready var void_pool: Node3D = $Decorations/Void
@onready var prisoner_spawns: Node3D = $PrisonerSpawns


func _ready() -> void:
	void_pool.prisoner_entered.connect(on_prisoner_thrown)
	move_player_and_camera($PlayerSpawn.global_position, PI)
	set_chums_loc_on_entry()
	tiles.mesh_library = load("res://assets/world/meshlib_world_%s.tres" % Global.current_world_num)
	for text in $Texts.get_children():
		text.player_entered.connect(change_being_goal)

	#Move prisoners to next to pool.
	for chum in get_tree().get_nodes_in_group("Chums_Friend"):
		if chum.chum_id in [17, 18, 19, 20] and chum.being_particles:
			chum.global_position = prisoner_spawns.get_node("Chum%s" % chum.chum_id).global_position
			chum.being_particles.restart_particles()

func on_prisoner_thrown(chum_id: int) -> void:
	thrown_prisoners.append(chum_id)
	thrown_prisoners.sort()
	#slightly messy but i cant set() them :/
	if thrown_prisoners.has(17) and thrown_prisoners.has(18) and thrown_prisoners.has(19) and thrown_prisoners.has(20):
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
