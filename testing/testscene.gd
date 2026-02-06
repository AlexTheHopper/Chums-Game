extends Node3D
@onready var cages: Node3D = $cages
var test_world_seed = 1
var room_1_seed = 100
var room_2_seed = 101
var current_room = 1
var rng
const CAGE_TESTING = preload("uid://doc0b1wjqgvyd")


var distance_dict := {}

func _ready() -> void:
	Global.current_room_node = self
	PlayerStats.initialise()
	get_node("/root/Testscene/HUD").initialise()
	get_node("/root/Testscene/HUD").add_chum_indicators()
	rng = RandomNumberGenerator.new()
	
	for i in ChumsManager.chums_list.keys():
		create_cage(Vector3(6.0 + (12.0 if i > 14 else 0.0), 0.0, -60.0 + i * 12.0 if i <= 14 else -60.0 + (i-10) * 12.0), i, 28)

func create_cage(spawn_position, id1, id2):
	var to_add = CAGE_TESTING.instantiate()
	to_add.id_1 = id1
	to_add.id_2 = id2
	
	cages.add_child(to_add)
	to_add.global_position = spawn_position
