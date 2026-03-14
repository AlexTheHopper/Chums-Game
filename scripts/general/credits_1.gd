extends Credits


@export var chum_ids : Array[int]
@export var chum_locations: Array[Node3D]
@export var max_camera_height := 190.0


func _ready() -> void:
	super()
	PlayerStats.attempt_achievement_unlock(PlayerStats.ACHIEVEMENTS.ACH_ON_CREDITS_1)
	var counter := 0
	var chum_count := chum_ids.size()
	for spawn_location in chum_locations:
		counter = 0
		
		for chum_id in chum_ids:
			spawn_chum(chum_id, spawn_location.global_position, 2 * PI * counter / chum_count)
			counter += 1

func _physics_process(delta: float) -> void:
	#Speed up camera
	if camera.global_position.y >= max_camera_height:
		if credits_done and (Input.is_action_pressed("attack") or Input.is_action_pressed("interact") or Input.is_action_pressed("jump")):
			credits_done = false
			exit_credits()
		return

	camera.global_position.y += delta * (1.0 if not (Input.is_action_pressed("attack") or Input.is_action_pressed("interact") or Input.is_action_pressed("jump")) else 3.0)
