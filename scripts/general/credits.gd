extends Node3D

var credits_done := true

@export var chum_ids : Array[int]
@export var chum_locations: Array[Node3D]
@export var max_camera_height := 190.0

@onready var camera: Camera3D = $Camera3D
@onready var entities: Node3D = $Entities

signal return_to_main_menu

func _ready() -> void:
	Global.game_begun = false
	return_to_main_menu.connect(Global.restart_game)
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

func spawn_chum(chum_id: int, location: Vector3, angle: float) -> void:
	var chum_to_spawn = ChumsManager.get_specific_chum_id(chum_id)
	if not chum_to_spawn:
		return
	#Spawns chum
	var chum_instance = chum_to_spawn.instantiate()
	entities.add_child(chum_instance)
	chum_instance.global_position = location + Vector3(3.0 * sin(angle), 0.0, 3.0 * cos(angle))
	chum_instance.generalchumbehaviour.visible = false
	chum_instance.sleep_zone.queue_free()
	chum_instance.rotation.y = randf_range(0, 2*PI)
	chum_instance.scale = Vector3(1.5, 1.5, 1.5)
	chum_instance.anim_player.play("Idle")
	chum_instance.anim_player.speed_scale = randf_range(0.8, 1.2)

func exit_credits() -> void:
	await get_tree().create_timer(2.5).timeout
	TransitionScreen.transition(3)
	await TransitionScreen.on_transition_finished
	return_to_main_menu.emit(false, false)
	queue_free()
