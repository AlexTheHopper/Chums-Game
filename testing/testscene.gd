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
	PlayerStats.initialize()
	get_node("/root/Testscene/HUD").initialize()
	get_node("/root/Testscene/HUD").add_chum_indicators()
	rng = RandomNumberGenerator.new()
	
	for i in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20, 21, 22, 23, 24]:
		create_cage(Vector3(6.0 + (12.0 if i > 12 else 0.0), 0.0, -60.0 + i * 12.0 if i <= 10 else -60.0 + (i-10) * 12.0), i, 24)
		
	
	#for i in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]:
		#var chum_to_add = ChumsManager.get_specific_chum_id(i)
		#var chum_instance = chum_to_add.instantiate()
		#$Test.add_child(chum_instance)
	#
	#for chum in $Test.get_children():
		#for node in chum.get_children():
			#if node is CollisionShape3D:
				#distance_dict[chum.chum_id] = {"radius": node.shape.radius, "attack_distance": chum.attack_distance}
	#print(distance_dict)

func create_cage(spawn_position, id1, id2):
	var to_add = CAGE_TESTING.instantiate()
	to_add.id_1 = id1
	to_add.id_2 = id2
	
	cages.add_child(to_add)
	to_add.global_position = spawn_position
