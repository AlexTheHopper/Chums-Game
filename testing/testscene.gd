extends Node3D
@onready var cages: Node3D = $cages
var test_world_seed = 1
var room_1_seed = 100
var room_2_seed = 101
var current_room = 1
var rng

func _ready() -> void:
	Global.current_room_node = self
	PlayerStats.initialize()
	get_node("/root/Testscene/HUD").initialize()
	get_node("/root/Testscene/HUD").add_chum_indicators()
	rng = RandomNumberGenerator.new()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		if current_room == 1:
			current_room = 2
			print('room: 2')
			rng.seed = room_2_seed
		else:
			current_room = 1
			print('room 1')
			rng.seed = room_1_seed
		for n in range(5):
			print(rng.randi_range(0, 10))


func _on_timer_timeout() -> void:
	print(randi())
