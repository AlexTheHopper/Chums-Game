extends CharacterBody3D

var speed := randf_range(0.2, 0.75)
var height := randf_range(2.5, 10.0)
var radius := randf_range(5.0, 15.0)
var time := 0.0
var angle := randf_range(0, 2 * PI)
@onready var timer: Timer = $Timer
var world_n_to_chun_id: Dictionary[int, int] = {1: 17, 2: 18, 3: 19, 4: 20}
var rising := false

func _ready() -> void:
	
	var possible_particles := []
	for history in Global.room_history:
		if history[0] not in possible_particles and history[0] in world_n_to_chun_id.keys():
			possible_particles.append(world_n_to_chun_id[history[0]])
	add_child(load("res://particles/chum%s_particles.tscn" % possible_particles.pick_random()).instantiate())
	
	#Spawns in the air somewhere
	global_position = 15.0 * Vector3(sin(angle), 1.0, cos(angle))
	timer.wait_time = randf_range(7.5, 12.5)
	timer.start()

func _physics_process(delta: float) -> void:
	#Flies in a general circle, then after x time, flies up and queue free
	time += delta * speed
	global_position = global_position.lerp(Vector3(radius * sin(time + angle) + 1, height, radius * cos(time + angle) + 1),
						0.05)
	if rising:
		height += 1.5 * delta
	#check for queue free
	if global_position.y > 20.0:
		queue_free()

func _on_timer_timeout() -> void:
	rising = true
